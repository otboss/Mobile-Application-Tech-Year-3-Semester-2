import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import './main.dart';

class Client {
  final jsonEncoder = JsonEncoder();
  String privateKey = "";
  String symmetricKey = "";

  Client() {
    privateKey = secp256k1EllipticCurve.generatePrivateKey().toString();
    databaseManager.getCurrentUserInfo();
  }

  Future<Map> checkConnection(String ipAddress) async {
    Response response;
    try {
      response =  await dio.get(ipAddress + "?check=1");
      return json.decode(response.data);
    } catch (err) {
      print(err);
    }
  }

  Future<bool> sendMessage(String ipAddress, String message) async {
    try {
      message = jsonEncoder.convert(message);
      String encryptedMessage = await cryptor.encrypt(message, symmetricKey);
      await dio.get(ipAddress + "?msg=" + encryptedMessage);
    } catch (err) {
      return false;
    }
    return true;
  }

  Future<bool> sendPublicKey(String ipAddress) async {
    try {
      String encodedSymmetricKey = secp256k1EllipticCurve
          .generatePublicKey(BigInt.parse(privateKey))
          .toString();
      await dio.get(ipAddress + "?key=" + encodedSymmetricKey);
    } catch (err) {
      return false;
    }
    return true;
  }

  Future<Map> getPeerInfo(String ipAddress) async{
    if(peerUsername == ""){
      Response response;
      try {
        response = await dio.get(ipAddress + "?info=1");
      } catch (err) {
        return null;
      }
      peerUsername = json.decode(response.data["username"]);
      peerProfilePic = json.decode(response.data["username"]);
      return response.data;
    }
    else
      return {
        "username": peerUsername,
        "profilePic": peerProfilePic
      };
  }

  List<Widget> receivedMessages = [
    //sentMessageWidget("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
    //receivedMessageWidget("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
  ];
}
