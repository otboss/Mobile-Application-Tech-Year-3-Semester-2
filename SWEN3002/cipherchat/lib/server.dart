import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import './main.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';

class Server {
  int port = 6333;
  String ip = "unknown";
  HttpServer server;

  Server() {
    print("STARTING SERVER..");
    startServer();
  }

  int choosePort() {
    Random rng = Random();
    int min = 2000;
    int max = 12000;
    return min + rng.nextInt(max - min);
  }

  Future<String> getPublicIpAddress() async {
    try{
      Response response = await dio.get("http://ipecho.net/plain");
      return response.data;
    }
    catch(err){
      print(err);
    }
    return "unknown";
  }

  Future<String> getCompleteIpAddress() async {
    return "http://" + await getPublicIpAddress() + port.toString() + "/";
  }

  Future<bool> startServer() async {
    try {
      //port = choosePort();
      server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        port,
      );
      print('Listening on localhost:${server.port}');
      ip = await getPublicIpAddress();
      await for (HttpRequest request in server) {
        if (request.method == "GET") {
          HttpResponse response = request.response;

          if (request.uri.queryParameters['check'] != null) {
            //PEER IS CHECKING FOR CONNECTION
            response
              ..write('true')
              ..close();
          }
          if (request.uri.queryParameters['key'] != null) {
            //RECEIVED KEY PARAMETERS FROM PEER
            if (client.symmetricKey.length != 64) {
              BigInt receivedPublicKey =
                  BigInt.parse(request.uri.queryParameters['key']);
              BigInt symmetricKey = secp256k1EllipticCurve.generateSymmetricKey(
                  BigInt.parse(client.privateKey), receivedPublicKey);
              String hashedSymmetricKey = sha256
                  .convert(utf8.encode(symmetricKey.toString()))
                  .toString();
              client.symmetricKey = hashedSymmetricKey;
            }
            response
              ..write('true')
              ..close();
          }
          if (request.uri.queryParameters['msg'] != null) {
            //RECEIVE MESSAGE FROM PEER
            String decryptedMessage = json.encode(await cryptor.decrypt(
                request.uri.queryParameters['msg'], client.symmetricKey));
            //SAVE MESSAGE TO DATABASE
            response
              ..write('true')
              ..close();
          }
        }
      }
    } catch (err) {
      print(err);
      return false;
    }
    return true;
  }
}