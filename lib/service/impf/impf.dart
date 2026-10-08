import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectad/service/file_adapt.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Impf{

  Impf();

    String vn="26";//min version

    Future<List<String>> start(BuildContext _c) async{


    FirebaseAuth _auth = FirebaseAuth.instance;

    String filename = json.decode(await FileAdapter().readAsset("srcs", "keys.json"))["source_file_name"];


    print("user ${_auth.currentUser}");

    if(_auth.currentUser==null){  

  
      return ["403",filename];


    }else{

      String src = await FileAdapter().readFile(filename);

      if(src=="404"){

        return [AppLocalizations.of(_c).translateText("Refreshing"),filename,"-1"];
      }else{
        
       return handleVersion(_c,filename);
      }
    }
  }


  Future<List<String>> handleVersion(BuildContext _c, String filename) async {
    if(await checkVersion()){

          //no update needed

          return ["",filename];

        }else{

          //forcing update now

          return [AppLocalizations.of(_c).translateText("Refreshing"),filename,vn];

        }
  }
  Future<bool> checkVersion() async{
    vn = (await FirebaseDatabase.instance.reference().child("vn").once()).value;
    return vn==(await SharedPreferences.getInstance()).getString("dv");
  }

}

class ImpfService {

  String filename;

  ImpfService(this.filename);

  int repos = 0;

  Future<String> downloadFile(BuildContext _c, String vn) async {

    if(vn!="-1"){

          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("dv", vn);


          final Directory systemTempDir = await getApplicationDocumentsDirectory();
           File file = new File('${systemTempDir.path}/$filename');
           file = await file.writeAsString("updateing");
          
          StorageTaskSnapshot snapshot = await FirebaseStorage.instance
              .ref().child("fire/Note.txt")
              .putFile(file).onComplete;
          if (snapshot.error == null) {
            print("success");
            return "";
          }else{
            print(snapshot.error);
            if(repos>1){
              return AppLocalizations.of(_c).translateText("Please try later again");
            }
            else repos++;
            Future.delayed(Duration(milliseconds: 100)).then((value) => downloadFile);
          }
    }else{
      vn = (await FirebaseDatabase.instance.reference().child("vn").once()).value;
      downloadFile(_c, vn);
    }
            
  }


}