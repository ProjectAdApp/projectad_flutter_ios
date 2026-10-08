import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UserCollision, Unknown }

class AuthAnalysis{
  
  String email,pass;
  bool registering;

  

  AuthAnalysis(this.registering, { this.email,  this.pass });

  Future<int> load() async{
    
    _AuthTimeController timeController = _AuthTimeController((await SharedPreferences.getInstance()));

    print("xxkjdfk");

    if(timeController.getTimeTransit()){

      //time synced

      FirebaseAuth _auth = FirebaseAuth.instance;

      if(registering){

        try{

        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
        await buildNewUser(credential.user.uid);

        return 1;
        
        }  catch (e){


          print("this is code"+e.code);
        

          switch(e.code){

            case 'email-already-in-use':return -1;
            case 'network-request-failed':return -2;

          }

          return 0;

        }


      }else{
        try{

        UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: pass);

        return 1;
        
        }  catch (e){


          print("this is code"+e.code);
        

          switch(e.code){

            case 'user-not-found':return -4;
            case 'network-request-failed':return -2;
            case 'wrong-password':return -3;


          }

          return 0;

        }
      }

    }else{
      return 3;
    }

  }


  Future<void> buildNewUser(String uid) async{

    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(uid);
    
     reference.child("B1").set("?--?");
     
     reference.child("D1").set("0?"+DateTime.now().millisecondsSinceEpoch.toString());
     reference.child("UN").set(DateTime.now().millisecondsSinceEpoch.toString());
    await  reference.child("F").set(DateTime.now().millisecondsSinceEpoch.toString()+"#0!0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0+M");
    

  }
}

class AuthResult{

  int result;

  String errkey;

  AuthResult(this.result, {this.errkey});


  //result status

  static final error = 0;
  static final success = 1;


  

}

class _AuthTimeController{

  SharedPreferences sharedPreferences;

  final key = "AuthTime";
  final key2 = "AuthTry";
  final losttime = 300000;

  _AuthTimeController(this.sharedPreferences);

  bool getTimeTransit(){

    print("sdfhksjd");

    List<int> times = new List(5);

    times[0] = sharedPreferences.getInt(key+"0");

    times[1] = sharedPreferences.getInt(key+"1");

    times[2] = sharedPreferences.getInt(key+"2");
    times[3] = sharedPreferences.getInt(key+"3");

    times[4] = sharedPreferences.getInt(key+"4");

    bool medium = false;


    print("error");
    for (var i = 0; i < times.length; i++) {
      print(times[i]);

      if(times[i]==null)times[i]=0;

      if(times[i]==0 && !medium){
        sharedPreferences.setInt(key+i.toString(), currentTime());
        medium=true;
      }else{
        if(times[i]+losttime<currentTime() && times[i]!=0){
          //reset
          sharedPreferences.setInt(key+i.toString(), 0);
          if(!medium){
            sharedPreferences.setInt(key+i.toString(), currentTime());
            medium=true;
          }else{
            sharedPreferences.setInt(key+i.toString(), 0);
          }
        }
      }
      print("error2");
    }

    return medium;
  }

  int currentTime(){
    return DateTime.now().millisecondsSinceEpoch;
  }




}