
import 'package:flutter/material.dart';
import 'package:projectad/algo/space.dart';
import 'package:projectad/service/varhandlerx.dart';
import 'package:projectad/visual/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectad/main.dart' as main;

class Hws{

  Vhx v;

  Hws(BuildContext context, int i){
    this.v = new Vhx(null,null);
  
    Size s = MediaQuery.of(context).size;
    this.v.supportMultiple(true);
    this.v.setMultiple(s.width, "0");
    this.v.setMultiple(s.height, "1");
    print(v.toString()+"$i");
  }

  Style currentstyle;
  List<List<Color>> list_dark;
  List<List<Color>> list_light;

  List<List<Color>> choose(bool dark){
    return dark?list_dark:list_light;
  }

  Future<void> loadStyle(int paragraph) async{
    if(currentstyle!=null && paragraph==0)return;
    SharedPreferences sp = await SharedPreferences.getInstance();
    currentstyle = Style.fromId(sp.getInt("style_id"));
    if(currentstyle==null){
      currentstyle = Style.generateRandom();
     

      sp.setInt("style_id", currentstyle.id);

    }
    list_dark = currentstyle.colors_dark;
    list_light= currentstyle.colors_light;
  }

  double getWidth(){
    print("first $v +");
    return v.getFromMultiple("0") as double;
  }
  double getWidth2(int i){
    print("first $v +$i");
    return v.getFromMultiple("0") as double;
  }

  double getHeight(){
    
    return v.getFromMultiple("1") as double;
  }

  double getTH(){

    return getHeight()/1200;

  }

  WideSpaceResolver resolver;

  setResolver(WideSpaceResolver _resolver){
    resolver=_resolver;
  } 
  

  qualy(Hws hw){

  }


  
}

get mainIntentCollectionService {
  return main.ics;
}

class IntentCollectionService {
  
  String activityName = "main.dart";

  IntentCollectionService({this.activityName});
}

enum QuoteState {
  /*
   * LOADED is when the quote is new generated or copied from cloud
   */
  LOADED,
  /*
   * SOLVE is when the quote is in solving mode
   */
  SOLVE,
  /*
   * SOLVED is when the quote was solved, can also be found when a solved quote was LOADED
   */
  SOLVED
}

class HomeCollection extends IntentCollectionService {


  //state detect

  bool welcomed = true;
  bool showingAdInfo = false;
  bool quoteLoaded = false;
  bool quotePointsLoaded = false;

  QuoteState quoteState;

  //state input

  String quotePointData = "";
  String quoteData = "";

  
  

  HomeCollection(){
    this.activityName = "home.dart";

  }

  swelcomeFinished(){
    this.welcomed = false;
  }

  adInfo(){
    this.showingAdInfo = true;
  }

  dismissAdInfo(){
    this.showingAdInfo = false;
  }

  loadQuoteFinished(){
    this.quoteLoaded = true;
  }

  quotePointsLoadedFinished() {
    this.quotePointsLoaded = true;
  }

  changeQuoteState(QuoteState qs){
    
    if(onChange != null)onChange.call(qs, quoteState);
    this.quoteState = qs;
  }

  Function onChange;

  addQuoteStateListener(Function(QuoteState,QuoteState) onChange){
    this.onChange = onChange;
  }



  

}