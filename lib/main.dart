
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:projectad/account.dart';
import 'package:projectad/algo/quote.dart';
import 'package:projectad/edit.dart';
import 'package:projectad/imp.dart';
import 'package:projectad/authdisplay.dart';
import 'package:projectad/creator.dart';
import 'package:projectad/home.dart';
import 'package:projectad/sender.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/impf/impf.dart';
import 'package:projectad/service/insta31.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/settings.dart';
import 'package:projectad/shop.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'intent.dart';

List<CameraDescription> cameras = [];
IntentCollectionService ics = IntentCollectionService();
Map<String,IntentCollectionService> services = {"main.dart":ics};


// @dart=2.9
void main() async{ 

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if(!(await QuotePre.check())) QuotePre.access();

  try {
    cameras = await availableCameras();
    print(cameras);
  } on CameraException catch (e) {
   //logError(e.code, e.description);
   print(e);
  }

  

  
  runApp(StartLoadingWidget());

  /*if((await QuotePre.check())){
    QuotePre.access();
  }*/
}


// ignore: must_be_immutable
class StartLoadingWidget extends StatelessWidget {


  Hws mainhws;



  setMainHws(Hws hw){
    this.mainhws=hw;
  }



  @override
  Widget build(BuildContext context) {
        
    return MaterialApp(

      
      
        home: StartLoadingWidgetBody(this,context),
      
      supportedLocales: [
      const Locale('en','US'),
      const Locale('de','DE'),
      const Locale('fr',"FR"),
    ], 

    

    

    debugShowCheckedModeBanner: false,
    
    localizationsDelegates: [
      AppLocalizations.delegate,      
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    );
  }
}



// ignore: must_be_immutable
class StartLoadingWidgetBody extends StatefulWidget {
  StartLoadingWidget slw;
  BuildContext c;

  StartLoadingWidgetBody(this. slw, this. c);

  @override
  StartLoadingWidgetBodyState createState() => StartLoadingWidgetBodyState();
}

class StartLoadingWidgetBodyState extends State<StartLoadingWidgetBody> with WidgetsBindingObserver, TickerProviderStateMixin{

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
  }

  Hws hw;

    List<CameraDescription> cameras0;


 BuildContext c(){
   return widget.c;
 }

 GlobalKey<FormState> from = GlobalKey();

 createAlertDialog2(bool dark, BuildContext c, Function f){
   
   return showDialog(context: c, builder: (context){
     return AlertDialog(
       backgroundColor: dark?Colors.black:Colors.white,
       shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
       
       content: SingleChildScrollView(
         scrollDirection: Axis.vertical,

         child: Container(
          width: hw.getWidth()/1.2,
        height: hw.getHeight()/1.4,
        
         child: Center(child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             width: hw.getWidth()/1.5,
             height: hw.getHeight()/5,
             child: Center(child: AutoSizeText(AppLocalizations.of(c).translateKey("s131_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: hw.getTH()*32),textAlign: TextAlign.center,),
       )),

        Container(
          width: hw.getWidth()/1.6,
          height: hw.getHeight()/3,
          child: Center(child: Container(
            child: Form(key: from, child: TextFormField(
                


style: TextStyle(
        color: dark?Colors.black:Colors.white,
    ),
    
                
                decoration: InputDecoration(
                  
                  hintText: AppLocalizations.of(context).translateKey("s132_ "),


                  
                  
                  hintStyle: TextStyle(color: dark?Colors.grey:Colors.grey, fontSize: hw.getTH()*30),
                  labelText: AppLocalizations.of(context).translateKey("s132_ "),
                  labelStyle: TextStyle(color: dark?Colors.black:Colors.white, fontSize: hw.getTH()*30),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  focusColor: dark?Colors.white:Colors.black,
                  fillColor: dark?Colors.white:Colors.black,
                  filled: true,
                  alignLabelWithHint: false,
                  prefixIcon: Icon(Icons.alternate_email, color: Colors.grey,),
                  errorMaxLines: 3,
                  
                  
                  errorStyle: TextStyle(color:dark?Colors.red[900]:Colors.red),
                  
                  
                  enabledBorder: OutlineInputBorder(
                    
                    
                    borderSide: BorderSide(color: dark?Colors.white:Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    
                    borderSide: BorderSide(color: dark?Colors.white:Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    
                    borderSide: BorderSide(color: dark?Colors.white:Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    
                    borderSide: BorderSide(color: dark?Colors.white:Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                
                cursorColor: dark?Colors.black:Colors.white,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.top,
                obscureText: false,
                onEditingComplete: (){
              //value is entered text after ENTER press
              //you can also call any function here or make setState() to assign value to other variable


             
                  },
                  onFieldSubmitted: (s){
FocusScope.of(context).unfocus();
                  },
                  onSaved: (s){
FocusScope.of(context).unfocus();
                  },
            textInputAction: TextInputAction.continueAction,
                validator: (text) {

                  print(text);
                    

                  startValidate(text, c,f);

                  print("text:"+result);
                  
                  return result;
                  
                },
              )),

          ),),
        ),

       Container(
         width: hw.getWidth(),
         height: hw.getHeight()/10,
         child: Center(child: GestureDetector(
           onTap: (){
             from.currentState.validate();
           },
           child: Container(
           
         width: hw.getWidth()/3,
         height: hw.getHeight()/13,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(90),
           color: dark?Colors.white:Colors.black,
         ),
         child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("PSI4 "), style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: hw.getTH()*33),textAlign:TextAlign.center,),))),)
       )
       ])
         ),
       )
     ));
   });
 }
  String result = "";
  bool singlTouchdown = false;
 void startValidate(String text, BuildContext c, Function f){
   print("startValidate");
   if(singlTouchdown){singlTouchdown = false;return;}
   result = "";
   var v = InstagramHandler();
                  v.buildInstagramFollowRequest(FirebaseAuth.instance.currentUser.uid, text).then((value){
                    switch(value){
                      case -314:{
                        result = AppLocalizations.of(c).translateKey("s146_");
                        print(result);
                        singlTouchdown = true;
                        from.currentState.validate();
                        break;
                      }
                      case -313: {
                        result = AppLocalizations.of(c).translateKey("s155_");
                        print(result);
                        singlTouchdown = true;
                        from.currentState.validate();
                        break;
                      }
                      case -312:{
                      
                        result = AppLocalizations.of(c).translateKey("s156_");
                        print(result);
                        singlTouchdown = true;
                        from.currentState.validate();
                        break;
                      }
                      case 0:{
                        print("????");
                        f.call();
                        Navigator.pop(context, result);
                        launch("https://instagram.com/officialprojectad");
                        break;
                      }
                    }

                  });
 }
 reateAlertDialog2(bool dark, BuildContext c, Function f){
   
   return showDialog(context: c, builder: (context){
     return AlertDialog(
       backgroundColor: dark?Colors.black:Colors.white,
       shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
       
       content: SingleChildScrollView(
         scrollDirection: Axis.vertical,

         child: Container(
          width: hw.getWidth()/1.2,
        height: hw.getHeight()/1.4,
        
         child: Center(child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             
             child: Center(child: AutoSizeText("Dear Apple, only you can see this. As soon as our app is available in the apple app store, our ad partner allows us to show real ads. In this case: Here will be a rewarded video ad", style: TextStyle(color: dark?Colors.white:Colors.black,),textAlign: TextAlign.center,),
       )),

          


       Container(
         width: hw.getWidth(),
         height: hw.getHeight()/10,
         child: Center(child: GestureDetector(
           onTap: (){
             //from.currentState.validate();
              Navigator.pop(context, result);
             f.call();
             
           },
           child: Container(
           
         width: hw.getWidth()/3,
         height: hw.getHeight()/13,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(90),
           color: dark?Colors.white:Colors.black,
         ),
         child: Center(child:  AutoSizeText(AppLocalizations.of(context).translateKey("PSI4 "), style: TextStyle(color: dark?Colors.black:Colors.white, ),textAlign:TextAlign.center,),)),))
       )
       ])
         ),
       )
     ));
   });
 }

 createAlertDialog(bool dark, BuildContext c, Function successcall){
   return showDialog(context: c, builder: (context){
     return AlertDialog(
       backgroundColor: dark?Colors.black:Colors.white,
       shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
       
       content: Container(
         
        
        width: hw.getWidth()/1.2,
        height: hw.getHeight()/2.5,

        
        
        decoration: BoxDecoration(
          
           //borderRadius: BorderRadius.circular(90)
        ),
         child: Center(child: Column(

         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             width: hw.getWidth()/1.5,
             height: hw.getHeight()/5,
             child: Center(child: AutoSizeText(AppLocalizations.of(c).translateKey("s130_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: hw.getTH()*32),textAlign: TextAlign.center,),
       )),
       Container(
         width: hw.getWidth(),
         height: hw.getHeight()/12,
         child: Center(child: GestureDetector(
           onTap: (){
             Navigator.pop(context, result);
             createAlertDialog2(dark, c, successcall);
           },
           child: Container(
           
         width: hw.getWidth()/3,
         height: hw.getHeight()/13,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(90),
           color: dark?Colors.white:Colors.black,
         ),
         child: Center(child:  AutoSizeText(AppLocalizations.of(context).translateKey("PSI4 "), style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: hw.getTH()*33),textAlign:TextAlign.center,),),)),)
       )
       ])
     )));
   });
 }
 @override
  void dispose() {
    this._controller2.dispose();
    this.fadeonupdateanimationc.dispose();
    super.dispose();
  }

  @override
  initState(){

    this.cameras0 = cameras;

    fadeonupdateanimationc = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    fadeonupdateanimationc.repeat(reverse:true);
    fadeonupdateanimation = Tween(begin: 0.0, end: 1.0).animate(fadeonupdateanimationc);

    this._controller2 = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    this._coloranimation = ColorTween(begin: Colors.white, end: (WidgetsBinding.instance.window.platformBrightness==Brightness.dark)?Colors.black:Colors.white).animate(_controller2);

    super.initState();

    

    Impf().start(context).then((value){
      print("$value[0] value");
    

      if(value[0]=="403"){
        //sign in
        setState(() {
          updateonsignin=true;
        });
        print(updateonsignin);
        return;
      }
      setState(() {
        
        updatetext=value[0];
      });

      if(value[0]!="")ImpfService(value[1]).downloadFile(context, value[2]).then((value1){
        print("$value1 valueings");
        setState(() {
          updatetext=value1;
        });
        Future.delayed(Duration(milliseconds: 200)).then((value){
          setState(() {
            pushmain=true;
          });
        });
      });else {
         Future.delayed(Duration(milliseconds: 200)).then((value){
          setState(() {
            pushmain=true;
          });
        });
      }
    });
  }

  Animation fadeonupdateanimation;
  AnimationController fadeonupdateanimationc;

  String updatetext = "";

  bool updateonsignin = false;

  bool pushmain = false;


  void restartApplication(){
    Impf().start(context).then((value){
      print("$value[0] value");
      

      if(value[0]=="403"){
        //sign in
        setState(() {
          updateonsignin=true;
        });
        print(updateonsignin);
        return;
      }else{
        setState(() {
          updateonsignin=false;
        });
      }
      setState(() {
        
        updatetext=value[0]==null?"":value[0];
        
      });

      if(value[0]!="" && value[0]!="403")ImpfService(value[1]).downloadFile(context, value[2]).then((value1){
        setState(() {
          updatetext=value1==null?"":value[1];
        });
        Future.delayed(Duration(milliseconds: 200)).then((value){
          setState(() {
            pushmain=true;
          });
        });
      });else{
         Future.delayed(Duration(milliseconds: 200)).then((value){
          setState(() {
            pushmain=true;
          });
        });
      }
    });
  }

  int currentCall = 0;
  IntentX currentIntent = null;

  void updateHws(Hws hw){
    this.hw = hw;
  }

  void pushback(){
    setState(() {
      pushmain=false;
    });
  }

  void updatePage(int newCall, IntentX newIntent){
    setState(() {
       this.currentCall=newCall;
    this.currentIntent=newIntent;
    });
   
  }

  Widget getWidgetByCall(){
    switch(currentCall){
      case 0: return Home(hw, this);
      case 1: return Shop(hw, this, currentIntent);
      case 3: return Sender(hw, this, currentIntent);
      case 2: return Setting(hw, this);
      case 4: return Account(hw, this, currentIntent);
      
     
      //case 5: return Creator(hw, this, currentIntent);
    }
    return Container();
  }

  void signInBack(){
    setState(() {
          pushmain = false;
          updateonsignin = true;
        });
  }

  Animation _coloranimation;
  AnimationController _controller2;


  @override
  Widget build(BuildContext context) {
     SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

    bool dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;

    SvgPicture mainimage = SvgPicture.asset('images/pad.svg', color: dark?Colors.white:Colors.black, semanticsLabel: "");
    
    if(hw==null)
    {
    hw = new Hws(context,0);
    hw.loadStyle(0);
    widget.slw.setMainHws(hw);
    }
    //widget.slw=null;
    return pushmain?getWidgetByCall():updateonsignin?AuthDisp(hw, this):Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: _coloranimation,
        builder: (x,c){return Container(
      decoration: BoxDecoration(
        color: dark?Colors.black:Colors.white
      ),
          width: hw.getWidth(),
          height: hw.getHeight(),
          child: Center(
        
            child: Column(children: <Widget>[
              
              Container(
                height: hw.getHeight()/2-hw.getHeight()/6
              ),
              Container(
                height: hw.getHeight()/3,width: hw.getWidth()/3,
                child: mainimage),
              Container(
                color: dark?Colors.black:Colors.white,
                height: hw.getHeight()/2-hw.getHeight()/6,
                width: hw.getWidth(),
                //FadeTransition(opacity: fadeonupdateanimation as Animation<double>, child: Expanded(child: AutoSizeText(updatetext, style: TextStyle(color: dark?Colors.white:Colors.black),textAlign: TextAlign.center,))),
              )
            ],
          ),
        ));}));


      


  }


  
}

