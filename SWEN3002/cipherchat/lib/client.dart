import 'dart:convert';
import './main.dart';


class Client{
  final jsonEncoder = JsonEncoder();
  String privateKey = "";
  String symmetricKey = "";

  Client(){
    privateKey = secp256k1EllipticCurve.generatePrivateKey().toString();
  }

  Future<bool> connectToPeer(String ipAddress) async{
    try{
      await dio.get(ipAddress+"?check=1");
    }
    catch(err){
      return false;
    }
    return true;
  }

  Future<bool> sendMessage(String ipAddress, String message) async{
    try{
      message = jsonEncoder.convert(message);
      String  encryptedMessage = await cryptor.encrypt(message, symmetricKey);
      await dio.get(ipAddress+"?msg="+encryptedMessage);
    }
    catch(err){
      return false;
    }
    return true;
  }
  
  Future<bool> sendSymmetricKey(String ipAddress, String message) async{
    try{
      String encodedSymmetricKey = secp256k1EllipticCurve.generatePublicKey(BigInt.parse(privateKey)).toString();
      await dio.get(ipAddress+"?key="+encodedSymmetricKey);
    }
    catch(err){
      return false;
    }
    return true;
  }
}