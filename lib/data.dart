import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectad/algo/space.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as Im;


class CloudCombinatorix {

  static final path0 = "Users";
  static final path1 = "usd";
  static final var0 = "Ask";
  static final var1 = "Con";
  static final var2 = "UN";

  static final sourceControl1 = "cc1";


  static Future<String> loadUNData() async {
    if(FirebaseAuth.instance.currentUser==null)return null;
    var snap = await FirebaseDatabase.instance.reference().child(path0).child(FirebaseAuth.instance.currentUser.uid).child(var2).once();
    return snap.value is int ? (snap.value as int).toString() : snap.value;
  }

  /// THE UN-Data Value: 
  /// is a jsonList containing mulitple elements (6)
  /// [ num, String, String, num, bool, String]
  /// [color, username, name, create_time, hasProfilePicture, privacy]
  /// 
  /// privacy = "M" (all), "R" (firends only), other (nobody)
  ///
  static List<dynamic> getUNDatas(String un_data){
    if(un_data == null)return [];
    if(num.tryParse(un_data) != null)return [num.parse(un_data)];
    else{

      //check user system 
      
      if(un_data.substring(un_data.length-2,un_data.length-1) == "*" /*old separator*/){

        //old
        
        String color = un_data.substring(0, un_data.indexOf("?"));
        int _color = num.parse(color);

        un_data = un_data.substring(un_data.indexOf("?")+1);

        String user_name = un_data.substring(0, un_data.indexOf("/"));

        un_data = un_data.substring(un_data.indexOf("/")+1);

        String nname = un_data.substring(0, un_data.indexOf(","));

        un_data = un_data.substring(un_data.indexOf(",")+1);

        String timec = un_data.substring(0, un_data.indexOf("+"));
        int _timec = num.parse(timec);

        un_data = un_data.substring(un_data.indexOf("+")+1);

        String pic = un_data.substring(0, un_data.indexOf("*"));
        bool _pic = pic == "true";

        un_data = un_data.substring(un_data.indexOf("*")+1);

        String privacy = un_data;

        return [_color, user_name, nname,_timec,_pic, privacy];

      }else{
        
        List<String> datas = un_data.split(",");

        List d = [];
        for(String s in datas){
          d.add(s);
        }

        d[4] = datas[4]=="true"?true:false;

        return d;

        

        

        //return jsonDecode(un_data);

      }

    }
  }

  ///loading the base from Cloud Firestore
  ///base is a two sized string
  ///-> [child] 'base[0]' -> [child] 'base[1]' -> receiveList with usernames of the base
  ///  
  /// returning a list of usernames of the base
  static Future<UsernameDataSet> loadFirestoreBase(String base) async{

    String s1 = base[0];
    String s2 = base[1];

    

    DocumentSnapshot sp = await FirebaseFirestore.instance.doc("/usd/"+s1).get();
    
    String jsonString = await sp.get(s2);

    return UsernameDataSet(jsonString, base);
  }



}

class UsernameDataSet {



  List<dynamic> sList;
  String base;

 

  UsernameDataSet( String sList, this.base, {String username, String nname, String bio, bool hasPb, String privacy, String time0}){
    
    if(username != null){

      this.sList = List.empty(growable: true);
      this.sList.add(username);
      this.sList.add(nname);
      this.sList.add(bio);
      this.sList.add(hasPb);
      this.sList.add(privacy);
      this.sList.add(time0);

      return;
    }
    
    sList = sList.replaceAll(",", "\",\"");
    sList = "[\""+sList.substring(1, sList.length-1) +"\"]";
    this.sList = jsonDecode(sList);
  }

  @override
  String toString() {
    return "[\""+jsonEncode(sList).substring(1,jsonEncode(sList).length-1)+"\"]";
  }

}

class Suggestions {

  String base;

  Suggestions(this.base);

  final suffixes = ["123","333","666","999","321","_","__","___","31","gg","04","03","02","01","00","100","_bb8","_star_wars_fan","_football_fan","_lol","__blm__","__fff__","__who__"];

  //final patterns: (1) check _ in every place, (4) random 4 digit number at the end, (4) random 4 digit number at start

  List<String> getSuggestions(){

    //loading prefixes
    //
    
   

    List<String> sl = [];


    for(var suf in suffixes){
      sl.add(base+suf);
    }

    Random ran = new Random();
    
    for (var i = 0; i < 4; i++) {
      sl.add(base+"_"+ran.nextInt(9999).toString());
    }

    for (var i = 0; i < 4; i++) {
      sl.add(ran.nextInt(9999).toString()+"_"+base);
    }
    



    return shuffle(sl);
    

  }

  

}

List shuffle(List l) {
  var random = new Random();

  // Go through all elements.
  for (var i = l.length - 1; i > 0; i--) {

    // Pick a pseudorandom number according to the list length
    var n = random.nextInt(i + 1);

    var temp = l[i];
    l[i] = l[n];
    l[n] = temp;
  }

  return l;
}

class CreatorDataPack {

  String user_name;//30
  String nname;//30
  String biography;//120
  String profilePicPath;
  String cat_V;
  String timeUpdate;

  void addUserName(String un){
    this.user_name = un;
  }

  void addName(String nn){
    this.nname = nn;
  }

  void addBio(String bio){
    this.biography = bio;
  }

  void addPath(String path){
    this.profilePicPath = path;
  }

  void addTags(String tags){
    this.cat_V = tags;
  }

  void addTime(String time){
    this.timeUpdate = time;
  }

  

  @override
  String toString() {
    List l = ["0",user_name,nname,"",false,"M", timeUpdate];

    return jsonEncode(
      
      l

    );

  }

  List<dynamic> toList(){

    return ["0",user_name,nname,"",false,"M", timeUpdate];

  }

  String safe(){
    return toString().replaceAll("\"", "");
  }

}

class TagHandler {

  //loading tags
  ///s -> String containing tags
  TagHandler() {

    load();


  }

  static String getTagStringFromList(List<Tag> tags){
    String tagString = "";
    tags.forEach((element) {
      tagString = tagString + element.tD;
    });
    return tagString;
  }

  

  static Tag default$(BuildContext context){
    String s =  AppLocalizations.of(context).translateKey("s171_");
    return Tag(tD: "",de: s, en: s, fr: s, condition: null, f: "", default$: true);
  }
  static Tag dummy(){
    return Tag(tD: "",de: "", en: "", fr: "", condition: null, f: "", default$: true);
  }

  List<Tag> loadTags(String s){
    if( s == "0")return [];
    List<Tag> tags = [];
    for (String c in s.characters){
      tags$.forEach((element) {
        if(element.tD == c){
          tags.add(element);
        }
      });
    }
    return tags;
  }

  List<Tag> tags$ = []; 

  Future<void> load() async{
    String tags = await rootBundle.loadString('lang/tags.json');
    Map<String, dynamic> m = jsonDecode(tags);


    final String ab = "ABCDEFGHIJKLMNO";
    for (var i = 0; i < 14; i++) {
      Map m2 = m[ab[i].toString()];
      Tag t;
      if(m2.containsKey("text"))t = Tag(tD: ab[i].toString(), condition: m2["c"], de: m2["text"], en: m2["text"], fr: m2["text"], f: ab[i].toString());
      else t = Tag(tD: ab[i].toString(), condition: m2["c"], en: m2["en"], fr: m2["fr"], de: m2["de"], f: ab[i].toString());

      this.tags$.add(t);
    }


  }

  List<Tag> getStandardTags({List<Tag> yourTags}){

    if(tags$ == null || tags$.length == 0)return null;

    //5 to 10
    


    List<Tag> t =  tags$.getRange(4, 10).toList();
    if(yourTags != null){
      List<Tag> remove = [];
      for(Tag tag in t){
        bool tr = false;
        for(Tag t1 in yourTags){
          if(t1 == tag){
            tr = true;
            break;
          }
        }
        if(tr){
          remove.add(tag);
        }
      }
      remove.forEach((element) {
        t.remove(element);
      });
    }
    return t;



  }

  List<Tag> getSpecialTags({List<Tag> yourTags}){

    if(tags$ == null || tags$.length == 0)return null;

    //5 to 10
    print("tags range:"+tags$.length.toString());
    List<Tag> tags = tags$.getRange(0, 4).toList();
    tags.addAll(tags$.getRange(10,14 ).toList());
    print("tags range:"+tags.length.toString());
    
    if(yourTags != null){
      List<Tag> remove = [];
      for(Tag tag in tags){
        bool tr = false;
        for(Tag t1 in yourTags){
          if(t1 == tag){
            tr = true;
            break;
          }
        }
        if(tr){
          remove.add(tag);
        }
      }
      remove.forEach((element) {
        tags.remove(element);
      });
    }
    return tags;



  }

  List<Tag> checkTags(CompleteUserPack cup){
    List<Tag> currentTags = [];
    for(Tag t in tags$){

      if(t.conidition(cup))currentTags.add(t);
    }

    return currentTags;
  }

  void addTag(Tag t){
    tags$.add(t);
  }

  Future<void> updateTags$(List<Tag> tags, UsernameDataSet uds){

    String sb = "";
    List<Tag> used = [];
    for(Tag t in tags){
      if(used.contains(t))continue;
      used.add(t);
      sb += t.f;
    }

    uds.sList[0] = sb;

    String val = "";
    for(dynamic d in uds.sList){

      val += d.toString();

    }

    val = "["+val.substring(0, val.length-1)+"]";

    return FirebaseDatabase.instance.reference().child("Users/"+FirebaseAuth.instance.currentUser.uid+"/B1").set(val);
  

  }
  Future<void> updateTags(List<Tag> tags, String un){

    updateTags$(tags, UsernameDataSet(un,null));

  }

}
class Tag {
  String de, en, fr;
  String f;
  String condition;

  String tD;

  bool operator ==(Object o){
    if(o is Tag){
      return o.tD == this.tD;
    }else return o == this;
  }

  String text(BuildContext context){
    String lang = Localizations.localeOf(context).languageCode;

    if(lang == "en"){

      return en;

    }else if(lang == "de"){

      return de;

    }else if(lang == "fr"){

      return fr;

    }

    return en;


  }

  String conditionText(BuildContext context, CompleteUserPack cup, bool set0){

    if(condition == null || condition == ""){
      //no cond
      return AppLocalizations.of(context).translateKey("s182_");
    }else if(condition.startsWith("-")){
      List<String> splitted = condition.split(",");
      splitted[3] = splitted[3].trim();
      
      String condition0 = splitted[3][3];
      switch(condition0){
        case "A":return AppLocalizations.of(context).translateKey("s185_") + (set0 ? (" ("+ (cup.d1.endsWith("x")? "✅": "❌") +")") : "");
        case "B":return AppLocalizations.of(context).translateKey("s186_") + (set0 ? (" ("+cup.spaceResolver.jokerusedstring+")") : "");
        case "C":return AppLocalizations.of(context).translateKey("s187_") + (set0 ? (" ("+(cup.spaceResolver.quotesolvedint*10).toString()+")") : "");
        case "D":return AppLocalizations.of(context).translateKey("s188_") + (set0 ? (" ("+intl.DateFormat.yMd( Localizations.localeOf(context).languageCode).format(cup.creationTime).toString()+")") : "");
        case "E":return AppLocalizations.of(context).translateKey("s189_") + (set0 ? (" ("+_x(cup).toString()+")") : "");

      }
    }else{
      String fs = AppLocalizations.of(context).translateKey("s184_");
      fs = fs.replaceAll("x",condition.substring(0, condition.indexOf(",")));
      return fs+ (set0 ? (" ("+ cup.qpc+"qp)"):"");
    }

  } 
  int _x(CompleteUserPack cup){
    int solved = 0;
        cup.spaceResolver.weeklist.forEach((element) {
          solved += element;
        });
        return solved;
  }
  String nameText(BuildContext context){
    if(condition == null || condition == "")return text(context);
    if(condition.startsWith("-")){
      List<String> splitted = condition.split(",");
      splitted[3] = splitted[3].trim();
      
      String condition0 = splitted[3][3];
      if(condition0 == "A"){
        return text(context).replaceAll("-", " ");
      }
      if(condition0 == "E"){
        return text(context).replaceAll("/", " ");
      } return text(context);
    }else return text(context);
  }

  bool default$ = false;

  Tag({this.tD, this.de, this.fr, this.en, this.condition, this.default$, @required this.f /**use text if unknown */});

  bool conidition(CompleteUserPack cup){

    if(condition == null){

      return true;

    }

    print(condition);
    if(num.tryParse(condition.split(",")[0])!=null && num.tryParse(condition.split(",")[1])!=null){

      return (num.parse(cup.qpc)>=num.parse(condition.split(",")[0]));

    }else{

      List<String> splitted = condition.split(",");
      splitted[3] = splitted[3].trim();
      
      String condition0 = splitted[3][3];

      if(condition0 == "A"){

        return cup.d1.endsWith("x");

      }else if(condition0 == "B"){

        return cup.spaceResolver.jokerusedint > 333;

      }else if(condition0 == "C"){

        return cup.spaceResolver.quotesolvedint > 333;

      }else if(condition0 == "D"){

        return cup.creationTime.millisecondsSinceEpoch < 1622505600000;

      }else if(condition0 == "E"){

        int solved = 0;
        cup.spaceResolver.weeklist.forEach((element) {
          solved += element;
        });

        return solved > 30;

      }

    }
    return false;
  }


  bool hasUserChangeAbility(){

    if(condition == null)return true;

    
    if(num.tryParse(condition.split(",")[0])!=null && num.tryParse(condition.split(",")[1])!=null){

      return false;

    }else{

      return false;

    }
    
  }

}
class TagWidget extends StatefulWidget {

  Tag tag;
  Hws hws;
  Function clickFunction;
  TagWidget(this.tag, this.hws, this.clickFunction);

  _TagWidgetState state;

  void reload(){



    state.notifyReload();
  }

  @override
  _TagWidgetState createState() { state =_TagWidgetState();return state; }
}

class _TagWidgetState extends State<TagWidget> with WidgetsBindingObserver,TickerProviderStateMixin{

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
    setState(() {
      
    });
  }

  double w,h,th;

  Color backgroundColor = Colors.grey.withAlpha(180);
  Color borderColor = Colors.grey[700];
  Color textColor = Colors.white;

  Animation textSizeAnimation;
  Animation glow;
  Animation colorAnimation;
  Animation transitionAnimation,transitionAnimation1,transitionAnimation2;
  AnimationController ac,ac1,ac2;

  int index = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    if(ac != null ) ac.dispose();
    if(ac1!=null)ac1.dispose();
    if(ac2 != null)ac2.dispose();
    super.dispose();
  }

  @override 
  void initState() {
    this.w = widget.hws.getWidth();
    this.h = widget.hws.getHeight();
    this.th = widget.hws.getTH();

    
      
      

    

    // TODO: implement initState
    super.initState();
  }

  int carIndex,carIndex1,carIndex2;
  List<String> cars = [];

  void notifyReload(){
  

 if(ac != null ) ac.dispose();
    if(ac1!=null)ac1.dispose();
    if(ac2 != null)ac2.dispose();
  setState(() {
    ac = null;
    ac1 = null;
    ac2 = null;
  });

   setState(() {
     rebuild = true;
   });
   rebuild = false;
   print("back:"+backgroundColor.toString());
   

  }


  void initAnimation(){
if(widget.tag.condition == null){}else{
    if(widget.tag.conidition != null && widget.tag.condition.startsWith("-")){

      List<String> splitted = widget.tag.condition.split(",");
      String vers = splitted[3].trim();
      this.ac = AnimationController(duration: Duration(milliseconds: num.parse(splitted[2].substring(4))), vsync: this);

      print(vers);


      if(vers.endsWith("A")){

        this.backgroundColor = Colors.yellow[300];
        this.borderColor = Colors.yellow[700];

        this.textColor = backgroundColor;
        this.ac.repeat(reverse: true);

        this.textSizeAnimation = Tween( begin: 1.1,end: 1.6).animate(ac)..addListener(() {setState((){});});;

        this.index = 0;

       // this.ac.forward();
       
      }else if(vers.endsWith("B")) {

        this.backgroundColor = Colors.white;
        this.borderColor = Colors.white;

        this.ac.repeat(reverse: true);
        this.colorAnimation = RainbowColorTween([ 

          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.indigo,
          Colors.pink,
          Colors.purple


        ]).animate(ac)..addListener(() {setState((){});});;
        index = 1;

      }else if(vers.endsWith("C")){

        this.backgroundColor = Colors.blue[800];
        this.borderColor = Colors.blue[200];

    

        this.ac.repeat(reverse: true);

        this.glow = Tween(begin:  0.0, end: 3.0).animate(ac)..addListener(() {setState((){});});;

        


        index = 2;
      }else if(vers.endsWith("D")){
        this.ac.repeat(reverse: true);
         this.glow = Tween(begin:  0.0, end: 3.0).animate(ac)..addListener(() {setState((){});});
         
        this.colorAnimation = RainbowColorTween([ 

          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.indigo,
          Colors.pink,
          Colors.purple


        ]).animate(ac)..addListener(() {setState((){});});


        this.textColor = Colors.white;
        this.backgroundColor = Colors.black;
                 

        index = 3;
      }else if(vers.endsWith("E")){
        
        this.ac.repeat(reverse: false);
        //special opne
        this.transitionAnimation = Tween<double>(begin: w/30 + w/50*widget.tag.en.length, end: -5.0).animate(ac)..addListener(() {setState((){});
          if(transitionAnimation.value < -3.0){
            //end
            setState((){
              this.carIndex++;
              if(carIndex == cars.length){
                carIndex = 0;
              }
            });
          }

          

          });

          this.ac1 = AnimationController(vsync: this, duration: Duration(milliseconds: 2300));
          ac1.repeat(reverse: false);

          this.transitionAnimation1 = Tween<double>(begin: w/30 + w/50*widget.tag.en.length, end: -5.0).animate(ac1)..addListener(() {setState((){});
          if(transitionAnimation1.value < -3.0){
            //end
            setState((){
              this.carIndex1++;
              if(carIndex1 == cars.length){
                carIndex1 = 0;
              }
            });
          }
          
          

          });

          this.ac2 = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
          ac2.repeat(reverse: false);

          this.transitionAnimation2 = Tween<double>(begin: w/30 + w/50*widget.tag.en.length, end: -5.0).animate(ac2)..addListener(() {setState((){});
          if(transitionAnimation2.value < -3.0){
            //en
            setState((){
              this.carIndex2++;
              if(carIndex2 == cars.length){
                carIndex2 = 0;
              }
            });
          }
          
          

          });
        this.carIndex = 0; 
        this.carIndex1 = 2;
        this.carIndex2 = 4;   
        this. cars = widget.tag.en.split("/");
      
        index = 4;

      }
    }}
  }

  bool rebuild = false;

  @override
  Widget build(BuildContext context) {

    if(index == null || (index == 0 && textSizeAnimation == null) || rebuild)initAnimation();

    bool dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

    //if(index == 0  && textSizeAnimation == null)textSizeAnimation = Tween(begin: 1.1, end: 1.6).animate(ac);

    if(widget.tag.condition != null){

      if( widget.tag.condition.startsWith("-")){

        if(index == 4){

          

          return GestureDetector(
            onTap: widget.clickFunction,
          child: Container(
            alignment: Alignment.centerLeft,
            height: h/22,
            width:  w/30 + w/50*widget.tag.text(context).length + w/44,
            child: Container(
               alignment: Alignment.centerLeft,
          height: h/22,
          width:  w/30 + w/50*widget.tag.text(context).length,
          child: 
        Center(child: Container(
                    height: h/25,
                    width: w/30 + w/50*widget.tag.text(context).length,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: dark?Colors.grey[700]:Colors.grey.withAlpha(180),
                      border: Border.all(color: dark?Colors.grey:Colors.grey[600])

                    ),
                    child:  Stack(children:[
                      AnimatedBuilder
                    (
                        animation: transitionAnimation,
                        builder: (xa,af){return Positioned(
                        top: 0,
                        bottom: 0,
                        left: transitionAnimation.value,
                        child: Text(
                          cars[carIndex],
                          style: TextStyle(color: Colors.white, fontSize: th*19, ),
                      textAlign: TextAlign.center
                        )
                      );}),
                      AnimatedBuilder
                    (
                        animation: transitionAnimation1,
                        builder: (xa,af){return Positioned(
                        top: 0,
                        bottom: 0,
                        left: transitionAnimation1.value,
                        child: Text(
                          cars[carIndex1],
                          style: TextStyle(color: Colors.white, fontSize: th*19, ),
                      textAlign: TextAlign.center
                        )
                      );}),
                      AnimatedBuilder
                    (
                        animation: transitionAnimation2,
                        builder: (xa,af){return Positioned(
                        top: 0,
                        bottom: 0,
                        left: transitionAnimation2.value,
                        child: Text(
                          cars[carIndex2],
                          style: TextStyle(color: Colors.white, fontSize: th*19, ),
                      textAlign: TextAlign.center
                        )
                      );})
                    ] ))
                    
                  
                  
                  ))));

        }

        //special part
        //print("glow:"+glow.value);
return GestureDetector(
  onTap: widget.clickFunction,
  child: Container(
            alignment: Alignment.centerLeft,
            height: h/22,
            width:  w/30 + w/50*widget.tag.text(context).length + w/44,
            child: Container(
          height: h/22,
          width:  w/30 + w/50*widget.tag.text(context).length,
          child: 
        Center(child: Container(
                    height: h/25,
                    width: w/30 + w/50*widget.tag.text(context).length,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),

                      color: index == 1? colorAnimation.value : backgroundColor,

                      boxShadow: index == 2 || index == 3 ?[
                        BoxShadow(
                          blurRadius: glow.value,
                          spreadRadius: glow.value,
                          color: index == 2 ? Colors.blue[800] : colorAnimation.value
                        )
                      ]:[],

                      border: Border.all(color: borderColor),
                      //gradient: index == 1 ? LinearGradient(colors: [Colors.green,Colors.red,Colors.blue,Colors.yellow,Colors.pink], end: Alignment.centerRight, begin: Alignment.centerLeft) :  null ,                    


                    ),
                    child:  Center(child: index == 0 ? ScaleTransition(
                      scale: textSizeAnimation,
                      child: Text(
                      widget.tag.text(context),
                      style: TextStyle(color: textColor, fontSize: th*19 ),
                      textAlign: TextAlign.center)
                    ):(index == 1 || index == 2? Container(
                      
                      child: Text(
                      widget.tag.text(context),
                      style: TextStyle(color: Colors.white, fontSize: th*19, ),
                      textAlign: TextAlign.center))
                    :Text(
                      widget.tag.text(context),
                      style: TextStyle(color: colorAnimation.value, fontSize: th*19, ),
                      textAlign: TextAlign.center)))
                    
                  
                  
                  )))));
      
      
      }


    }

    return GestureDetector(onTap: widget.clickFunction, child: Container(
            alignment: Alignment.centerLeft,
            height: h/22,
            width:  w/30 + w/50*widget.tag.text(context).length + w/44,
            child: Container(
          height: h/22,
          width:  w/30 + w/50*widget.tag.text(context).length,
          child: 
        Center(child: Container(
                    height: h/25,
                    width: w/30 + w/50*widget.tag.text(context).length,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: dark?Colors.grey[700]:Colors.grey.withAlpha(180),
                      border: Border.all(color: dark?Colors.grey:Colors.grey[600])

                    ),
                    child:  Center(child: Text(
                      widget.tag.text(context),
                      style: TextStyle(color: Colors.white, fontSize: th*19, ),
                      textAlign: TextAlign.center,

                    )
                    
                  
                  
                  ))))));
  }
}
class CompleteUserPack {


  WideSpaceResolver spaceResolver;
  String qpc;
  
  DateTime creationTime;
  UsernameDataSet uds;

  String d1;

  CompleteUserPack({this.spaceResolver, this.qpc, this.uds, this.d1}){
    this.creationTime = FirebaseAuth.instance.currentUser.metadata.creationTime;
  }

}
class AnimatedGradient extends StatefulWidget {
  @override
  _AnimatedGradientState createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient> {
  List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.red;
  Color topColor = Colors.yellow;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 2),
          onEnd: () {
            setState(() {
              index = index + 1;
              // animate the color
              bottomColor = colorList[index % colorList.length];
              topColor = colorList[(index + 1) % colorList.length];

              //// animate the alignment
              // begin = alignmentList[index % alignmentList.length];
              // end = alignmentList[(index + 2) % alignmentList.length];
            });
          },
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, colors: [bottomColor, topColor])),
        ),
        Positioned.fill(
          child: IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                bottomColor = Colors.blue;
              });
            },
          ),
        )
      ],
    ));
  }
}

class ProfilePicManager {
  static final String fileName = "profilePic";
  static final String lastUpdate = "lastUpdate0";

  Future<File> loadbyHard(String s) async{


    File f0 = File((await getApplicationDocumentsDirectory()).path +"/"+fileName+s);

    StorageFileDownloadTask sdt = FirebaseStorage.instance.ref().child("profs/"+FirebaseAuth.instance.currentUser.uid+".jpg").writeToFile(f0);
    var v = await sdt.future;
    
    return (f0);

  }

  Future<File> loadbyHard2(String uid) async{


    File f0 = File((await getApplicationDocumentsDirectory()).path +"/"+fileName+uid);

    StorageFileDownloadTask sdt = FirebaseStorage.instance.ref().child("profs/"+uid+".jpg").writeToFile(f0);
    var v = await sdt.future;
    
    return (f0);

  }

  Future<File> loadPic(String time0) async{
SharedPreferences sp = await SharedPreferences.getInstance();
String time = sp.getString(lastUpdate);
print("loadPic with "+time+"/"+time0);
if(time == null || time != time0){

  //load file by hard

  File img = await loadbyHard(sp.getString(objS));
  
  final File hard = await img.copy((await getApplicationDocumentsDirectory()).path +"/"+fileName+sp.getString(objS));

  sp.setString(fileName, hard.path);
  sp.setString(lastUpdate, time0);

  return hard;

}else{

  return File((await getApplicationDocumentsDirectory()).path +"/"+fileName+sp.getString(objS));


}
  }

  final String objS = "timeFileSub";

  Future<void> delete() async{
    SharedPreferences sp = await SharedPreferences.getInstance();

    await File(sp.getString(fileName)).delete();
    await sp.setString(fileName,null);
    await sp.setString(objS,null);

    FirebaseStorage.instance.ref().child("profs/"+FirebaseAuth.instance.currentUser.uid+"_snap.jpg").delete();

    return FirebaseStorage.instance.ref().child("profs/"+FirebaseAuth.instance.currentUser.uid+".jpg").delete();
  }

  Future<void> upload(File f, String time0, BuildContext context) async {

    final String objS0 = DateTime.now().millisecondsSinceEpoch.toString();

    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(fileName, f.path);
    sp.setString(lastUpdate, time0);
    sp.setString(objS,objS0);



    File f0 = File((await getApplicationDocumentsDirectory()).path +"/"+fileName+objS0);
          
    Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s204_"));

    await f0.writeAsBytes(await f.readAsBytes());
  
    

    File f1 = File((await getApplicationDocumentsDirectory()).path +"/"+FirebaseAuth.instance.currentUser.uid + ".jpg");

    double l1 = (f0.lengthSync() / (50 * 1024));
    double l2 = (f0.lengthSync() / (330 * 1024));
    double l3 = (f0.lengthSync() / (1024 * 1024));
    

    File f2 = await FlutterImageCompress.compressAndGetFile(
        f0.path, f1.path,
        quality: l1 > 1.0 ? (l2 > 1.0 ? (l3 > 1.0 ? 20 : 30):66):80,
        rotate: 0,
      );

    

    //snapshot


    Im.Image image = Im.decodeImage(f2.readAsBytesSync());
    Im.Image smallerImage = Im.copyResize(image, width: (120*image.width/image.height).round(), height: 120); // choose the size here, it will maintain aspect ratio
  
    var compressedImage = new File(f2.path.replaceFirst(".jpg", "snap.jpg"))..writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 75));

  



    await f0.writeAsBytes(await f2.readAsBytes());

    await FirebaseStorage.instance.ref().child("profs/"+FirebaseAuth.instance.currentUser.uid + "snap.jpg").putFile(compressedImage).onComplete;
    var v = await FirebaseStorage.instance.ref().child("profs/"+FirebaseAuth.instance.currentUser.uid + ".jpg").putFile(f2).onComplete;

    
    compressedImage.delete();

    print(v.bytesTransferred);

  }

  void updatePath(String path) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(fileName, path);
  }

  Future<String> getPath() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(fileName);//null able
  }

  Future<File> loadFromFile(String s) async{

    File f0 = File((await getApplicationDocumentsDirectory()).path +"/"+fileName
    +(s));
    
    return (f0);
  }

  

}