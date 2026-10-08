import 'dart:math';

import 'package:flutter/material.dart';

class Style{

  List<List<Color>> colors_light;
  List<List<Color>> colors_dark;

  List<Color> lightTransGradient;
  List<Color> darkTransGradient;

  int id;

  List<List<Color>> getListLight(){
    print("getListLight");
    return getListDark0();
  }

  List<List<Color>> getListDark0(){
    return List.from(colors_dark.reversed);
  }
  List<List<Color>> getListLight0(){
    return List.from(colors_light.reversed);
  }
  List<List<Color>> getListDark(){
    print("getListDark");
    return getListLight0();
  }

  List<Color> getRealColorLight(){
    print("4");
    return {getListLight0()[4][0],getListLight0()[4][0]}.toList();
  }

  List<Color> getRealColorDark(){
    return {getListDark0()[3][0],getListDark0()[3][0]}.toList();
  }




  Style({this.colors_light, this.colors_dark, this.id, this.lightTransGradient, this.darkTransGradient});

  static final Style green = Style(
    id: 701,
    lightTransGradient: [Colors.teal[800],Colors.teal[300]],
    darkTransGradient: [Colors.greenAccent[700],Colors.teal[900]],
    colors_light: [[Colors.greenAccent[700], Colors.lightGreenAccent[700]],[Colors.greenAccent[400], Colors.lightGreenAccent[400]],[Colors.green,Colors.lightGreen],[Colors.lightGreenAccent[400], Colors.greenAccent[100]], [Colors.lightGreenAccent, Colors.greenAccent]],
    colors_dark: [[Colors.green[900], Colors.teal[900]],[Colors.green[700],Colors.tealAccent[700]],[Colors.lightGreen[600], Colors.limeAccent[700]],[Colors.lime[600], Colors.lime[800]]]);
  

  static final Style red = Style(
    id: 401,
    lightTransGradient: [Colors.deepOrange,Colors.orangeAccent],
    darkTransGradient: [Colors.deepOrange[900],Colors.pink[900]],
    colors_light: [[Colors.redAccent[400],Colors.deepOrange],[Colors.red,Colors.redAccent],[Colors.deepOrangeAccent[700],Colors.pink[800]],[Colors.deepOrange,Colors.redAccent[400]], [Colors.pinkAccent[400],Colors.pink[600]]],
    colors_dark: [[Colors.red[900],Colors.redAccent[700]],[Colors.red[700],Colors.red[800]],[Colors.pink[900],Colors.pink[800]],[Colors.deepOrange[900],Colors.deepOrangeAccent[700]]]);

  static final Style blue = Style(
    id: 702,
    lightTransGradient: [Colors.lightBlue[600],Colors.pink[300]],
    darkTransGradient: [Colors.blueGrey[800],Colors.cyan[900]],
    colors_light: [[Colors.blueAccent[700], Colors.lightBlueAccent[700]],[Colors.blueAccent,Colors.blue], [Colors.lightBlue[200], Colors.cyan[600]],[Colors.lightBlueAccent[400], Colors.cyanAccent], [Colors.lightBlueAccent, Colors.blueAccent]],
    colors_dark: [[Colors.blue[900], Colors.indigo[900]],[Colors.blueAccent[700],Colors.indigo[700]],[Colors.lightBlue[600], Colors.blueGrey],[Colors.indigo[600], Colors.deepPurple[900]]]);

  static final Style yellow = Style(
    id: 703,
    lightTransGradient: [Colors.red[300],Colors.yellow[900]],  
    darkTransGradient: [Colors.red[800],Colors.deepOrangeAccent[400]],
    colors_light: [[Colors.yellowAccent[400],Colors.amber[300]],[Colors.amberAccent[400],Colors.amber[600]],[Colors.yellow,Colors.yellowAccent[400]],[Colors.amber,Colors.yellowAccent[700]], [Colors.limeAccent,Colors.amberAccent[700]]],
    colors_dark: [[Colors.yellow[900],Colors.yellowAccent[700]],[Colors.yellow[700],Colors.yellow[800]],[Colors.amber[900],Colors.amberAccent[700]],[Colors.lime[900],Colors.orange[800]]]);

  

  static Style fromId(int id){
    print("new id"+id.toString());
    switch (id) {
      case 701:
        return green;
      case 702:
        return blue;  
      case 703:
        return yellow;
      case 401:
        return red;     
      default:return null;

    }
  }
  static Style generateRandom(){
     final List<int> ids = [701,401,702,703];
     Random r = new Random();
     return fromId(ids[r.nextInt(ids.length)]);
  }

}