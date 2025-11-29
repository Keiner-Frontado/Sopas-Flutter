import 'dart:convert';
import 'dart:io';

class Client{
  Socket socket;
  late String ip, name;
  late int port;
  late Stream<String> stream;

  Client(this.socket){
    ip = socket.remoteAddress.address;
    port = socket.remotePort;
    name = "user_$port";
    stream = utf8.decoder.bind(socket);
  }

  void send(Map<String, dynamic> msgData){
    Map<String, dynamic> data = {
      ...msgData,
      'from': name
    };
    socket.writeln(
      jsonEncode(data)
    );
  }

  void setName(String name){
    this.name = name;
  }

  Future<void> disconnect() async {
    try {
      socket.close();
    } catch (_) {

    }
  }
}
