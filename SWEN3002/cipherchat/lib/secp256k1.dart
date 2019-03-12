

import 'package:flutter/services.dart';
import './main.dart';

///Implementation of the secp256k1 elliptic curve. 
///The graph's parameters are provided by http://www.secg.org/SEC2-Ver-1.0.pdf
///section 2.7.1
class Secp256k1{
    BigInt g = BigInt.parse("02 79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798"
    .split(" ")
    .join(""), 
    radix: 16);
  
  BigInt p = BigInt.parse("FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F"
    .split(" ")
    .join(""), 
    radix: 16);

  BigInt n = BigInt.parse("FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141"
    .split(" ")
    .join(""), 
    radix: 16);

  BigInt h = BigInt.parse("01"
    .split(" ")
    .join(""), 
    radix: 16);

  BigInt a = BigInt.parse("00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"
    .split(" ")
    .join(""), 
    radix: 16);

  BigInt b = BigInt.parse("00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000007"
    .split(" ")
    .join(""), 
    radix: 16);

  Future<BigInt> generatePrivateKey() async{
    try{
      String privateKeyJsCode = await rootBundle.loadString('assets/privateKeyGenerator.js');
      await flutterWebviewPlugin.launch("");
      String privateKey = await flutterWebviewPlugin.evalJavascript(privateKeyJsCode);
      privateKey = privateKey.split('"').join("");
      await flutterWebviewPlugin.close();
      return BigInt.parse(privateKey);
    }
    catch(err){
      print("an error occurred while generating the private key: ");
      print(err);
    }
    return null;
  }

  BigInt generatePublicKey(BigInt privateKey) {
    return privateKey*g;
  }
  
}