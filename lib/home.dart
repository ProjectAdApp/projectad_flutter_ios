
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projectad/algo/quote.dart';
import 'package:projectad/algo/space.dart';
import 'package:projectad/creator.dart';
import 'package:projectad/intent.dart';
import 'package:projectad/main.dart';
import 'package:projectad/service/file_adapt.dart';
import 'package:projectad/service/insta31.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/service/saver.dart';
import 'package:projectad/visual/instagramb.dart';
import 'package:projectad/visual/style.dart';
import 'package:projectad/visual/typewriter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:ntp/ntp.dart';
import 'data.dart';
import 'imp.dart';
import 'env.dart';
import 'service/hws.dart';




class Home extends StatefulWidget {

  Hws hws;

  StartLoadingWidgetBodyState startLoadingWidgetBodyState;

  Home(this.hws,this.startLoadingWidgetBodyState){
    //home first open

    

    if(!services.containsKey("home.dart")){
      services["home.dart"] = HomeCollection();
    }


  }

  @override
  HomeState createState() => HomeState();
}

Future<int> getRealTime() async {
    print("getRealTime ---------------------------");
    return (await NTP.now()).millisecondsSinceEpoch;
  }

class HomeState extends State<Home> with WidgetsBindingObserver, TickerProviderStateMixin{

  static const platform = const MethodChannel("org.vali.src/projectad");

  Future<List<String>> getInstagramFollowers(String username) async{
    var result = await platform.invokeMethod("getInstagramFollowersSwift",{"ab1":username, "username":Env.instagramUsername, "password":Env.instagramPassword});
    print("result:"+result);
    String s = result;
    s = s.substring(0, s.length-1);
    return s.split(",");  
  }

   bool dark;

  @override
  void didChangePlatformBrightness() {

    setState(() {
      dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    });

    super.didChangePlatformBrightness();
    
  }
  void checkTime() async{

    //get time data
    //check time
    //update timex  

    print(timecount);

    int times = await getRealTime();
    if(timecount+28800000<times){
      //new quote


      await FirebaseDatabase.instance.reference().child("Users").child(uuid).child("D1").set(pointstxt+"?"+times.toString());

      newQuote().call();

    
      

    }


  }

  bool _loaded;

  FlutterLocalNotificationsPlugin plugin;

  

   AnimationController _controller1;
   Animation<Offset> _offsetAnimation;

  bool available = false;

  String srcx;


  Future<void> initSpaceController() async{

    if(srcx != null)return;

    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(uuid).child("F");
    String src = (await reference.once()).value;
    this.srcx = src;
    print("loaded source:"+srcx);
    
    WideSpaceResolver resolver = WideSpaceResolver(src);

    var temp = resolver;

    bool changed = false;

    SpaceCheck sc = SpaceCheck(resolver);
    if(sc.day()){
      resolver = resolver.clearDay(resolver);
      sc = SpaceCheck(resolver);
      changed = true;
    }
    if(sc.week()){
      resolver = resolver.clearWeek(resolver);
      sc = SpaceCheck(resolver);
       changed = true;
    }
    if(sc.month()){
      resolver = resolver.clearMonth(resolver);
      sc = SpaceCheck(resolver);
       changed = true;
    }

    if(temp.equals(resolver) && changed){

      resolver.update();

    }

    Hws hw = widget.hws;
    hw.setResolver(resolver);
    widget.hws.setResolver(resolver);
    widget.startLoadingWidgetBodyState.updateHws(hw);

    return;
  }

   FlutterLocalNotificationsPlugin pluginnotification;

  Future _selctnofit(String s){
    print("payload:"+s);
  }

  void showNotification() async{

    String title = AppLocalizations.of(context).translateKey("s157_");
    String body = AppLocalizations.of(context).translateKey("s158_");

    var android = new AndroidNotificationDetails("189", "projectad", "none");
    var IOS = new IOSNotificationDetails(); 
    var cross = new NotificationDetails(android: android, iOS: IOS);
    await pluginnotification.show(0, title, body, cross);
  }

  

  @override
  void initState() {
    uuid = FirebaseAuth.instance.currentUser.uid;
    super.initState();

    FlutterApplovinMax.init('7744bbf15d566bd0	');


    currentquote = "";
    h = widget.hws.getHeight();
    w = widget.hws.getWidth2(1);
    th = widget.hws.getTH();
    currentstyle= widget.hws.currentstyle;
    getPoints();

    pluginnotification = FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS=new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android: android, iOS: iOS);
    pluginnotification.initialize(initSettings, onSelectNotification: _selctnofit);
  

    _controller1 = AnimationController(vsync: this, duration: Duration(seconds: 1));

    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    _controller1.forward();

    this._controller = PageController(initialPage: 1);

    //handle activity history

    HomeCollection hc = services["home.dart"];
    if(hc.welcomed){
      //please welcome
      Future.delayed(Duration(milliseconds: 100)).then((value) => 
      this._controller.jumpToPage(0));

      Future.delayed(Duration(milliseconds: 1300)).then((value) => 
      this._controller.animateToPage(1, duration: Duration(milliseconds: 777), curve: Curves.ease));

      hc.welcomed = false;
      //this._controller.jumpToPage(1);
    }
    
    hc.addQuoteStateListener((n,o ) {
      if(n == QuoteState.SOLVED && o == QuoteState.SOLVE){
        //info
        this._controller.animateToPage(2, duration: Duration(milliseconds: 777), curve: Curves.ease);
      }
    });

    handleHistory();

    simagcontr = AnimationController(vsync: this, duration: Duration(microseconds: 800));
    sigmaanimation = Tween(begin: 0.0, end: 1.0).animate(simagcontr);

    

      

  // ad listener




  available = StaticSave.value("home.text");
  if(available==null)available=false;

  

  var v = InstagramHandler();
    uuid = FirebaseAuth.instance.currentUser.uid;
    v.requestFilledIsAvailable(uuid).then((value){
      print("isAvailable"+value.toString());
            if(value){
        v.checkInstagramRequestFilled(uuid, this).then((value) {
          if(value==-99){
            String data = (pointscount-=10).toString()+"?"+DateTime.now().millisecondsSinceEpoch.toString();
            FirebaseDatabase.instance.reference().child("Users").child(uuid).child("D1").set(data);
            
          }
          if(value==1){
            String data = (pointscount+=10).toString()+"?"+DateTime.now().millisecondsSinceEpoch.toString();
            FirebaseDatabase.instance.reference().child("Users").child(uuid).child("D1").set(data).then((value){
showNotification();
            });
          }
        });
      }
    });  

  }

  void listener(AppLovinAdListener event, bool isInter){

    
    if(event == AppLovinAdListener.adLoadFailed){
      print("failed");
      Fluttertoast.showToast(msg: 'Failed', toastLength: Toast.LENGTH_SHORT);
      return;
    }
    if(event == AppLovinAdListener.onUserRewarded){
      //reward
      print("rewarded");

      _controller.animateToPage(1, duration: Duration(seconds: 1), curve: Curves.ease);

      SharedPreferences.getInstance().then((value) {
        int ix1 = value.getInt("last_ad_update_time1");if(ix1==null)ix1=0;
        int ix2 = value.getInt("last_ad_update_time2");if(ix2==null)ix2=0;
        int ix3 = value.getInt("last_ad_update_time3");if(ix3==null)ix3=0;

        int currenttime = DateTime.now().millisecondsSinceEpoch;

        if(ix1+600000<currenttime){
          value.setInt("last_ad_update_time1", currenttime);
        }else{
          if(ix2+600000<currenttime){
            value.setInt("last_ad_update_time2", currenttime);
          }else{
            if(ix3+600000<currenttime){
            value.setInt("last_ad_update_time3", currenttime);
            }
          }
        }
      

      });

      print("call function");
      _function.call();
    }
    if(event == AppLovinAdListener.onRewardedVideoCompleted){
      if(pendingTransition){
        Future.delayed(Duration(milliseconds: 100)).then((value)  {
           this.pendingTransition = false;
        setState(() {
          isSolved=false;
          //currentquote = s[0];
          wordscurrentqoute = [currentquote];
          readydisplay=true;
          //failword = s[1];
        });          
        });
      }
    }
    

  
       

       
    
    
    
 


  }

  /*listener(AdColonyAdListener event)async {
    print(event);
    if (event == AdColonyAdListener.onRequestFilled) {
      AdColony.show();
      return;
    }
    if(event == AdColonyAdListener.onReward){
       print("rewarded");

      var currenttimex = (await NTP.now()).millisecondsSinceEpoch;

      SharedPreferences.getInstance().then((value) {
        int ix1 = value.getInt("last_ad_update_time1");if(ix1==null)ix1=0;
        int ix2 = value.getInt("last_ad_update_time2");if(ix2==null)ix2=0;
        int ix3 = value.getInt("last_ad_update_time3");if(ix3==null)ix3=0;

        int currenttime = currenttimex;

        if(ix1+adsSlowTime<currenttime){
          value.setInt("last_ad_update_time1", currenttime);
        }else{
          if(ix2+adsSlowTime<currenttime){
            value.setInt("last_ad_update_time2", currenttime);
          }else{
            if(ix3+adsSlowTime<currenttime){
            value.setInt("last_ad_update_time3", currenttime);
            }
          }
        }
      

      });
      return;
    }
    if(event == AdColonyAdListener.onClosed){
      Future.delayed(Duration(milliseconds: 100)).then((value)  {
           this.pendingTransition = false;
        setState(() {
          isSolved=false;
          //currentquote = s[0];
          wordscurrentqoute = [currentquote];
          readydisplay=true;
          //failword = s[1];
    });
      });
    }
    
  }
  */



   Function _function;

  String timetxt="";
  int timecount=0;

    void finished(){
      StaticSave.save("home.text", true);
      setState(() {
        available=true;
   // activateBlurTimer();
  
      });
  }


  void getPoints() {
    //updateing coins

    
    HomeCollection hc = services["home.dart"];
    FirebaseDatabase.instance.reference().child("Users").child(uuid).child("D1").onValue.listen((event) {
      String s = event.snapshot.value;
      widget.hws.v.setMultiple(s, "d1");
      setState(() {

      if(s == null){
        Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s205_"), toastLength: Toast.LENGTH_SHORT);
        widget.startLoadingWidgetBodyState.signInBack();
      }

      pointstxt = s.substring(0,s.indexOf("?"));
      pointscount = int.parse(pointstxt);
      timetxt = s.substring(s.indexOf("?")+1);
      timecount = int.parse(timetxt);
      
      hc.loadQuoteFinished();
    });

    checkTime();
    });

    

   
  

  }

  @override
  void dispose() {
    
    _controller1.dispose();
    simagcontr.dispose();
    _controller.dispose();
    _controller2.dispose();
  
    super.dispose();
  }

  int quotecount = 0;
  List<String> listquote;

  void handleHistory() async{
    String s = await FileAdapter().readFile("history.txt");

    
    if(s=="404"){
      await FileAdapter().writeFile("history.txt", " ");
      setState(() {
        quotecount = 0;
      });
    }else{
      
      
      if(s==" "){
        setState(() {
          listquote = [];
        });
        return;
      }

      List<String> ss = s.split("#");
      
      if (ss.length >=1){

        if(ss.length > 120 ){

          String newS = s.split("#").getRange(ss.length-120, ss.length).join("#");
          await FileAdapter().writeFile("history.txt", newS);

          ss = newS.split("#");

        }
        
      setState(() {
        listquote = ss;
        _controller2 = PageController(initialPage: listquote.length);
      });
      }else{
         setState(() {
        listquote=[s];
        _controller2 = PageController(initialPage: listquote.length);  
        });      }

      

    }

  }

  void updatePageController(){
    if(_controller2 != null && _controller2.hasClients)
    _controller2.jumpToPage(_controller2.initialPage);
        available=true;
   // activateBlurTimer();
  
     // Future.delayed(Duration(seconds: 10)).then((value) => newQuote().call());
  }

  void handleQuoteState(int i) async{
    if(i!=0)return;
    pointer++;
    HomeCollection hc = services["home.dart"];

    

    List s = await QuoteAlgo().callResult(uuid, Localizations.localeOf(context));
    if(s.length==1){
      setState(() {
        currentquote = s[0];
        wordscurrentqoute = [currentquote];
        readydisplay=true;
        isSolved=true;
      hc.changeQuoteState(QuoteState.SOLVED);
        activateBlurTimer();
      });
    }else{
    setState(() {
      isSolved=false;
      currentquote = s[0];
      wordscurrentqoute = [currentquote];
      print(currentquote);
      readydisplay=true;
      hc.changeQuoteState(QuoteState.LOADED);
    });
    failword = s[1];
    }
  }

  void activateBlurTimer(){
    setState(() {
      blurred = false;
    });
    Future.delayed(Duration(seconds: 3)).then((value){
      setState(() {
        blurred = true;
      });
    });
  }



  double h = 0;
  double w = 0;
  double th = 0;

  String pointstxt = "...";
  String uuid = "";
  int pointscount = 0;

  String currentquote = "";
  String failword = "";

  int pointer = 0;

  bool readydisplay = false;



  List<String> wordscurrentqoute = [""];

  Style currentstyle;

  bool typemode = false;

  bool finalanim = false;

  bool isSolved = false;

  bool blurred = false;

  void setFinalAnim(String quote){

   setState(() {
     readydisplay=false;
   });

   _controller.animateToPage(1, duration: Duration(seconds: 1), curve: Curves.ease);

    simagcontr.forward().then((value)  {
setState(() {
  readydisplay=true;
      finalanim=true;
      this.currentquote = quote;
      this.wordscurrentqoute = [currentquote];
      isSolved=true;
      activateBlurTimer();
       typemode=false;

    });
    Future.delayed(Duration(milliseconds: 2200)).then((value){
      setState(() {
      finalanim=false;
    });
    });
    });

    //display finished quo
    return;
     

    
  }





  
  
   
        
     
  void loadAd(Function f) async{


 


    

    //checking time

    int currenttimex = await getRealTime();

    SharedPreferences sp = await SharedPreferences.getInstance();
    int i1 = sp.getInt("last_ad_update_time1");if(i1==null)i1=0;
    int i2 = sp.getInt("last_ad_update_time2");if(i2==null)i2=0;
    int i3 = sp.getInt("last_ad_update_time3");if(i3==null)i3=0;

    //30 mins = 30 * 60 * 1000 = 1.800.000

    if(i1+adsSlowTime<currenttimex || i2+adsSlowTime<currenttimex || i3+adsSlowTime<currenttimex){

    



    this._function=f;

    // print('what');

    bool loaded = await FlutterApplovinMax.isLoaded((AppLovinAdListener event) => listener(event, false));

    print(loaded);

    if(loaded)FlutterApplovinMax.showRewardVideo((AppLovinAdListener event) => listener(event, false));



    }else{
      

      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translateKey("TOAST4 "),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1
    );

    }
    
  } 

  String fill(String s, int l){
    String out = "";
    for (var i = 0; i < l; i++) {
      out = out + s;
    }
    return out;
  }

  Function newQuote() {

    HomeCollection hc = services["home.dart"];
    
    
        
    return (){
      print("ejfsd");
      setState(() {
      readydisplay=false;
      typemode=false;
       });
    FileAdapter().readFile("history.txt").then((s){
if(s==" "){
          s = currentquote.replaceFirst( fill("_",failword.length), failword);
        }else{
          s = s + "#" + currentquote.replaceFirst( fill("_",failword.length), failword);;
        }

        FileAdapter().writeFile("history.txt", s);
    });
      QuoteAlgo().generateNewQuote(uuid, Localizations.localeOf(context)).then((s){
        print("updating world");
        setState(() {
          isSolved=false;
      currentquote = s[0];
      wordscurrentqoute = [currentquote];
      readydisplay=true;
      failword = s[1];
    
      hc.changeQuoteState(QuoteState.LOADED);
    });

    this.pendingTransition = true;
    
      });
    };
  }

  bool pendingTransition = false;

  void updatePoints({int amount, int time}){
    setState(() {
      this.timecount=time;
      this.timetxt=time.toString();
      this.pointscount=amount;
      this.pointstxt=amount.toString();
    });
  }


   Animation sigmaanimation;
   AnimationController simagcontr;

//   PageController _controller2;

  PageController _controller;

  List<Widget> oldQuotes(){

    

    List<Widget> widgets = [];
   if(listquote != null && listquote.length > 0)
      listquote.forEach((element) {
        if(element != "")
        widgets.add(
          Container(
            child: Center(child: 
            Container(width: w-w/12, child: Stack(children: [
                AutoSizeText(
                element, textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*37)
              
          )
            ]
            )
            )
            )
          
          )
        );
      });
    
    //widgets.add(Container());

    return widgets;

  }

  List insertGet(List x, int index, var element){
    x.insert(index, element);
    return x;
  }

  PageController _controller2;

  List<Widget> pages(){

    List<Widget> olds = oldQuotes();

    Future.delayed(Duration(milliseconds: 50)).then((value) => updatePageController());

  //  _controller2 = PageController(initialPage: olds.length);
   /* Future.delayed(Duration(milliseconds: 50)).then((value) {
      _controller2.jumpToPage(olds.length);
    });
*/
    List<Widget> a =  [
      
      
    PageView(
      controller: _controller2,
      scrollDirection: Axis.vertical,
      pageSnapping: true,
      children: insertGet(olds, olds.length,
      FlatButton(
              onPressed: (){
                if(!isSolved){print("press");
                initSpaceController().then((value){
setState(() {
                  typemode=true;
                  HomeCollection hc = services["home.dart"];
                  hc.changeQuoteState(QuoteState.SOLVE);
                });
                  });
                }
              },
              onLongPress: (){
                if(typemode){
                  setState(() {
                    typemode=false;
                  });
                }
              },
              color: Colors.black.withOpacity(0.0),
            disabledColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            disabledTextColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,

              child: Center(
              //fjj
              child: readydisplay?Center(child: Container(width: w-w/12, child: available?blurred ? Stack(children: [
                AutoSizeText(
                currentquote, textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*37)
              ),
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0,sigmaY: 5.0))
              ],) : AutoSizeText(
                currentquote, textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*37)
              ):Container(child: TypewriterAnimatedTextKit(
                pause: Duration(milliseconds: 90),
                
                onNext: (x,s){},
                onTap: (){
                  
                  print("tapcc");
                  if(!isSolved){print("press");
                  initSpaceController().then((value){
setState(() {
                  typemode=true;
                });
                  });
                
                }},
                onFinished: finished,
                
                
                textAlign: TextAlign.center, text: [currentquote], speed: Duration(milliseconds: 90),displayFullTextOnTap: true, isRepeatingAnimation: false,repeatForever: false, textStyle: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*32
                ),)))):Container()
            ),
          ),
      )),
          //ad info

          Container(child: Center(child: 
          
            Stack(
             
              //  color: Colors.grey[200].withAlpha(90),
             //   borderRadius: BorderRadius.circular(33),
                
              
              children:[ Positioned(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
                child: Center(child: 
              Text(AppLocalizations.of(context).translateKey("s201_"), style: TextStyle(fontSize: th * 23, fontWeight: FontWeight.w400,color: dark?Colors.white:Colors.black, ),textAlign: TextAlign.center,)),
            )])

          ,))

          ];
          a.insert(0, getUpdatedTexts());
          return a;
  }

  Widget getUpdatedTexts(){
    return Container(child: Center(child: Container(width: w-w/12, child: AutoSizeText(
                AppLocalizations.of(context).translateKey("s159_"), textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*32)
              )))
              );
  }

  bool pullUpCreatorMode = false;

  @override
  Widget build(BuildContext context) {
    handleQuoteState(pointer);
    dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    Image im = Image(image: AssetImage("images/qp.png"), color: dark?Colors.white:Colors.black,);
    

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
      width: w,
      height: h,
      color: dark?Colors.black:Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[

          
        
         Column(
        children: <Widget>[
          Container(height: h/33),
          Container(width: w,
          height: h/12
          ,child: SlideTransition(
            position: _offsetAnimation,
            child: Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/10, height: w/8, child: GestureDetector(
                onTap: (){
                  widget.startLoadingWidgetBodyState.updatePage(2, null);
                },
                child: Icon(Icons.settings, color: dark?Colors.white:Colors.black,),)),
               
              Container(width: w/32,),
              Container(width: w/10 , height: w/8, child: GestureDetector(
                onTap: (){

                  CloudCombinatorix.loadUNData().then((un_data)  {
          if(num.tryParse(un_data)!=null){

          //creator
          //
          //
          print("work");
          setState(() {
            pullUpCreatorMode = true;
          });

        }else{

          List<dynamic> data = CloudCombinatorix.getUNDatas(un_data);



         // sp.setString(CloudCombinatorix.sourceControl1, jsonEncode(data));
         IntentX xx = new IntentX();
         xx.addParameter("data", data);
          widget.startLoadingWidgetBodyState.updatePage(4, xx);

        }
        });

                 
                },child: Icon(Icons.person, color: dark?Colors.white:Colors.black,),),),

   
Container(width: w/32,),
              Container(width: w/2.44 , height: w/8, child: Center(child:AutoSizeText("ProjectAd", style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: widget.hws.getTH()*32),textAlign: TextAlign.center,),)),
              
              Container(width: w/3.45, height: w/8,
              child: GestureDetector(
                onTap: (){
                  IntentX i = new IntentX();
                  i.addParameter("count", pointstxt);
                  
                  widget.startLoadingWidgetBodyState.updatePage(1, i);
                },
                
                child: Center(child: Container(width: w/3.45-w/30, height: w/12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: dark?Colors.white:Colors.black, width: 1.5)), child: Center(child: Row(
                children: <Widget>[
                  Container(height: w/10,width: w/6,child: Center(child:Container(width: w/6, child: Container(child: AutoSizeText(pointstxt,style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*30),textAlign: TextAlign.right,))),)),
                  Container(height: w/10  , width: w/27,child: im, )
                ]
              )),)),))
            ]
          ),)),
          
            Container(
            width: w,
            height: h/3,
            color: dark?Colors.black:Colors.white,
            child: PageView(children: pages(), 
            physics: NeverScrollableScrollPhysics(),
            controller: _controller,)),
          Container(height: h/25,),
          //wave,
          Container(height: h/12, width: w,
          child: dark?WaveWidget(
    config: CustomConfig(
      
        gradients: currentstyle.getListLight(),
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.20, 0.23, 0.25, 0.30],
        blur: MaskFilter.blur(BlurStyle.solid, 10),
        gradientBegin: Alignment.bottomLeft,
        gradientEnd: Alignment.topRight,

    ),
    
    duration: 1000,
    
    waveAmplitude: 10,
    heightPercentange: 0.45,
    backgroundColor: Colors.transparent,
    size: Size(
        double.infinity,
        double.infinity,
    )):WaveWidget(
    config: CustomConfig(
      
        gradients: currentstyle.getListDark(),
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.20, 0.23, 0.25, 0.30],
        blur: MaskFilter.blur(BlurStyle.solid, 10),
        gradientBegin: Alignment.bottomLeft,
        gradientEnd: Alignment.topRight,

    ),
    
    duration: 1000,
    
    waveAmplitude: 10,
    heightPercentange: 0.6,
    backgroundColor: Colors.transparent,
    size: Size(
        double.infinity,
        double.infinity,
    )),

),
        Container(height: h/2.3275, width: w, decoration: BoxDecoration(gradient: LinearGradient(colors: !dark?currentstyle.getListDark()[3]:currentstyle.getListLight()[3], begin: Alignment.centerLeft, end: Alignment.centerRight)), child: Center(
          child: typemode?Solve(widget.hws, failword, currentquote, this):
          
            Container(height: h/7,width: w/1.8,decoration: BoxDecoration(
            border: Border.all(color: dark?Colors.white:Colors.black, width: 2.5),
            borderRadius: BorderRadius.circular(90),  
            color:Colors.transparent,
          ),
          child: FlatButton(
            onPressed: (){loadAd(newQuote());},
            color: Colors.black.withOpacity(0.0),
            disabledColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            disabledTextColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            
            child: Center(
            child: Container(child: AutoSizeText(AppLocalizations.of(context).translateKey("MA1 "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*43 ),textAlign: TextAlign.center,))
          ),))
        )),
       // Container(height: h/100, width: w, decoration: BoxDecoration(gradient: LinearGradient(colors: dark?currentstyle.getListDark()[3]:currentstyle.getListLight()[3], begin: Alignment.centerLeft, end: Alignment.centerRight)))

        ]
         ),
         Positioned(
          left: 0, 
          top: h/2-((w/6)/2),
          child: InstagramWrapper(this.widget.hws, this.uuid, this),
        ),
         finalanim?BackdropFilter(filter: ImageFilter.blur(
          sigmaX: sigmaanimation.value*5,
          sigmaY: sigmaanimation.value*5,
        ),
          child: Container(color: Colors.transparent),
        ):Container(),
                      finalanim?Center(child: FlareActor("images/correct.flr", alignment:Alignment.center, fit:BoxFit.contain, animation: "Untitled",)):Container(),

 pullUpCreatorMode?Creator(widget.hws, widget.startLoadingWidgetBodyState,this, null):Container(),

   

    ]
    )
    )
    );
  }


  void resolveResolverChanges(WideSpaceResolver resolver){
    widget.hws.setResolver(resolver);
    widget.startLoadingWidgetBodyState.updateHws(widget.hws);
  }

  void back2(){
    setState(() {
      pullUpCreatorMode = false;
    });
  }

}

class Solve extends StatefulWidget {

  Hws hw;

  String randomword;
  String quote;
  HomeState state;

  Solve(this.hw, this.randomword, this.quote, this.state);

  @override
  _SolveState createState() => _SolveState();
}

class _SolveState extends State<Solve> with WidgetsBindingObserver, TickerProviderStateMixin{

  Hws hw;

  double h;
  double w;
  double th;

  String failword;
   String quote;

   bool dark;

   List<String> jokers;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
          this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    });
  }

  @override
  void initState() {
    h = widget.hw.getHeight();
    w = widget.hw.getWidth();
    th = widget.hw.getTH();
    failword = widget.randomword;
    quote = widget.
    quote;
    startfadecontroller = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    startfade = new Tween(begin: 0.0, end: 1.0).animate(startfadecontroller);
    controllers = new List(12);
    for (var i = 0; i < 12; i++) {
      controllers[i]=new TextEditingController();
    }
    charpositioninword = new List(12);
    isClicked = new List(12);
    isClicked.fillRange(0, 12, false);
    currentWord = new List(12);
    isJoked = new List(12);
    isJoked.fillRange(0, 12, false);
    super.initState();
    prepare();

    

    


  }

  



  Future<void> prepare() async{
//steps
//1: lookup the generated quotecode in the quoters.txt
//2: load jokers
//3: 

  String quotecode = QuoteAlgo.generateQuoteCode(quote);
  String content = await FileAdapter().readFile("quoters.txt");
  if(content=="404"){
    //file does not exists
    await FileAdapter().writeFile("quoters.txt", quotecode+"#"+"");
    return prepare();
  }else{

    QuoteDataHandler qdh = QuoteDataHandler(content);

    if(quotecode==qdh.getQuoteCode()){

      //its the same

      //get jokers

      List<String> jokers = qdh.getJokers();

      if(jokers.length!=0){
        this.jokers=jokers;
      }

      return handle();

    }else{

      //update the file to current quotecode

      content = quotecode+"#"+"";
      await FileAdapter().writeFile("quoters.txt", quotecode+"#"+"");
      return prepare();
    }

  }

  }

  final alphabethen = ["a","b","c","d","e","f","g","h","i","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
  final alphabethde = ["a","b","c","d","e","f","g","h","i","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","ä","ö","ü","ß"];

  List<String> counters = List(12); //list with 12 value. For each key one value..

  void handle(){

    isClicked.fillRange(0, isClicked.length, false);
    currentWord.fillRange(0, failword.length, null);

    Locale l = Localizations.localeOf(context);
     List src;
    if(l.languageCode=="de"){
      src = alphabethde;
    }
    if(l.languageCode=="en"){
      src = alphabethen;
    }
    if(l.languageCode=="fr"){
      src = alphabethen;
    }

    List wordaschar = List(failword.length);
    int index = 0;

    Random r = new Random();

    print(failword);

    List<String> given = List(12);  

    wordaschar.forEach((element) {
      int irand;
      while(true){
        irand = r.nextInt(12);
        if(given[irand]==null)break;
      }
      print(irand);
      given[irand]=failword[index];

      index++;
    });



    //given is now a sequenz with some empty spaces, which have to be filled with random chars

    index = 0;
    given.forEach((element) {
      if(element==null){
        given[index]=src[r.nextInt(src.length)];
      }
      print("given: "+given[index]);
      index++;
    });

    //given is now filled with random chars

    //setup jokers in both lists

    counters = given;

    //clearing jokers before
    //int ixa = 0;
    //List<int> wrong = List();
    /*if(jokers.length=0){jokers.forEach((element) {
      wrong.add(ixa);
      ixa++;
    });
    wrong.forEach((element) {
      jokers.removeAt(element);
    });
    }*/

    if(jokers.length!=0)jokers.forEach((e) {
      //get pos of joker
      print(e);
      if(e==""||e==" "||e==null)return;
      int pos = int.parse(e);

      
      int posIn=0, peso=0;
      String txt = failword[pos];

      while(true){

        posIn = counters.indexOf(txt, peso);

        if(isClicked[posIn])break;
        else{
          peso = posIn+1;
        }

      }

      this.currentposition=pos;


      isJoked[pos]=true;
      handleClick(posIn, counters[posIn]);

    });

    handlePositionAfterTap();

    setState(() {
      startfadecontroller.forward();
      isReady = true;
    });
  }

  void handlePositionAfterTap(){
    this.currentposition=0;
   
    for (String s in currentWord) {
      if(s==null || s=="")break;
      currentposition++;
    }
    
  }

  void handleClick(int pos, String text){

    print("currentposition");
    print(currentposition);


    //check setClicked for pos
    //setClicked for pos
    //add to currentword
    //updatecurrentpos

        print("tap");


    if(isClicked[pos]){
      return;//this key was already used
    }




    setState(() {
      isClicked[pos]=true;
    });

    print(currentWord);

    currentWord[currentposition]=text;

    
    resolveChanges(text, currentposition,pos);

        handlePositionAfterTap();

checkCurrentWord();
  }


  List<TextEditingController> controllers = new List(12);
  List<int> charpositioninword = new List(12);
  List<bool> isClicked = new List(12);
  List<String> currentWord = new List(12);
  List<bool> isJoked = new List(12);

  int currentposition = 0;//the text area with will be attached by clicking on a key
  

  bool isReady = false;
  bool err = false;

   Animation startfade;
   AnimationController startfadecontroller; 

  @override
  Widget build(BuildContext context) {

    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;

    this.hw = widget.hw;

    return isReady?FadeTransition(opacity: startfade as Animation<double>, child: Container(
        width: w,
        height: h/2.75,
        color: Colors.transparent,
        child: Center(child: Column(
          




          children: [
            
            //word displayer
            Container(height: h/11, width: w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getWordDisplayer()
            ),
            
            ),

            Container(height: h/12, width: w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Spacer(),
                GestureDetector(
                  onTap: joker1,
                  child: Container(
                    width: w/9,
                    height: h/12,

                    child: Image(width: w/9,
                    height: h/12,image: !dark?AssetImage("images/correct_black.png"):AssetImage("images/correct_white.png"),),
                )),
                Spacer(),
                GestureDetector(
                  onTap: joker2,
                  child: Container(
                    width: w/9,
                    height: h/12,
                    child: Image(
                      width: w/9,
                    height: h/12,image: !dark?AssetImage("images/one_black.png"):AssetImage("images/one_white.png"),),
                )),
                Spacer(),
                GestureDetector(
                  onTap: joker3,
                  child: Container(
                    width: w/9,
                    height: h/12,
                    child: Image(
                      width: w/9,
                    height: h/12,
                      image: !dark?AssetImage("images/next_black.png"):AssetImage("images/next_white.png"),),
                )),
                Spacer()
                
            ],)),
            
            
             //row1 above,
            Container(
            width: w,
            height: h/11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row(0)
            ),
          ),
          Container(
            width: w,
            height: h/11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row(1),
            ),
          ),
          ]
        ),)
    )):Container(width: w, height: double.infinity);
  }

  List<Widget> row(int num){
    List<Widget> widgets = new List();
    for (var i = 0; i < 6; i++) {

      widgets.add(Spacer());
      widgets.add(GestureDetector(onTap: (){handleClick(i+6*num, counters[i+6*num]);},child: Container(
        width: w/9,
        height: h/12,
        
        decoration: BoxDecoration(
          border: Border.all(color: !isClicked[i+6*num]?dark?Colors.white:Colors.black:Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(9),
          color: Colors.transparent
        ),
        child: Center(child: Container(
          child: AutoSizeText(counters[i+6*num],textAlign: TextAlign.center, style: TextStyle(color:!isClicked[i+6*num]?dark?Colors.white:Colors.black:Colors.grey, fontSize: hw.getTH()*30),))),
      )));
      widgets.add(Spacer());
    }

    return widgets;
  }

  List<Widget> getWordDisplayer(){
    List<Widget> widgets = new List();
    int blech = 9;

    if(failword.length>9)blech = failword.length;

    for (var i = 0; i < failword.length; i++) {
      widgets.add(Spacer());
      widgets.add(GestureDetector(onTap: (){handleBackClick(i, controllers[i]);},child: Container(
        width: w/blech,
        height: h/12,
        
        decoration: BoxDecoration(
          border: Border.all(color:err?Colors.red:dark?Colors.white:Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(9),
          color: Colors.transparent
        ),
        child: Center(child: TextField(
          decoration: new InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        
        hintText: ""),
        textAlign: TextAlign.center,
        enabled: false,
          controller:controllers[i],  style: TextStyle(color: err?Colors.red:dark?Colors.white:Colors.black, fontSize: hw.getTH()*30),)),
      )));
      widgets.add(Spacer());
    }
    return widgets;
  }

  void joker1(){

    widget.state.loadAd((){
      for (var i = 0; i < failword.length; i++) {
      currentWord[i]=failword[i];
    }
    checkCurrentWord();
    widget.hw.resolver.updateJokerUse();
    widget.state.resolveResolverChanges(widget.hw.resolver);
    });

  }

  void check31(int index){

    int ix = 0;

    bool finisher = false;

    charpositioninword.forEach((element) {
      if(finisher)return;
      if(element == index){
        print("ix");
        print(ix);
        print(controllers[ix].text);
        handleBackClick(ix, controllers[ix]);
        finisher = true;
      } 
      ix++;
    });

  }

  void joker2() async{

    print(widget.state.pointstxt);

    int count = widget.state.pointscount;
    if(count>=5){

      count = count -5;

    await FirebaseDatabase.instance.reference().child("Users").child(widget.state.uuid).child("D1").set((count.toString()+"?"+widget.state.timetxt));
      
    widget.state.updatePoints(amount: count, time: widget.state.timecount);

    int index = 0;
    int pera = 0;

    int cp = currentposition;

    print("current"+currentposition.toString());

    if(failword.length<=currentposition)return;

    String txt = failword[currentposition];
    while(true){
      index = counters.indexOf(txt, pera);
      print("=======");
            print(index);
      if(index==-1){

        
        index = counters.indexOf(txt, 0);

        //clear isClicked[index]

        check31(index);
        
        break;
      }
      if(!isClicked[index])break;
      else{
        pera = index+1;
      }
    }

    print(index);
    this.currentposition=cp;
    isJoked[currentposition]=true;
    handleClick(index, failword[currentposition]);

    String quotecode = QuoteAlgo.generateQuoteCode(quote);

    print("joker"+cp.toString());

    jokers.add(cp.toString());
if(widget.hw.resolver==null)widget.hw.setResolver(WideSpaceResolver(widget.state.srcx));
    widget.hw.resolver.updateJokerUse();
    widget.state.resolveResolverChanges(widget.hw.resolver);

    QuoteDataHandler.setData(quotecode, jokers);

    //get jokers list

    

    }
    


  }
  void joker3(){
widget.state.loadAd((){  
  widget.hw.resolver.updateJokerUse();
  widget.state.newQuote().call();
});

  }

  void resolveChanges(String text, int pos, int bpos){
    print(controllers[pos]);
    controllers[pos].text=text;
    charpositioninword[pos]=bpos;
  }

  void handleBackClick(int pos, TextEditingController text2){

    print(text2.text);

        if(isJoked[pos])return;


    if(text2.text == null || text2.text == "")return;

    print("pos:"+pos.toString());
    print(charpositioninword);

    currentWord[pos]=null;

  

    controllers[pos].addListener(() {
      print(controllers[pos].text);
    });
    controllers[pos].text="";
    setState(() {
      isClicked[charpositioninword[pos]]=false;
    });

    handlePositionAfterTap();
    checkCurrentWord();
  }


  int realLenght(List l){
    int index =0;
    l.forEach((element) {
      if(element!=null)index++;
      
    });

    return index;
  }

  String value(List<String> l){
    var concatenate = StringBuffer();

  l.forEach((item){

    if(item!=null)concatenate.write(item);
  }); 
  return concatenate.toString();
  }

  String real(List<String> l){
    String s  = "";
    l.forEach((element) {
      s = s+element;
    });
    return s;
  }

  void checkCurrentWord() async{

    print("fin");
    print(realLenght(currentWord));

    if(realLenght(currentWord)==failword.length){

      
      print(realLenght(currentWord));
      print(value(currentWord));

      //finale
      if(value(currentWord)==failword){

        
        //right


        //solve quote

        List<String> underline = List(failword.length);
        underline.fillRange(0, underline.length, "_");

        String finq = quote.replaceAll(real(underline), failword
        );

        widget.state.setFinalAnim(finq);

        DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(widget.state.uuid);
        DatabaseReference ref1 = reference.child("B1");
        ref1.set("!!"+finq);

        HomeCollection hc  = services["home.dart"];
        hc.changeQuoteState(QuoteState.SOLVED);

        DatabaseReference ref2 = reference.child("D1");
        
        int count = widget.state.pointscount;
        count = count + 10;

        ref2.set(count.toString()+"?"+(await getRealTime()).toString());

        



        widget.state.updatePoints(amount: count, time: await getRealTime());
        

      print("data :" +widget.state.srcx);

        if(widget.hw.resolver==null)widget.hw.setResolver(WideSpaceResolver(widget.state.srcx));
        widget.hw.resolver.updateQuoteSolve();
       //widget.hw.resolver.update();
        widget.state.resolveResolverChanges(widget.hw.resolver);


        

      

      }else{
        //wrong

        setState(() {
          err = true;
        });

        int timex = 0;

        Timer.periodic(Duration(milliseconds: 50), (va){
          setState(() {
            err=err;
          });
          if(timex==10){va.cancel();killText();}
          timex++;
        });

  

      }
    }
  }

  void killText(){
    for (var i = 0; i < failword.length; i++) {
          handleBackClick(i, controllers[i]);
        }
  }

}


