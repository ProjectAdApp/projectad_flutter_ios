/*import 'dart:convert';
import 'dart:isolate';  

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'service/hws.dart';
import 'visual/style.dart';

class FlareEngine {

  Future<String> locateUIDByObject(String docName, String objName) async{

    return (await FirebaseFirestore.instance.collection("usd").doc(docName).get()).get(objName);

  }

  Future<void> setUIDByObject(String docName, String objName, String uid) async {

     return (await FirebaseFirestore.instance.collection("usd").doc(docName).set({objName: uid}, SetOptions(merge: true)));

  }

}

class UserNameEngine extends FlareEngine {

  Future<String> locateUIDByUsername(String objName) {
    return super.locateUIDByObject("userId", objName);
  }

  Future<void> setUIDByUserName(String objName){
    return super.setUIDByObject("userId", objName, FirebaseAuth.instance.currentUser.uid);
  }

}

class PhoneNumberEngine extends FlareEngine {

  Future<String> locateUIDByPhoneNumber(String objName) async{
    return super.locateUIDByObject("phoneId", objName);
  }

  Future<void> setUIDByPhoneNumber(String objName) async{
    return super.setUIDByObject("phoneId", objName, FirebaseAuth.instance.currentUser.uid);
  }

}

Route createRoute(
  Hws hw,
){
  return PageRouteBuilder(
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    pageBuilder: (context,a,b) {
    return Connections(hw);
  });
}

class Connections extends StatefulWidget {

  final Hws hw;
  Connections(this.hw);

  @override
  _ConnectionsState createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> with WidgetsBindingObserver, SingleTickerProviderStateMixin{



  

  bool dark;
  double w,h,th;
  Style currentStyle;

  Animation<Offset> _offsetAnimation;
  AnimationController animationController;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

  /*
  - Setup an account with a profile picture, username, name, bio and tags.
- Inspect solving timeline per day, week, month and overall, also the usage of jokers.
- Bug fixes*/

  @override
  void initState() {
    
    this.w = widget.hw.getWidth();
    this.h = widget.hw.getHeight();
    this.th = widget.hw.getTH();

    this.currentStyle = widget.hw.currentstyle;

    this.pageController = PageController();

 animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    ));
    super.initState();

    animationController.forward();
  }

  int currentPage = 0;
  PageController pageController;

  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return Scaffold(
      body: GestureDetector(child: Container(
        width:w,
        height: h,
        color: dark?Colors.black:Colors.white,
        child: Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        Container(height: h/23,),

        Container(width: w,
          height: h/21,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Row(

            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/26, child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: RotatedBox(quarterTurns: 3, child:  Icon(Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,),))),
              Container(width: w/32,),
              Container(width: w/8, height: w/8, ),
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("s197_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*40),textAlign: TextAlign.center,),))  
            ]
          ),)),
          
          Container(height: h/66,),

          Container(height: h/21,width: w/1.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: w/2.33,
                height: h/21,
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent
                                    )                  ),
                  onPressed: (){
                    setState(() {
                     currentPage = 0;

                    });
                pageController.animateToPage(0, duration: Duration(milliseconds: 900), curve: Curves.elasticIn);
              }, child: Center(child: Text(AppLocalizations.of(context).translateKey("s198_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th* 29, fontWeight: currentPage == 0 ? FontWeight.w500:FontWeight.w300),textAlign: TextAlign.center,))))
          ,
              VerticalDivider(
                width: 2,

                color: dark?Colors.grey[400]: Colors.grey[900],),
SizedBox(
                width: w/2.33,
                height: h/21,
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent
                                    )                  ),
                  onPressed: (){
                    setState(() {
                       currentPage = 1;
                    });
                   
                pageController.animateToPage(0, duration: Duration(milliseconds: 900), curve: Curves.elasticIn);
              }, child: Center(child: Text(AppLocalizations.of(context).translateKey("s199_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th* 29, fontWeight: currentPage == 1 ? FontWeight.w500:FontWeight.w300),textAlign: TextAlign.center,))))
          
          ],),),

          Container(height: h/88,),

          Center(child: SizedBox(
            width: w/1.05, 
            height: h/4*3,
            child: PageView(
              controller: pageController,
              onPageChanged: (i){
                setState(() {
                  this.currentPage = i;
                });
              },
              children: [
                ContanctView(widget.hw),
                ContanctView(widget.hw)
              ],
            ),
          ),)

          
          
          ]),
        
          
      ),
      onVerticalDragUpdate: (details) {
        int sensitivity = 8;
        if (details.delta.dy > sensitivity) {
            Navigator.pop(context);
        } else if(details.delta.dy < -sensitivity){
            // Up Swipe
        }
    
    },
    ),
    
    );
  }
}
class ContanctView extends StatefulWidget {

  Hws hw;
  ContanctView(this.hw);

  @override
  _ContanctViewState createState() => _ContanctViewState();
}

class _ContanctViewState extends State<ContanctView> with WidgetsBindingObserver{

  double w, h, th;
  bool dark;

  @override
  void initState() {
    
    this.w = widget.hw.getWidth();
    this.h = widget.hw.getHeight();
    this.th = widget.hw.getTH();

    checkContacts();

    super.initState();
  }
  @override
  void didChangePlatformBrightness() {
    setState(() {
      
    });
    super.didChangePlatformBrightness();
  }

  
  void checkContacts() async{
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);

    if(contacts != null && contacts.length > 0){

      if(await isAvailable()){
        

        resolveContatcs(contacts);

      }

      setState(() {
        a0 = data.length>0;
      });

    }

  }

  Future<bool> isAvailable() async{

    SharedPreferences sp = await SharedPreferences.getInstance();
    int lastTime = sp.getInt("update10");
    sp.setInt("update10", DateTime.now().millisecondsSinceEpoch);
    if(lastTime == 0)return true;
    return (DateTime.now().millisecondsSinceEpoch - lastTime > 1000*60*10);

  }

  Future<List> loadCountries() async{

    String value = await rootBundle.loadString('lang/countries.json');
    return jsonDecode(value);

  }

  String getPrefix(List l){
    String locale = Localizations.localeOf(context).countryCode;
    for(var v in l){
      Map<String, String> input = v;
      if(input["alpha_2_code"] == locale){
        return input["dial_code"];
      }
    }
  }

  Future<void> resolveContatcs(Iterable<Contact> cl ) async{

    List list = await loadCountries();

    List<String> completeSummary = [];

    PhoneNumberEngine engine = PhoneNumberEngine();

    do {

      Contact c = cl.iterator.current;

      List<Item> nums = c.phones.toList();



      nums.forEach((element) {

        Isolate.spawn((message) {
          analyseNumber(message);
        }, [element, list, engine]);
        
      });

    }while(cl.iterator.moveNext());

  }

  void analyseNumber(List va) async{
    Item element = va[0]; 
    List list = va[1]; 
    PhoneNumberEngine engine = va[2]; 
      String p = element.value;
        if(p.startsWith("0")){
          //get pre context
          
          p = (getPrefix(list)) + p;

        } 

          //run check
        
          String value = await engine.locateUIDByPhoneNumber(element.value);

          if(value != null && value.length>0){

            registerItem(p  , value);

          }
        
  }

  Map<String,String> data = {};

  void registerItem(String phone, String uid){

    if(data[phone] != null)return;  

    data[phone] = uid;

  }
  
  bool a0 = false;
  bool a1 = false;

  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

    return a0 ? Container(
      
      color: Colors.red,
      
    ): Stack(
      alignment: Alignment.center,
      children:[SizedBox(
      width: w/1.33,
      height: h/21,child: Container(
      decoration: BoxDecoration(
        color: dark?Colors.white:Colors.black,
        borderRadius: BorderRadius.circular(90),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
        ),
        ]
      )),
    )]);
  }
}
*/