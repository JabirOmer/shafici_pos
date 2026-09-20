enum WebSocketMessageType { ping, pong, connection, order }

class WebSocketMessageModel {
  final String type;
  final dynamic data;

  WebSocketMessageModel({
    required this.type,
    required this.data
  });


  factory WebSocketMessageModel.fromMap(Map<String, dynamic> message) {
    return WebSocketMessageModel(
      type: message['type'], 
      data: message['data']
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "type": type.toString(),
      "data": data
    };
  }
}