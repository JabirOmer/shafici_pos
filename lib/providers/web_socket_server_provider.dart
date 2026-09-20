import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/models/web_socket_message_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';

enum ServerStatus { stopped, starting, running, stopping, error }

class WebSocketServerProvider extends ChangeNotifier {
  // final AppInfoProvider appInfoProvider;

  HttpServer? _server;
  final List<WebSocket> _clients = [];
  ServerStatus _serverStatus = ServerStatus.stopped;
  String? _errorMessage;
  String? _serverAddress;

  // Getters for UI
  ServerStatus get serverStatus => _serverStatus;
  String? get errorMessage => _errorMessage;
  int get clientCount => _clients.length;
  String? get serverAddress => _serverAddress;



  // WebSocketServerProvider({
  //   required this.appInfoProvider
  // });

  



  // - - - - - - >>
  // - - - S T A R T _ S E R V E R
  Future<bool> startServer() async {
    if (kDebugMode) print('startServer on instance: ${identityHashCode(this)}');

    if (_serverStatus == ServerStatus.running) {
      if (kDebugMode) print('Server is already running');
      return false;
    }

    if (_serverStatus == ServerStatus.starting) {
      if (kDebugMode) print('Server is already starting...');
      return false;
    }

    final port = int.tryParse(CSharedPreferencesServices().getString(CSharedPrefsKeys.socketPort) ?? '') ?? 4040;
    final address = InternetAddress.anyIPv4;

    _serverStatus = ServerStatus.starting;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    try {
      _server = await HttpServer.bind(address, port);
      _serverStatus = ServerStatus.running;
      notifyListeners();

      // Listen for connections
      _server!.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          _handleSocketConnection(request);
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..write('Websocket connection only')
            ..close();
        }
      }, onError: (error) {
        _serverStatus = ServerStatus.error;
        _errorMessage = 'connection failed';
        notifyListeners();
      }); 

      return true;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      _serverStatus = ServerStatus.error;
      _errorMessage = 'failed to start server';
      notifyListeners();
      return false;
    }
  }
  // - - - S T A R T _ S E R V E R
  // - - - - - - >>



  // - - - - - - >>
  // - - - S T O P _ S E R V E R
  Future<void> stopServer() async {
    if (_serverStatus == ServerStatus.stopped) {
      if (kDebugMode) print('Server is already stopped');
      return;
    }

    if (_serverStatus == ServerStatus.stopping) {
      if (kDebugMode) print('Server is already stopping...');
      return;
    }

    _serverStatus = ServerStatus.stopping;
    notifyListeners();

    try {
      // Close all clients with individual error handling
      final List<Future> closeFutures = _clients.map((client) async {
        try {
          await client.close();
        } catch (e) {
          if (kDebugMode) print('Error closing client: $e');
        }
      }).toList();
      
      await Future.wait(closeFutures);
      _clients.clear();

      // Close server
      await _server?.close();
      _server = null;
      _serverStatus = ServerStatus.stopped;
      notifyListeners();
    } catch (e) {
      _serverStatus = ServerStatus.stopped;
      if (kDebugMode) print('failed to stop server: $e');
      notifyListeners();
    }
  }
  
  
  


  // - - - - - - >>
  // - - - T O G G L E _ C O N N E C T I O N
  Future<void> toggleConnection() async {
    _serverStatus == ServerStatus.running ? await stopServer() : await startServer();
    await _setLocalIPAddress();
  }






  // - - - - - - >>
  // - - - S E N D _ M E S S A G E
  Future<bool> sendMessage(WebSocketMessageModel message) async {
    if (kDebugMode) print('sendMessage on instance: ${identityHashCode(this)}, status: $_serverStatus');
    if (_serverStatus != ServerStatus.running) {
      if (kDebugMode) print('Cannot send: server is not running');
      return false;
    }

    if (_clients.isEmpty) {
      if (kDebugMode) print('Cannot send: no connected clients');
      return false;
    }


    final encodedMessage = jsonEncode(message);

    // Iterate over a copy so removals don't break the loop
    bool sentToAny = false;
    for (final client in List<WebSocket>.from(_clients)) {
      try {
        if (client.readyState == WebSocket.open) {
          client.add(encodedMessage);
          sentToAny = true;
        } else {
          _clients.remove(client);
        }
      } catch (e) {
        if (kDebugMode) print('Failed to send to client: $e');
        _clients.remove(client);
      }
    }

    notifyListeners();
    return sentToAny;
  }





  // - - - - - - >>
  // - - - S E N D _ T O _ C L I E N T
  Future<void> sendMessageToClient(WebSocketMessageModel message, WebSocket socket) async {
    final encodedMessage = jsonEncode(message);
    socket.add(encodedMessage);
  }





  // * * * * * * *
  // * * * * P R I V A T E _ F U N C T I O N S
  // * * * * * * *





  // - - - H A N D L E _ S O C K E T _ C O N N E C T I O N
  Future<void> _handleSocketConnection(HttpRequest request) async {
    try {
      // appInfoProvider = Provider.of(context)
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      _clients.add(socket);
      if (kDebugMode) print('Client connected. Total clients: ${_clients.length}');
      notifyListeners();

      final connectionMessage = WebSocketMessageModel(
        type: WebSocketMessageType.connection.name, 
        // data: { 'business_name': appInfoProvider.deviceData?.branchName ?? 'unknown' }
        data: { 'business_name': 'zain mmaart' }
      );
      
      sendMessageToClient(connectionMessage, socket);

      socket.listen(
        (message) => _handleMessage(socket, message),
        onDone: () {
          _clients.remove(socket);
          if (kDebugMode) print('Client disconnected. Total clients: ${_clients.length}');
          notifyListeners();
        },
        onError: (error) {
          if (kDebugMode) print('Websocket error: $error');
          _clients.remove(socket);
          notifyListeners();
        }
      );
    } catch (e) {
      if (kDebugMode) print('Error handling websocket connection: $e');
    }
  }



  // - - - H A N D L E _ M E S S A G E
  void _handleMessage(WebSocket sender, dynamic message) { }



  // - - - G E T _ L O C A L _ I P
  Future<void> _setLocalIPAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false
    );
    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        if (!address.isLoopback) {
          _serverAddress = address.address;
          notifyListeners();
          return;
        }
      }
    }
    _serverAddress = null;
    notifyListeners();
    return;
  }




  // - - - D I S P O S E
  @override
  void dispose() {
    stopServer();
    super.dispose();
  }

}