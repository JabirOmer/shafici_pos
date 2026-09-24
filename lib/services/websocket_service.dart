import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';

/// Connection role. Either app can be the host — whichever device starts
/// first and calls `startAsHost()` becomes the server; the other calls
/// `connectAsClient()` (optionally after `discoverHost()`).
enum ConnectionRole { host, client, none }

enum ConnectionStatus { disconnected, searching, connecting, connected }

/// A single incoming/outgoing message. `type` lets you route different
/// kinds of payloads (e.g. "order", "ack", "ping") through one channel.
class SocketMessage {
  final String type;
  final Map<String, dynamic> data;
  final String? fromClientId;

  SocketMessage({required this.type, required this.data, this.fromClientId});

  String encode() => jsonEncode({'type': type, 'data': data});

  factory SocketMessage.decode(String raw, {String? fromClientId}) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return SocketMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      fromClientId: fromClientId,
    );
  }
}

/// Universal WebSocket service. Works identically on Windows, macOS,
/// Android and iOS since it only relies on dart:io sockets.
///
/// Usage:
///   - Device that should listen: `await service.startAsHost();`
///   - Device that should connect: `await service.discoverAndConnect();`
///   - Either side: `service.send(SocketMessage(...))`
///   - Either side: `service.messages.listen((msg) => ...)`
class WebSocketService {
  WebSocketService({
    this.wsPort = 4040,
    this.discoveryPort = 4041,
    this.discoveryToken = 'APP_DISCOVER',
    this.discoveryReplyPrefix = 'APP_HERE',
  });

  final int wsPort;
  final int discoveryPort;
  final String discoveryToken;
  final String discoveryReplyPrefix;

  ConnectionRole role = ConnectionRole.none;

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get status => _statusController.stream;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;

  final _messageController = StreamController<SocketMessage>.broadcast();
  Stream<SocketMessage> get messages => _messageController.stream;

  // --- host state ---
  HttpServer? _httpServer;
  RawDatagramSocket? _discoveryResponder;
  final Map<String, WebSocket> _clients = {};
  int _clientCounter = 0;

  // --- client state ---
  IOWebSocketChannel? _channel;
  StreamSubscription? _channelSub;

  void _setStatus(ConnectionStatus s) {
    _currentStatus = s;
    _statusController.add(s);
  }

  ConnectionStatus get currentStatus => _currentStatus;

  // ---------------------------------------------------------------------
  // HOST SIDE (e.g. Cashier app)
  // ---------------------------------------------------------------------

  /// Starts listening for connections and answers UDP discovery pings.
  Future<void> startAsHost() async {
    role = ConnectionRole.host;
    _setStatus(ConnectionStatus.connecting);

    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, wsPort);
    _httpServer!.listen((HttpRequest req) async {
      if (!WebSocketTransformer.isUpgradeRequest(req)) return;
      final ws = await WebSocketTransformer.upgrade(req);
      final clientId = 'client_${_clientCounter++}';
      _clients[clientId] = ws;
      _setStatus(ConnectionStatus.connected);

      ws.listen(
        (raw) {
          try {
            _messageController.add(
              SocketMessage.decode(raw as String, fromClientId: clientId),
            );
          } catch (_) {
            // ignore malformed payloads
          }
        },
        onDone: () {
          _clients.remove(clientId);
          if (_clients.isEmpty) _setStatus(ConnectionStatus.disconnected);
        },
        onError: (_) => _clients.remove(clientId),
      );
    });

    _discoveryResponder =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort);
    _discoveryResponder!.broadcastEnabled = true;
    _discoveryResponder!.listen((event) {
      if (event != RawSocketEvent.read) return;
      final dg = _discoveryResponder!.receive();
      if (dg == null) return;
      if (utf8.decode(dg.data) == discoveryToken) {
        _discoveryResponder!.send(
          utf8.encode('$discoveryReplyPrefix:$wsPort'),
          dg.address,
          dg.port,
        );
      }
    });

    _setStatus(ConnectionStatus.disconnected); // listening, no clients yet
  }

  // ---------------------------------------------------------------------
  // CLIENT SIDE (e.g. POS app)
  // ---------------------------------------------------------------------

  /// Broadcasts a discovery ping on the LAN, connects to the first host
  /// that replies. Throws [TimeoutException] if nothing replies in time.
  Future<void> discoverAndConnect({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    role = ConnectionRole.client;
    _setStatus(ConnectionStatus.searching);

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final completer = Completer<String>();

    final sub = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final dg = socket.receive();
      if (dg == null) return;
      final msg = utf8.decode(dg.data);
      if (msg.startsWith('$discoveryReplyPrefix:') && !completer.isCompleted) {
        completer.complete('${dg.address.address}:${msg.split(':')[1]}');
      }
    });

    socket.send(
      utf8.encode(discoveryToken),
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );

    try {
      final result = await completer.future.timeout(timeout);
      await sub.cancel();
      socket.close();
      final parts = result.split(':');
      await connectDirect(parts[0], int.parse(parts[1]));
    } on TimeoutException {
      await sub.cancel();
      socket.close();
      _setStatus(ConnectionStatus.disconnected);
      rethrow;
    }
  }

  /// Connects straight to a known host IP:port, skipping discovery.
  /// Useful for manual entry / reconnect / saved-address flows.
  Future<void> connectDirect(String ip, int port) async {
    role = ConnectionRole.client;
    _setStatus(ConnectionStatus.connecting);

    _channel = IOWebSocketChannel.connect('ws://$ip:$port');
    _setStatus(ConnectionStatus.connected);

    _channelSub = _channel!.stream.listen(
      (raw) {
        try {
          _messageController.add(SocketMessage.decode(raw as String));
        } catch (_) {
          // ignore malformed payloads
        }
      },
      onDone: () => _setStatus(ConnectionStatus.disconnected),
      onError: (_) => _setStatus(ConnectionStatus.disconnected),
    );
  }

  // ---------------------------------------------------------------------
  // SHARED API
  // ---------------------------------------------------------------------

  /// Sends a message. On the host, broadcasts to all connected clients
  /// unless [toClientId] is given. On the client, sends to the host.
  void send(SocketMessage message, {String? toClientId}) {
    final encoded = message.encode();
    if (role == ConnectionRole.host) {
      if (toClientId != null) {
        _clients[toClientId]?.add(encoded);
      } else {
        for (final ws in _clients.values) {
          ws.add(encoded);
        }
      }
    } else if (role == ConnectionRole.client) {
      _channel?.sink.add(encoded);
    }
  }

  int get connectedClientCount => _clients.length;

  Future<void> stop() async {
    await _httpServer?.close(force: true);
    _discoveryResponder?.close();
    await _channelSub?.cancel();
    await _channel?.sink.close();
    _clients.clear();
    role = ConnectionRole.none;
    _setStatus(ConnectionStatus.disconnected);
  }

  void dispose() {
    stop();
    _statusController.close();
    _messageController.close();
  }
}