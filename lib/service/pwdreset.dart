import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'file_adapt.dart';

class PWDReset{

  String email;

  PWDReset({this.email});

  Future<int> reset() async{

try{
    void v = await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return 1;
}catch (x){
  print(x.code);
  if(x.code == "internal-error")return -1;
  return 0;

} 

  }

}