import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_insta/flutter_insta.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projectad/env.dart';
import 'package:projectad/home.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/visual/instagramb.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InstagramHandler{

  // ignore: non_constant_identifier_names
  static final INSTAGRAM_ERROR_ALREADY_FOLLOWED = -312; 
  // ignore: non_constant_identifier_names
  static final INSTAGRAM_ERROR_ALREADY_GIVEN = -313; 
  // ignore: non_constant_identifier_names
  static final INSTAGRAM_ERROR_USER_NOT_EXSITS = -314; 

  
  Future<int> buildInstagramFollowRequest(String uuid, String username) async{
    /*
    1. check if the username is already registered in the cloud (firestore)
    2. if not -> upload new username and timestamp on database and update firestore


    */



    FlutterInsta fi = FlutterInsta();
    print(fi);

    //get current sessionId 

    String sessionId;

    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey("sessionIdInstagram")){
      sessionId = pref.getString("sessionIdInstagram");
    }else{
      //download from firebase
      DataSnapshot snap = await  FirebaseDatabase.instance.reference().child("sessionId").once();
      sessionId = snap.value;
      pref.setString("sessionIdInstagram", sessionId);
    }


    bool cf = false;
    try{
      await fi.getProfileData(username, sessionId);
    }catch(e){
      //e != null if the session id is outdated
      //call heroku server to receive a new sessionid

      cf = true;

      print("worked");

      Fluttertoast.showToast(msg: "Sending to Server", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP);

      Future.delayed(
        Duration(seconds: 1)
      ).then((value){
              Fluttertoast.showToast(msg: "Wake up Server", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP);
              Future.delayed(
        Duration(seconds: 7)
      ).then((value){
              Fluttertoast.showToast(msg: "Login to Instagram", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP);
              Future.delayed(
        Duration(seconds: 5)
      ).then((value){
              Fluttertoast.showToast(msg: "Catch Cookies", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP);
              Future.delayed(
        Duration(seconds: 1)
      ).then((value){
              Fluttertoast.showToast(msg: "Send to Database", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP);
      } 

      );
      } 

      );
      } 

      );
      } 

      );

      var res = await http.post(Uri.parse(Env.sessionServerUrl), body: jsonEncode({
        "a":Env.sessionServerTokenA,
        "b":Env.sessionServerTokenB,
        "c":Env.sessionServerTokenC
      }), headers: {
        "content-type":"application/json"
      });

      print(res.body);

      //finished

      DataSnapshot snap = await FirebaseDatabase.instance.reference().child("sessionId").once();
      sessionId = snap.value;
      pref.setString("sessionIdInstagram", sessionId);
      

        

      return buildInstagramFollowRequest(uuid,username);
    }

    print("hello?");

    if(!cf){

    

    
    if(fi.url!=null){

    if( !( await FirebaseFirestore.instance.collection("instagram").doc(username).get()).exists){

      DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(uuid).child("INS");

      if((await reference.once()).value==null){
        //no ig user is registered for uuid

        //build INS

        await reference.set("n:"+username+"&s:"+DateTime.now().millisecondsSinceEpoch.toString()+"c:0");

        /*Map<String,dynamic> x = Map();
        x["obj"]=false;

        await FirebaseFirestore.instance.collection("instagram").doc(username).set(x);
        */
        return 0;

      }else{
        return INSTAGRAM_ERROR_ALREADY_GIVEN;
      }


    }else{
      return INSTAGRAM_ERROR_ALREADY_FOLLOWED;
    }

  }else{
    return INSTAGRAM_ERROR_USER_NOT_EXSITS;
  }
    }
  }

  Future<int> checkInstagramState(String uuid) async{
    /*
    checking the state by getting INS data
    this method should be called after resolving the state request


    */

    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(uuid).child("INS");
    var v = await reference.once();
    if(v.value==null){
      //instagram data is zero
      //what means that the data have changed, you unfollowed us

      //you can follow us...

      return 1;
    }else{
      return INSTAGRAM_ERROR_ALREADY_FOLLOWED;
    }


  }

  void updateUpdateTime()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt("lastinstagramupdatetime", DateTime.now().millisecondsSinceEpoch);
  } 

  Future<int> checkInstagramRequestFilled(String uuid, HomeState wrapper) async{
    /**
     * this method checks if you followed us
     * but when do you call it?
     * - you call this method: 10 min after reuqest was built; then each hour
     */

    //checking

    String s = (await FirebaseDatabase.instance.reference().child("Users").child(uuid).child("INS").once()).value;

    if(s==null){
      //there is no request any more
      updateUpdateTime();
      return -1;
    }else{

       String username = s.substring(s.indexOf("n:")+2, s.indexOf("&"));
      print("username:"+username);
      print(s);

      if(s.endsWith("c:0")){

        //check if followed yet


      //check if sub

    
      List<String >followers = await wrapper.getInstagramFollowers(username);
      print(followers);
      print("hello?");
      if(followers.contains(username)){
        //you followed us

        //huhu

        //update ins data

        String data$s = s.substring(0, s.length-1)+DateTime.now().millisecondsSinceEpoch.toString();

        handleCopyOnEarth(data$s);

        FirebaseDatabase.instance.reference().child("Users").child(uuid).child("INS").set(data$s);

        //write to firestore

        Fluttertoast.showToast(msg: AppLocalizations.of(wrapper.context).translateKey("s157_"),toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.SNACKBAR);

        Map<String,dynamic> x = Map();
        x["obj"]=false;
updateUpdateTime();
        await FirebaseFirestore.instance.collection("instagram").doc(username).set(x);
        return 1;
        
      }else{

        
updateUpdateTime();
        return -1;
        //you dont followed us
      }
      }else{
        //check if unfollowed yet

        
        List<String >followers = await wrapper.getInstagramFollowers(username);

        if(!followers.contains(username)){
          //sign out and keep down ---

          FirebaseDatabase.instance.reference().child("Users").child(uuid).child("INS").remove();
          handleCopyOnEarth(null);
updateUpdateTime();
          await FirebaseFirestore.instance.collection("instagram").doc(username).delete();

          return -99;

        }else{
          updateUpdateTime();
          return -1;
        }
      }

    }
  }

  String startinstagramrequest = "";

  Future<void> handleCopyOnEarth(String s) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("instagramdatapack", startinstagramrequest);
  }
  Future<String> getCopyFromEarth()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("instagramdatapack");
  }

  Future<bool> requestFilledIsAvailable(String uuid)async{

    

    String sg = (await getCopyFromEarth());

    //download data
    if(sg==null || sg == ""){
      //handle data (set)

      sg = (await FirebaseDatabase.instance.reference().child("Users").child(uuid).child("INS").once()).value;

      await handleCopyOnEarth(sg);
    }


    if(sg==null || sg == "")return false;

    

    if(sg.endsWith("c:0")){
String sg2 = sg.substring(sg.indexOf("&s:"));
    String time = sg2.substring(sg2.indexOf("&s:")+3, sg2.indexOf("c:"));

    int time$int = int.parse(time);

    SharedPreferences sp = await SharedPreferences.getInstance();

    int lastupdatetime = sp.getInt("lastinstagramupdatetime");
    if(lastupdatetime==null)lastupdatetime=0;

    if(DateTime.now().millisecondsSinceEpoch-7200000>lastupdatetime){
      //update
      return true;
    }

    return false;
    }else{
String sg2 = sg.substring(sg.indexOf("&s:"));
    String time = sg2.substring(sg2.indexOf("&s:")+3, sg2.indexOf("c:"));

    int time$int = int.parse(time);

    SharedPreferences sp = await SharedPreferences.getInstance();

    int lastupdatetime = sp.getInt("lastinstagramupdatetime");

    if(lastupdatetime==0 && time$int+600000<DateTime.now().millisecondsSinceEpoch){
      //update
      return true;
    }

    if(lastupdatetime == null || DateTime.now().millisecondsSinceEpoch-3600000>lastupdatetime ){
      //update
      return true;
    }

    return false;
    }

    

  }

} 