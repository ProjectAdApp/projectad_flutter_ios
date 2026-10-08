import 'package:flutter/material.dart';
import 'package:projectad/service/varhandlerx.dart';

class IntentX{
  Vhx varhandler;

  IntentX(){
    varhandler = new Vhx(null, false);
    varhandler.supportMultiple(true);
    namelist=List();
  }

  List<String> namelist;

  addParameter(String name, var obj){

    if(namelist.contains(name))throw new FlutterError("Name already exsits!");

    namelist.add(name);

    varhandler.setMultiple(obj, name);
  }

  dynamic getValue(String name){
    return varhandler.getFromMultiple(name);
  }

}
