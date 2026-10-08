import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectad/algo/space.dart';
import 'package:projectad/data.dart';

import 'package:projectad/intent.dart';
import 'package:projectad/loading_gifs.dart';
import 'package:projectad/main.dart';
import 'package:projectad/friends.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/visual/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:intl/intl.dart' as intl;

import 'edit.dart';

class Account extends StatefulWidget {

  final Hws hw;
  final IntentX intentX;
  final StartLoadingWidgetBodyState state;

  Account(this.hw, this.state, this.intentX);


  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> with WidgetsBindingObserver, TickerProviderStateMixin{

  @override
  didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

  @override
  dispose() {
    //c.dispose();
    animationController.dispose();
    acc.dispose();
    super.dispose();
  }

  

  bool skinnull = true;
  

   check1() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    /*setState(() {
      this.edit = sp.getBool("account_built");
      
      if(edit==null){
        edit = false;
      }
      if(edit){*/

       // List<dynamic> data = jsonDecode(sp.getString(CloudCombinatorix.sourceControl1));

      //  this.userName = data[1];
      //  this.name = data[2];
        //this.path = sp.getString("account_imagepath");
        //skinnull = this.path==null;
    //  }else{
        //try resolving
        CloudCombinatorix.loadUNData().then((un_data) async {
          if(num.tryParse(un_data)!=null){

          //creator
          //
          //
          print("work");
          widget.state.updatePage(5, null);

        }else{



          List<dynamic> data = CloudCombinatorix.getUNDatas(un_data);

          String tag_data = data[0];

          if(data[6] != sp.getString("lastUpdate0")){

          TagHandler th = TagHandler();
          th.load().then((value){
            this.tags = th.loadTags(tag_data);
            if(tags.length == 0)tags.add(TagHandler.default$(context));
            this.tags.sort((s1,s2)  {
      return s1.text(context).length.compareTo(s2.text(context).length);
    });
    List<Tag> x = [];
            tags.forEach((element) {
              if(!x.contains(element)){
                x.add(element);
              }
            });
            this.tags = x;
          });



          this.userName = data[1];
          this.name = data[2];
          this.bio = data[3];
          this.hasProfilePic = data[4];
          
          this.privacy = data[5];
          this.time0 = data[6];
          if(hasProfilePic){
          this.profilePic = await ProfilePicManager().loadPic(time0);
          this.pb = Image.file(profilePic);
          }


          sp.setString(CloudCombinatorix.sourceControl1, jsonEncode(data));
          }
        }
        });

        setState(() {
          
        });
      
      //}
    //});
  }

  WideSpaceResolver wsr;
  bool hasProfilePic;
  String privacy;
  String time0;
  RequestHandler requestHandler;
  FriendHandler friendHandler;

  @override
   initState(){
    super.initState();

    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();
    //this.c = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    //this.a = Tween(end: 1.0, begin: 0.0).animate(c);

    this.currentStyle= widget.hw.currentstyle;
    List dss = widget.intentX.getValue("data");

    this.userName = dss[1];

    this.name = dss[2];
    
    this.bio = dss[3];
    if(bio == "")bio = "";
    bio = bio.replaceAll("", ",");

    this.hasProfilePic = dss[4];

    this.privacy = dss[5];

    this.time0 = dss[6];
    if(time0.endsWith("]"))time0 = time0.substring(0,time0.indexOf("]"));
  
    this.space_page = -1;

    SharedPreferences.getInstance().then((value){

      String s1 = value.getString(CloudCombinatorix.sourceControl1);
      String time1;
      List<dynamic> lis1;
      if(s1 != null && s1 != ""){
        lis1 = jsonDecode(s1);
      
      if((lis1[0] as String).startsWith("["))lis1[0] = (lis1[0] as String).substring((lis1[0] as String).indexOf("[")+1);

       time1 = lis1[6];
      if(time1.endsWith("]"))time1 = time1.substring(0,time1.indexOf("]"));
      print("hasPb"+hasProfilePic.toString());
      print(time1);
      }else time1 = "0";
    if(hasProfilePic){
      if(DateTime.fromMillisecondsSinceEpoch(num.parse(time1)).compareTo(DateTime.fromMillisecondsSinceEpoch(num.parse(time0)))!=0){

        //update profile picture
        
        ProfilePicManager().loadbyHard(value.getString("timeFileSub")).then((value1){
          setState(() {
                      this.profilePic = value1;
                      this.pb = Image.file(profilePic);
                      value.setString(CloudCombinatorix.sourceControl1, jsonEncode(dss));
          });
        });
        

      }else{

        ProfilePicManager().loadFromFile(value.getString("timeFileSub")).then((value) {
          setState(() {
                      this.profilePic = value;
                      this.pb = Image.file(profilePic);

          });
        });

      }
    }

    });

    TagHandler th = TagHandler();
      th.load().then((value){
 setState(() {
            this.tags = th.loadTags((dss[0] as String).substring(1) );
            if(tags.length == 0)tags.add(TagHandler.default$(context));
            List<Tag> x = [];
            tags.forEach((element) {
              if(!x.contains(element)){
                x.add(element);
              }
            });
            this.tags.sort((s1,s2)  {
      return s1.text(context).length.compareTo(s2.text(context).length);
    });
            this.tags = x;
      });
      });

    loadFriendAndRequests().then((lt) 
    {
      setState(() {
              this.requestHandler = lt[0];
              this.friendHandler = lt[1];
            });
    
    });
    

    initSpaceController().then((value) {
      this.space_page = 0;
      setState(() {
        
      });
    });

    ownRequestHandler = OwnRequestHandler();
    ownRequestHandler.init();


    //c.forward();
    //
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    acc = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    slideToRequest = Tween<Offset>(begin: Offset(1,0), end: Offset(0,0)).animate(acc);

    acc2 = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    slideToFriend = Tween<Offset>(begin: Offset(1,0), end: Offset(0,0)).animate(acc2);

    

    //sort tags
    

  
    

    animationController.forward();


   // check1();

  }
  
  String srcx;
  Future<void> initSpaceController() async{

    if(srcx != null)return;

    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("F");
    String src = (await reference.once()).value;
    this.srcx = src;
    print("loaded source:"+srcx);
    
   wsr = WideSpaceResolver(src);

    var temp = wsr;

    bool changed = false;

    SpaceCheck sc = SpaceCheck(wsr);
    if(sc.day()){
      wsr = wsr.clearDay(wsr);
      sc = SpaceCheck(wsr);
      changed = true;
    }
    if(sc.week()){
      wsr = wsr.clearWeek(wsr);
      sc = SpaceCheck(wsr);
       changed = true;
    }
    if(sc.month()){
      wsr = wsr.clearMonth(wsr);
      sc = SpaceCheck(wsr);
       changed = true;
    }

    print(wsr.prepareSource());

    if(temp.prepareSource$()==wsr.prepareSource$() && changed){

      wsr.update();

    }

   

    Hws hw = widget.hw;
    hw.setResolver(wsr);
    widget.hw.setResolver(wsr);
    widget.state.updateHws(hw);

    return;
  }

  List<OtherAccountState> states = [];



  
  Size sz,sz2;
  bool dark;
  double h,w;
  double th;

  bool edit = true;

  bool finished = false;

  int space_page; //0..3

  //AnimationController c;

  //Animation a;

//1627776000000



  //FlareController _controller; 
   Animation<Offset> _offsetAnimation;
   AnimationController animationController;

   Animation<Offset> slideToRequest;
   AnimationController acc;

   Animation<Offset> slideToFriend;
   AnimationController acc2;

  //values
  File profilePic;
  String name = "";
  String userName = "";
  String bio = "";
  List<Tag> tags = List.empty(growable: true);


  //swap
  bool firstEdit = true;
  bool edit_mode = false;
  bool requestLook = false;
  bool friendLook = false;
  
  //final
  Style currentStyle;
  TextEditingController edit_controller;

  Image pb;

  void updateRequest(RequestHandler n){
    requestHandler = n;
  }

  void updateFriend(FriendHandler n){
    friendHandler = n;
    states.forEach((element) {
      element.updateFriendHandler(n);
    });
  }

  OwnRequestHandler ownRequestHandler;

  int w3;

  @override
  Widget build(BuildContext context) {

    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    


    
    sz = (TextPainter(
        text: TextSpan(text: name, style: TextStyle(fontSize: th*31)),
        maxLines: 1,
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textDirection: TextDirection.ltr,
        )
      ..layout())
    .size;
 double w2 = 0 ;
      tags.forEach((element) {
         w2 +=  w/30 + w/50*element.text(context).length + w/44;
      });

      w2 += (tags.length-1)*w/50;

      //calculate the number of available fields
      //
      w3 = tags.length;
      if(!(w/1.075 - sz.width - w/44>= w2)){
        double w_temp = 0;
        for (var i = 0; i < tags.length; i++) {
          w_temp += w/30 + w/44*tags[i].text(context).length;

          if(!(w/1.075 - sz.width - w/44>= w_temp)){
            w3 = i;
            break;
          }

          if(i > 0 && i<tags.length-1)w_temp -= w/44;



        }

      }




            

    print(w3);
    print(w/1.057-sz.width);
    print(w/30+w/65*7);
    print(tags);
    


    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {  

        if(edit_mode)return;

        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 48;
        if (details.delta.dx > sensitivity) {
            // Right Swipe

            if(requestLook){
              killRequestPage(requestHandler);
              setState(() {
                              
                            });
              return;
            }
            if(friendLook){
              killFriendPage(friendHandler);
              setState(() {
                              
                            })
                            ;
                            return;
            }

             widget.state.updatePage(0, null);
        } else if(details.delta.dx < -sensitivity){
            //Left Swipe
           
        }
    },
        child: Container(height: h,width: w,
      color: dark?Colors.black:Colors.white,
      child: Stack(children:[
        
        Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        Container(height: h/23),

        Container(width: w,
          height: h/21,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/8,
              child: GestureDetector(
                onTap: (){
                  widget.state.updatePage(0, null);
                },
                child: Icon(Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,),)),
              Container(width: w/64,),
              Container(width: w/8, height: w/8,/*child: GestureDetector(
                onTap: (){
                  Navigator.push(context, cf.createRoute(widget.hw));
                },
                child: Icon(Icons.person_search_sharp, color: dark?Colors.white:Colors.black,)
              )*/),
              Container(width: w/64,),
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText("@"+userName, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),textAlign: TextAlign.center,),)),
              Container(width: w/6, height: w/8),
              Container(width: w/8,
              
               height: w/8, child: GestureDetector(
                onTap: (){
                  Navigator.push(context, createFRoute(widget.hw, friendHandler, userName,this));
                },
                child: Icon(Icons.search, color: dark?Colors.white:Colors.black,),))
            ]
          ),)),
      
        //Container(height: h/39),

      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
                        width: w,
        height: h/5.2,
        child: Row(
          children: <Widget> [
            Container(
              
              height: h/5,
              width: h/5,

              child: CircleAvatar(radius: 50.0,
              backgroundColor: dark?Colors.black:Colors.white,
              backgroundImage: profilePic == null || !hasProfilePic? null : FileImage(profilePic),
              child: profilePic == null  || !hasProfilePic? Icon(Icons.account_circle_rounded, size: h/5,color: Colors.grey[700],) : Container()),
            
            ),
            
            Center(child: Container(width: w/1.9,height: h/6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: w/1.9,
                  height: h/9,
                  
                  //friends & asks
                  child: Center(
                    child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                        Container(
                        //  color: Colors.red,
                        width: w/3.8,
                        height: h/9,
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.grey.withAlpha(50)),
                            
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      side: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(0.0))),
  ),
  
                          onPressed: (){
                           setState(() {
                                                        friendLook = true;
                                                        acc2.forward();
                                                      });
                          },
                          child: Column(children: [
                          //Container(height: h/36,),
                          Container(
                            width: w/5,
                            height: h/20,
                            child: Center(child: Column(children: <Widget>[
                              Container(height: h/70),
                              Container(
                                height: h/28,
                                child: Text(
                              friendHandler == null ? "0" : friendHandler.length().toString(),
                              style: TextStyle(fontSize: th * 37, color: (friendHandler == null || friendHandler.length().toString()=="0") ? Colors.grey : (dark?Colors.white:Colors.black)),
                              
                              textAlign: TextAlign.center,
                            ))])),
                          ),
                          Container(
                            height: h/24,
                            width: w/5,child: Center(child: 
                            Text(
                              AppLocalizations.of(widget.state.context).translateKey("s56_ "),
                              style: TextStyle(fontSize:  th * 24, color: dark?Colors.white:Colors.black),
                              textAlign: TextAlign.center,
                            )),
                          ),
                        
                        ],)
                      )),
                      TextButton(

                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.grey.withAlpha(50)),
                            
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      side: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(0.0))),
  ),
  
                          onPressed: (){
                            setState(() {
                              requestLook = true;
                              acc.forward();
                              
                                                        });
                          },child: Container(
                        width: w/5,
                        height: h/9,
                        child: Column(children: [
                          //Container(height: h/36,),
                          Container(
                            width: w/5,
                            height: h/20,
                            child: Center(child: Column(children: <Widget>[
                              Container(height: h/70),
                              Container(
                                height: h/28,
                                child: Text(
                              requestHandler == null ? "0" : requestHandler.length().toString(),
                              style: TextStyle(fontSize: th * 37, color: (requestHandler == null || requestHandler.length().toString()=="0") ? Colors.grey : (dark?Colors.white:Colors.black)),
                              
                              textAlign: TextAlign.center,
                            ))])),
                          ),
                          Container(
                            height: h/24,
                            width: w/3.8,child: Center(child: 
                            Text(
                              AppLocalizations.of(widget.state.context).translateKey("s58_ "),
                              style: TextStyle(fontSize:  th * 24, color: dark?Colors.white:Colors.black),
                              textAlign: TextAlign.center,
                            )),
                          ),
                        
                        ],)
                      ))
                    ]
                  )),
                ),
              
                GestureDetector(child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(33),
                              border: Border.all(color: dark?Colors.white:Colors.black, width: 2.5),

                  ),
                  child: Center(child: Text(
                    AppLocalizations.of(widget.state.context).translateKey("saas "),
                    style: TextStyle(fontSize:  th*25, color: dark?Colors.white:Colors.black)
                  )),
                  width: w/1.9,
                  height: h/22,
                  //edit
                ),
                onTap: (){

                  setState(() {
                    edit_mode = true;
                    ac++;
                  });
                  

                },
                )
              ]
            ),))
          ]
        ),),

        Center(child: Container(
          width: w/1.075,
          height: h/22,
          child: Row(
            children: <Widget>[
            Container(
            
            
              child: Text(

                name,
                maxLines: 1,
                style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*31),
                textAlign: TextAlign.left,



              ),
            ),
            Container(width: w/66,),
             w3==0?Container():Container(
              child: Container(
                height: h/22,
                width: w/1.057-sz.width-w/19,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  
                scrollDirection: Axis.horizontal,
                itemCount: w3,
                itemBuilder: (c,x){

                 return TagWidget(tags[x], widget.hw,(){showTagInfo(tags[x]);});


              }),
            ))
            ]
          ),
        )),
       w3 == tags.length?Container():Container(
         child: ShaderMask(
          shaderCallback: (Rect rect) {
            return w2 > w/1.075 ? LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.01, 0.99, 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect) : LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.0, 1.0 , 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,

 child: SizedBox(
                height: h/22,
                width: w/1.05,
                
                
                child: Center(child: ListView.builder(
                physics: RangeMaintainingScrollPhysics(),                  
                scrollDirection: Axis.horizontal,
                itemCount: tags.length-w3+1,
                itemBuilder: (c,x){
                  if(x == 0)return Container(width: w/100,height: 1,);
                  return TagWidget(tags[x+w3-1], widget.hw,(){showTagInfo(tags[x-1]);});


              })),
            ) 
       )),
        bio.length==0?Container(
          height: h/8,
          width: w/1.075,
           child: Text(
            AppLocalizations.of(context).translateKey("PO1 ")+intl.DateFormat("dd/MM/yyyy").format(FirebaseAuth.instance.currentUser.metadata.creationTime),
            style: TextStyle(fontSize: th * 19, color: dark?Colors.grey[400]:Colors.grey[900]),
            textAlign: TextAlign.left,


          ),
        ):Container(
          height: h/8,
          width: w/1.075,
        
          child: SizedBox(
            width: w/1.075,
            child: Text(
            bio,
            style: TextStyle(fontSize: th * 21, color: dark?Colors.white:Colors.black),
            textAlign: TextAlign.left,


          ),
        )),

        /*Container(
          height: h/25,
          width: w/1.075,
          child: Center(child: SizedBox(
            width: w/1.075,
            height: h/25,
            child: Text(
              AppLocalizations.of(context).translateKey("PO1 ") +    intl.DateFormat.yMd( Localizations.localeOf(context).languageCode).format(FirebaseAuth.instance.currentUser.metadata.creationTime)
,
              style: TextStyle(color: Colors.grey, fontSize:  th*17),
              textAlign: TextAlign.left,
            )
          ),),
        ),*/
        
        Container(
         // height: h/19.2+(w3!=tags.length?h/22:0) - h/24
        ),
        ])]),
        Positioned(bottom: 0,
        left: 0,
        right: 0,

          child: Column(children: [

        Container(
            height: h/12, width: w,
          child: dark?WaveWidget(
    config: CustomConfig(
      
        gradients: currentStyle.getListLight(),
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
      
        gradients: currentStyle.getListDark(),
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
    ))),
    Container(height: h/2.33, width: w, decoration: BoxDecoration(gradient: LinearGradient(colors: !dark?currentStyle.getListDark()[3]:currentStyle.getListLight()[3], begin: Alignment.centerLeft, end: Alignment.centerRight)), child: Center(
          
        child: Center(
          child: Container(
            width: w/1.05,
            height: h/2.1,
            child: Column(
              children: [
              Container(
                height: h/22,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children:[
                    GestureDetector(child: Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 0 ? dark?Colors.black:Colors.white : Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget.state.context).translateKey("s52_ "),
                          style: TextStyle(color: space_page == 0 ? (dark?Colors.white:Colors.black) : Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 0){
                        var tags0 = tags;
                        setState(() {
                          space_page = 0;
                          tags = tags0;
                        });
                      }
                    },
                    ),
                    Container(width: w/33,),
                    GestureDetector(child: Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 1 ? dark?Colors.black:Colors.white :Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget.state.context).translateKey("s53_ "),
                          style: TextStyle(color: space_page == 1 ? (dark?Colors.white:Colors.black) :Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 1){
                        var tags0 = tags;
                        setState(() {
                          space_page = 1;
                          tags = tags0;
                        });
                      }
                    },
                    ),
                     Container(width: w/33,),
                    GestureDetector(child:Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 2 ? dark?Colors.black:Colors.white :Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget.state.context).translateKey("s54_ "),
                          style: TextStyle(color: space_page == 2 ? (dark?Colors.white:Colors.black) :Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 2){
                        var tags0 = tags;
                        setState(() {
                          space_page = 2;
                          tags = tags0;
                        });
                      }
                    },
                    ),
                     Container(width: w/33,),
                    GestureDetector(child: Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 3? dark?Colors.black:Colors.white :Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget.state.context).translateKey("s55_ "),
                          style: TextStyle(color: space_page == 3 ? (dark?Colors.white:Colors.black) :Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 3){
                        setState(() {
                          space_page = 3;
                        });
                      }
                    },
                    )
                ]),
              ),
              Container(height: h/55,),

              space_page == 3 ? Center(child: Container(
                width: w/1.05,
                height: h/3,
                
                child: PageView.builder(itemBuilder: (x,o){

                  
                  Container c;
                  if(o == 0){
                  c = Container(
                    
                    child: Row(
                      
                    mainAxisAlignment: MainAxisAlignment.start,
                    
                    children: [

                      Container( child: SizedBox(
                        
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(wsr.quotesolvedstring, style: TextStyle(color: Colors.white, fontSize: th*180), 
                       
                        
                        maxLines: 2,textAlign: TextAlign.left,)),
                      )),

                      Container(
                        child: SizedBox(
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(AppLocalizations.of(context).translateKey("s172_"), style: TextStyle(color: Colors.white, fontSize: th*44), maxLines: 2,textAlign: TextAlign.left,))
                      ))


                  ],));
                  }else if(o == 1){
                    c = Container(
                    
                    child: Row(
                      
                    mainAxisAlignment: MainAxisAlignment.start,
                    
                    children: [

                      

                      Container(
                        child: SizedBox(
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(AppLocalizations.of(context).translateKey("s173_"), style: TextStyle(color: Colors.white, fontSize: th*44), maxLines: 2,textAlign: TextAlign.left,))
                      )),
                      Container( child: SizedBox(
                        
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(wsr.jokerusedstring, style: TextStyle(color: Colors.white, fontSize: th*180), 
                       
                        
                        maxLines: 2,textAlign: TextAlign.left,)),
                      )),


                  ],));
                  }else if(o == 2){
                    c = Container(
                    
                    child: Center(child: Column(
                      
                    mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [

                      

                      
                      Container( child: SizedBox(
                        
                        width: w/1.15,
                        height: h/7,
                        child: Center(child: Text((wsr.jokerusedint/wsr.quotesolvedint*100).round().toString()+"%", style: TextStyle(color: Colors.white, fontSize: th*170), 
                       
                        
                        maxLines: 2,textAlign: TextAlign.left,)),
                      )),
                      Container(
                        child: SizedBox(
                        
                        height: h/7,
                        child: Center(child: Text(AppLocalizations.of(context).translateKey("s174_"), style: TextStyle(color: Colors.white, fontSize: th*44), maxLines: 2,textAlign: TextAlign.center,))
                      )),


                  ],)));
                  }

                  


                  return Center(child: SizedBox(
                    width: w/1.05,
                    height: h/3,
                      child: c
                  ));

                  
                }, itemCount: 3),
              )):dataTableS()

          ],)
        ),

        ),




  
    


    )),
     
    ])),
    edit_mode?Edit(widget.hw, name, userName,bio, hasProfilePic ? profilePic : null, widget.state, this, tags, ac):Container(),
      requestLook ? SlideTransition(position: slideToRequest, child: RequestView(widget.hw, this.requestHandler, this)) : Container(),
      friendLook ?  SlideTransition(position: slideToFriend, child: FriendView(widget.hw, this.friendHandler, this)) : Container()
    ]))
        

    ));
  
  }

  

  killRequestPage(RequestHandler handler){

    
      setState(() {
              requestHandler = handler;
            });
    
          print(requestHandler.requests.length);
    
          acc.reverse().then((value) {
            setState(() {
                  requestLook = false;        
                        });
          });
        
  } 

  killFriendPage(FriendHandler handler){

      print("hello=?");

      setState(() {
             // friendHandler = handler;
            });
    
          //print(friendHandler.friends.length);
    
          acc2.reverse().then((value) {
            setState(() {
                  friendLook = false;        
                        });
          });
        
  } 

  int ac = 0;

  showTagInfo(Tag t){

    showDialog(context: context, builder: (x) => CupertinoDialogAction(
      isDestructiveAction: true,
      isDefaultAction:true,
      onPressed: (){
        Navigator.of(context).pop();
      },
      child: 
            Container(
        width: w/1.333,
        height: h/3.333,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          color: dark?Colors.black:Colors.white,
          boxShadow: [
            BoxShadow(color: dark?Colors.black:Colors.white,
            offset: Offset(-1,-1), blurRadius: 1.0, spreadRadius: 2.0),
          ]

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Transform.scale(scale: 1.2, child: TagWidget(t, widget.hw, (){})),
            Container(height: h/33),
            Center(child: Text(t.conditionText(context, null, false), style: TextStyle(color:!dark?Colors.black:Colors.white, fontSize: th* 28)),)
          ]
        ),
      )
    ));

  }

  
  void killEdit(String un_data) async{
    
    final String s0 = (await SharedPreferences.getInstance()).getString("timeFileSub");

    if(un_data != null){


      List<dynamic> data = CloudCombinatorix.getUNDatas(un_data);

          String tag_data = data[0];

          TagHandler th = TagHandler();
          th.load().then((value){
            this.tags = th.loadTags(tag_data);
            this.tags.sort((s1,s2)  {
      return s1.text(context).length.compareTo(s2.text(context).length);
    });
    List<Tag> x = [];
            tags.forEach((element) {
              if(!x.contains(element)){
                x.add(element);
              }
            });
            this.tags = x;
          });



          this.userName = data[1];
          this.name = data[2];
          this.bio = data[3];
          this.hasProfilePic = data[4];
          
          
          this.privacy = data[5];

          print("privacy:"+privacy);

          this.time0 = data[6];

          if(hasProfilePic){
          this.profilePic = await ProfilePicManager().loadFromFile(s0);
          this.pb = Image.file(profilePic);
          }
    
    }

    setState(() {
      edit_mode = false;
      ac++;
      if(hasProfilePic){
           ProfilePicManager().loadFromFile(s0).then((value) {profilePic=value;this.pb = Image.file(profilePic);});
      }
    });
    if(hasProfilePic){
      print("load898");
      print(profilePic);
      setState(() {
        hasProfilePic = false;
        this.pb = null;
      });
      setState(() {
        hasProfilePic = true;
       // this.pb = Image.file(profilePic);
      });
    }
  
  }

  List<SpaceEc> day_ec_list = [
    new SpaceEc("12",2)
  ];
  List<SpaceEc> week_ec_list = [
    new SpaceEc("Mon",0)
  ];
  List<SpaceEc> month_ec_list = [
    new SpaceEc("1.",0)
  ];

  List<SpaceEc> getDataS(){
    if(wsr == null)return List.filled(1, SpaceEc("0",0));
    if(space_page == 0)return transformDayList(wsr.daylist);
    if(space_page == 1)return transformWeekList(wsr.weeklist);
    if(space_page == 2)return transformMonthList(wsr.monthlist);
  }

  List<SpaceEc> transformDayList(List<int> li){
    List<SpaceEc> lsed = [];
    //12 values
    //from 0 to 22 o'clock -> 0 2 4, 6 8 10, 12 14 16, 18 20 22
    int hours = 0;
    wsr.daylist.forEach((element) {
      SpaceEc ec = new SpaceEc(hours.toString() + "h", element);
      lsed.add(ec);
       hours+=2;
    });

    print(lsed.toString());

    return lsed;
  }

   List<SpaceEc> transformWeekList(List<int> li){
    List<SpaceEc> lsed = [];
    //12 values
    //from 0 to 22 o'clock -> 0 2 4, 6 8 10, 12 14 16, 18 20 22
    
   // lsed.add(SpaceEc("s",1));

    int day = 1;
    wsr.weeklist.forEach((element) {
      SpaceEc ec = new SpaceEc(AppLocalizations.of(context).translateKey("days_"+day.toString()),element);
      lsed.add(ec);
      day++;
    });

    

    return lsed;
  }

   List<SpaceEc> transformMonthList(List<int> li){
    List<SpaceEc> lsed = [];
    //12 values
    //from 0 to 22 o'clock -> 0 2 4, 6 8 10, 12 14 16, 18 20 22
    int date = 1;
    wsr.monthlist.forEach((element) {
      SpaceEc ec = new SpaceEc(date.toString() + ".", element);
      lsed.add(ec);
      date+=1;
    });

    return lsed;
  }

  

  Widget dataTableS(){

    String var0 = AppLocalizations.of(widget.state.context).translateKey("s160_");
    String var1 = AppLocalizations.of(widget.state.context).translateKey("s161_");
    return SizedBox(
      height: h/2.88,
      child: SfCartesianChart(
      plotAreaBorderColor: Colors.transparent,
      plotAreaBackgroundColor: Colors.transparent,
      

      
            primaryXAxis: CategoryAxis(
            
            axisLine: AxisLine(
              color: dark?Colors.white:Colors.black
            ),
            majorGridLines: MajorGridLines(color:Colors.transparent),
            minorGridLines: MinorGridLines(color: Colors.transparent),
            minorTickLines: MinorTickLines(color: Colors.transparent),
            majorTickLines: MajorTickLines(color: Colors.transparent),
            plotOffset: 0.0,
            rangePadding: ChartRangePadding.none
      ),
      onAxisLabelRender: (args) { 
                    // checked the name of the axis/ 
                    if (args.axisName == 'primaryYAxis') { 
                      // Floored the axis label value and set to its text argument to render the axis labels in  
                      // integers in the chart. 
                      args.text = args.value.toString().contains(".0") ? args.value.floor().toString() : "";
                    } 
                    args.textStyle = TextStyle(color: dark?Colors.white:Colors.black);
                  }, 

      crosshairBehavior: CrosshairBehavior(enable: false),
      
      primaryYAxis: NumericAxis(axisLine: AxisLine(
              color: dark?Colors.white:Colors.black
            ),
            name: 'primaryYAxis', 
            decimalPlaces: 0,
            majorGridLines: MajorGridLines(

                                width: 1,
              color: !dark?Colors.grey[700].withAlpha(180):Colors.grey[400].withAlpha(180)),
            
            minorGridLines: MinorGridLines(color: Colors.transparent,),

            minorTickLines: MinorTickLines(color: Colors.transparent),
            majorTickLines: MajorTickLines(color: Colors.transparent),
            
        minimum: 0,
       // decimalPlaces: 0,
        //numberFormat: intl.NumberFormat.compactLong(),
                  ),
        
      title: ChartTitle(text: ""),
      legend: Legend(
        isVisible: false
      ),
      
      
    

      tooltipBehavior: TooltipBehavior( 
        enable: true,
        color: dark?Colors.black:Colors.white,
        
         builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
                  print(data);
                  SpaceEc sec = data;
                 
                  return Flexible(
                    child: Container(
                    width: w/2.5,
                    height: h/23,
                    decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(20.0),
                      color: dark?Colors.black:Colors.white,
                    ),
                    child: Center(child:Text(
                    (sec.qr_value!=0?sec.qr_value.toString():"0")+var0+sec.time_qr,
                      
                      textAlign: TextAlign.center,
                      style: TextStyle(color: dark?Colors.white:Colors.black),
                    ))
                  ));
                }
        ),
        
      series:  space_page == 0? <ColumnSeries<SpaceEc,String>>[
        ColumnSeries<SpaceEc, String>(

          animationDuration: 0,

          gradient: trans2(!dark?currentStyle.getRealColorDark():currentStyle.getRealColorLight()),

          dataSource: getDataS(),
          xValueMapper: (SpaceEc spec, _) => spec.time_qr,
        
          yValueMapper: (SpaceEc spec, _) => spec.qr_value
        )
      ]:<ChartSeries<SpaceEc,String>>[
        AreaSeries<SpaceEc, String>(

          animationDuration: 0,
          
          gradient:trans1(dark?currentStyle.getRealColorDark():currentStyle.getRealColorLight()) ,

          dataSource: getDataS(),
          xValueMapper: (SpaceEc spec, _) => spec.time_qr,
        
          yValueMapper: (SpaceEc spec, _) => spec.qr_value,
          //lowValueMapper: (SpaceEc spec, _) => -spec.,
        )
      ] ,
    ));
  }

  LinearGradient trans1(List<Color> colors){
   final List<Color> color = <Color>[];
        color.add(colors[0].withAlpha(120));
        color.add(colors[0]);

        final List<double> stops = <double>[];
        stops.add(0);
        stops.add(1.0);

        final LinearGradient gradientColors =
            LinearGradient(colors: color, stops: stops, begin: Alignment.bottomCenter, end: Alignment.topCenter);
    return gradientColors;
  } LinearGradient trans2(List<Color> colors){
   final List<Color> color = <Color>[];
        color.add(colors[0].withAlpha(254));
        color.add(colors[0]);

        final List<double> stops = <double>[];
        stops.add(0);
        stops.add(1.0);

        final LinearGradient gradientColors =
            LinearGradient(colors: color, stops: stops, begin: Alignment.bottomCenter, end: Alignment.topCenter);
    return gradientColors;
  }
}

class SpaceEc {
  SpaceEc(this.time_qr, this.qr_value);
  final String time_qr;
  final int qr_value;
  @override
  String toString() {
    // TODO: implement toString
    return time_qr + "/" +qr_value.toString();
  }
}

class OtherAccount extends StatefulWidget {

  final Hws hw;
  final AccountState _state;
  UnknownUser user;
  final int inCommit;
  //final UnknownUser user;

  OtherAccount(this.hw, this._state,  dynamic user, this.inCommit){
    if(user is Friend){
      Friend friend = user;
      this.user = UnknownUser(friend.fromUID);
      this.user.isFriend = true;
      this.user.lookup = friend.lookup;
    } else if(user is Request ){
      Request friend = user;
      this.user = UnknownUser(friend.fromUID);
      this.user.isFriend = false;
      this.user.lookup = friend.lookup;
    
    }else this.user = user;
  }


  @override
  OtherAccountState createState() => OtherAccountState();
}

class OtherAccountState extends State<OtherAccount> with WidgetsBindingObserver, TickerProviderStateMixin{

  @override
  didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

  @override
  dispose() {
    //c.dispose();
    animationController.dispose();
    acc.dispose();
    super.dispose();
  }

  

  bool skinnull = true;
  
  WideSpaceResolver wsr;
  bool hasProfilePic;
  String privacy;
  String time0;
  RequestHandler requestHandler;
  FriendHandler friendHandler;

  @override
   initState(){
    super.initState();

    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();
    //this.c = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    //this.a = Tween(end: 1.0, begin: 0.0).animate(c);

    this.currentStyle= widget.hw.currentstyle;

    this.userName = widget.user.lookup.username;

    this.name = widget.user.lookup.name;
    
    this.bio = widget.user.lookup.bio;
    if(bio == "")bio = "";
    bio = bio.replaceAll("", ",");

    this.hasProfilePic = widget.user.lookup.hasProfilePicture;

    this.privacy = "";

    this.time0 = widget.user.lookup.updateTime.toString();
  
    this.space_page = -1;

    this.friendHandler = widget._state.friendHandler;

    

    if(hasProfilePic){
     
      getApplicationDocumentsDirectory().then((value){
        if(File(value.path +"/"+"profilePic"+widget.user.fromUid).existsSync()){
          setState(() {
                      this.profilePic = File(value.path +"/"+"profilePic"+widget.user.fromUid);
                      this.pb = Image.file(profilePic);
                    });
        }
      });

        ProfilePicManager().loadbyHard2(widget.user.fromUid).then((value1){
          setState(() {
                      this.profilePic = value1;
                      this.pb = Image.file(profilePic);
          });
        });
        

      
      
    }



    TagHandler th = TagHandler();
      th.load().then((value){
 setState(() {
            this.tags = th.loadTags((widget.user.lookup.tagList));
            if(tags.length == 0)tags.add(TagHandler.default$(context));
            List<Tag> x = [];
            tags.forEach((element) {
              if(!x.contains(element)){
                x.add(element);
              }
            });
            this.tags.sort((s1,s2)  {
      return s1.text(context).length.compareTo(s2.text(context).length);
    });
            this.tags = x;
      });
      });

      loadFriends(widget.user.fromUid).then((value) {
        setState(() {
                  immigrant = value;
                });
      });



   /* loadFriendAndRequests().then((lt) 
    {
      setState(() {
              this.requestHandler = lt[0];
              this.friendHandler = lt[1];
            });
    
    });*/
    

    initSpaceController().then((value) {
      this.space_page = 0;
      setState(() {
        
      });
    });

    loadCoins();
    


    //c.forward();
    //
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    acc = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    slideToRequest = Tween<Offset>(begin: Offset(1,0), end: Offset(0,0)).animate(acc);

    acc2 = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    slideToFriend = Tween<Offset>(begin: Offset(1,0), end: Offset(0,0)).animate(acc2);

    

    //sort tags
    

  
    

    animationController.forward();


   // check1();

  }
  
  String srcx;
  Future<void> initSpaceController() async{

    if(srcx != null)return;

    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(widget.user.fromUid).child("F");
    String src = (await reference.once()).value;
    this.srcx = src;
    print("loaded source:"+srcx);
    
   wsr = WideSpaceResolver(src);

    var temp = wsr;

    bool changed = false;

    SpaceCheck sc = SpaceCheck(wsr);
    if(sc.day()){
      wsr = wsr.clearDay(wsr);
      sc = SpaceCheck(wsr);
      changed = true;
    }
    if(sc.week()){
      wsr = wsr.clearWeek(wsr);
      sc = SpaceCheck(wsr);
       changed = true;
    }
    if(sc.month()){
      wsr = wsr.clearMonth(wsr);
      sc = SpaceCheck(wsr);
       changed = true;
    }

    print(wsr.prepareSource());

    if(temp.prepareSource$()==wsr.prepareSource$() && changed){

      //wsr.update();
      print("no change needed");
    }

   


    return;
  }


  
  Size sz,sz2;
  bool dark;
  double h,w;
  double th;

  bool edit = true;

  bool finished = false;

  int space_page; //0..3

  //AnimationController c;

  //Animation a;

//1627776000000



  //FlareController _controller; 
   Animation<Offset> _offsetAnimation;
   AnimationController animationController;

   Animation<Offset> slideToRequest;
   AnimationController acc;

   Animation<Offset> slideToFriend;
   AnimationController acc2;

  //values
  File profilePic;
  String name = "";
  String userName = "";
  String bio = "";
  List<Tag> tags = List.empty(growable: true);


  //swap

  bool friendLook = false;
  
  //final
  Style currentStyle;
  TextEditingController edit_controller;

  Image pb;

  bool load = false;

  int w3;

  @override
  Widget build(BuildContext context) {

    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    


    
    sz = (TextPainter(
        text: TextSpan(text: name, style: TextStyle(fontSize: th*31)),
        maxLines: 1,
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textDirection: TextDirection.ltr,
        )
      ..layout())
    .size;
 double w2 = 0 ;
      tags.forEach((element) {
         w2 +=  w/30 + w/50*element.text(context).length + w/44;
      });

      w2 += (tags.length-1)*w/50;

      //calculate the number of available fields
      //
      w3 = tags.length;
      if(!(w/1.075 - sz.width - w/44>= w2)){
        double w_temp = 0;
        for (var i = 0; i < tags.length; i++) {
          w_temp += w/30 + w/44*tags[i].text(context).length;

          if(!(w/1.075 - sz.width - w/44>= w_temp)){
            w3 = i;
            break;
          }

          if(i > 0 && i<tags.length-1)w_temp -= w/44;



        }

      }




            

    print(w3);
    print(w/1.057-sz.width);
    print(w/30+w/65*7);
    print(tags);
    


    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {  

       

        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 48;
        if (details.delta.dx > sensitivity) {
            // Right Swipe

           
            if(friendLook){
              killFriendPage(friendHandler);
              setState(() {
                              
                            })
                            ;
                            return;
            }

        //     widget._state.updatePage(0, null);
        } else if(details.delta.dx < -sensitivity){
            //Left Swipe
           
        }
    },
        child: Container(height: h,width: w,
      color: dark?Colors.black:Colors.white,
      child: Stack(children:[
        
        Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        Container(height: h/23),

        Container(width: w,
          height: h/21,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/8,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,),)),
              Container(width: w/64,),
              Container(width: w/8, height: w/8,/*child: GestureDetector(
                onTap: (){
                  Navigator.push(context, cf.createRoute(widget.hw));
                },
                child: Icon(Icons.person_search_sharp, color: dark?Colors.white:Colors.black,)
              )*/),
              Container(width: w/64,),
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText("@"+userName, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),textAlign: TextAlign.center,),)),
              Container(width: w/6, height: w/8),
              Container(width: w/8,
              
               height: w/8, child: GestureDetector(
                onTap: (){
                //  Navigator.push(context, createFRoute(widget.hw, friendHandler, userName,this));
                },
              ))
            ]
          ),)),
      
        //Container(height: h/39),

      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
                        width: w,
        height: h/5.2,
        child: Row(
          children: <Widget> [
            Container(
              
              height: h/5,
              width: h/5,

              child: CircleAvatar(radius: 50.0,
              backgroundColor: dark?Colors.black:Colors.white,
              backgroundImage: profilePic == null || !hasProfilePic? null : FileImage(profilePic),
              child: profilePic == null  || !hasProfilePic? Icon(Icons.account_circle_rounded, size: h/5,color: Colors.grey[700],) : Container()),
            
            ),
            
            Center(child: Container(width: w/1.9,height: h/6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: w/1.9,
                  height: h/9,
                  
                  //friends & asks
                  child: Center(
                    child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                        Container(
                        //  color: Colors.red,
                        width: w/3.8,
                        height: h/9,
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.grey.withAlpha(50)),
                            
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      side: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(0.0))),
  ),
  
                          onPressed: (){
                           setState(() {
                                                        friendLook = true;
                                                        acc2.forward();
                                                      });
                          },
                          child: Column(children: [
                          //Container(height: h/36,),
                          Container(
                            width: w/5,
                            height: h/20,
                            child: Center(child: Column(children: <Widget>[
                              Container(height: h/70),
                              Container(
                                height: h/28,
                                child: Text(
                              immigrant == null ? "0" : immigrant.length().toString(),
                              style: TextStyle(fontSize: th * 37, color: (immigrant == null || immigrant.length().toString()=="0") ? Colors.grey : (dark?Colors.white:Colors.black)),
                              
                              textAlign: TextAlign.center,
                            ))])),
                          ),
                          Container(
                            height: h/24,
                            width: w/5,child: Center(child: 
                            Text(
                              AppLocalizations.of(widget._state.context).translateKey("s56_ "),
                              style: TextStyle(fontSize:  th * 24, color: dark?Colors.white:Colors.black),
                              textAlign: TextAlign.center,
                            )),
                          ),
                        
                        ],)
                      )),
                      TextButton(

                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.grey.withAlpha(0)),
                            
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      side: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(0.0))),
  ),
  
                          onPressed: (){
                            
                          },child: Container(
                        width: w/5,
                        height: h/9,
                        child: Column(children: [
                          //Container(height: h/36,),
                          Container(
                            width: w/5,
                            height: h/20,
                            child: Center(child: Column(children: <Widget>[
                              Container(height: h/70),
                              Container(
                                height: h/28,
                                child: Text(
                              coinData,
                              style: TextStyle(fontSize: th * 37, color:  (dark?Colors.white:Colors.black)),
                              
                              textAlign: TextAlign.center,
                            ))])),
                          ),
                          Container(
                            height: h/24,
                            width: w/3.8,child: Center(child: 
                            Text(
                              "QuoteP",
                              style: TextStyle(fontSize:  th * 24, color: dark?Colors.white:Colors.black),
                              textAlign: TextAlign.center,
                            )),
                          ),
                        
                        ],)
                      ))
                    ]
                  )),
                ),
              
                load ? Container(width: w/12,height: w/12,child: Image.asset(cupertinoLoadingGifSmall),)  : SwitchConnectionButton(
                  widget.hw,
                  firstImp: widget.inCommit,
                  otFunc: true,
                  onAction: (){
                    setState(() {
                                          load = false;
                                        });
                  },
                  offAction: (){
                    setState(() {
                                          load = false;
                                        });
                  },
                  uid0: widget.user.fromUid,
                  handlerUpdate: (x){
                    widget._state.updateFriend(x);
                  },
                  friendHandler: friendHandler,
                )
              ]
            ),))
          ]
        ),),

        Center(child: Container(
          width: w/1.075,
          height: h/22,
          child: Row(
            children: <Widget>[
            Container(
            
            
              child: Text(

                name,
                maxLines: 1,
                style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*31),
                textAlign: TextAlign.left,



              ),
            ),
            Container(width: w/66,),
             w3==0?Container():Container(
              child: Container(
                height: h/22,
                width: w/1.057-sz.width-w/19,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  
                scrollDirection: Axis.horizontal,
                itemCount: w3,
                itemBuilder: (c,x){

                 return TagWidget(tags[x], widget.hw,(){showTagInfo(tags[x]);});


              }),
            ))
            ]
          ),
        )),
       w3 == tags.length?Container():Container(
         child: ShaderMask(
          shaderCallback: (Rect rect) {
            return w2 > w/1.075 ? LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.01, 0.99, 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect) : LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.0, 1.0 , 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,

 child: SizedBox(
                height: h/22,
                width: w/1.05,
                
                
                child: Center(child: ListView.builder(
                physics: RangeMaintainingScrollPhysics(),                  
                scrollDirection: Axis.horizontal,
                itemCount: tags.length-w3+1,
                itemBuilder: (c,x){
                  if(x == 0)return Container(width: w/100,height: 1,);
                  return TagWidget(tags[x+w3-1], widget.hw,(){showTagInfo(tags[x-1]);});


              })),
            ) 
       )),
        bio.length==0?Container(
          height: h/8,
          width: w/1.075,
           child: Text(
            AppLocalizations.of(context).translateKey("PO1 ")+intl.DateFormat("dd/MM/yyyy").format(FirebaseAuth.instance.currentUser.metadata.creationTime),
            style: TextStyle(fontSize: th * 19, color: dark?Colors.grey[400]:Colors.grey[900]),
            textAlign: TextAlign.left,


          ),
        ):Container(
          height: h/8,
          width: w/1.075,
        
          child: SizedBox(
            width: w/1.075,
            child: Text(
            bio,
            style: TextStyle(fontSize: th * 21, color: dark?Colors.white:Colors.black),
            textAlign: TextAlign.left,


          ),
        )),

        /*Container(
          height: h/25,
          width: w/1.075,
          child: Center(child: SizedBox(
            width: w/1.075,
            height: h/25,
            child: Text(
              AppLocalizations.of(context).translateKey("PO1 ") +    intl.DateFormat.yMd( Localizations.localeOf(context).languageCode).format(FirebaseAuth.instance.currentUser.metadata.creationTime)
,
              style: TextStyle(color: Colors.grey, fontSize:  th*17),
              textAlign: TextAlign.left,
            )
          ),),
        ),*/
        
        Container(
         // height: h/19.2+(w3!=tags.length?h/22:0) - h/24
        ),
        ])]),
        Positioned(bottom: 0,
        left: 0,
        right: 0,

          child: Column(children: [

        Container(
            height: h/12, width: w,
          child: dark?WaveWidget(
    config: CustomConfig(
      
        gradients: currentStyle.getListLight(),
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
      
        gradients: currentStyle.getListDark(),
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
    ))),
    Container(height: h/2.33, width: w, decoration: BoxDecoration(gradient: LinearGradient(colors: !dark?currentStyle.getListDark()[3]:currentStyle.getListLight()[3], begin: Alignment.centerLeft, end: Alignment.centerRight)), child: Center(
          
        child: Center(
          child: Container(
            width: w/1.05,
            height: h/2.1,
            child: Column(
              children: [
              Container(
                height: h/22,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children:[
                    GestureDetector(child: Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 0 ? dark?Colors.black:Colors.white : Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget._state.context).translateKey("s52_ "),
                          style: TextStyle(color: space_page == 0 ? (dark?Colors.white:Colors.black) : Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 0){
                        var tags0 = tags;
                        setState(() {
                          space_page = 0;
                          tags = tags0;
                        });
                      }
                    },
                    ),
                    Container(width: w/33,),
                    GestureDetector(child: Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 1 ? dark?Colors.black:Colors.white :Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget._state.context).translateKey("s53_ "),
                          style: TextStyle(color: space_page == 1 ? (dark?Colors.white:Colors.black) :Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 1){
                        var tags0 = tags;
                        setState(() {
                          space_page = 1;
                          tags = tags0;
                        });
                      }
                    },
                    ),
                     Container(width: w/33,),
                    GestureDetector(child:Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 2 ? dark?Colors.black:Colors.white :Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget._state.context).translateKey("s54_ "),
                          style: TextStyle(color: space_page == 2 ? (dark?Colors.white:Colors.black) :Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 2){
                        var tags0 = tags;
                        setState(() {
                          space_page = 2;
                          tags = tags0;
                        });
                      }
                    },
                    ),
                     Container(width: w/33,),
                    GestureDetector(child: Container(
                      width: w/5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        color:space_page == 3? dark?Colors.black:Colors.white :Colors.grey[850].withAlpha(151)
                      ),
                      child: Center(
                        child:Text(
                          AppLocalizations.of(widget._state.context).translateKey("s55_ "),
                          style: TextStyle(color: space_page == 3 ? (dark?Colors.white:Colors.black) :Colors.white, fontSize: th * 29),
                          textAlign: TextAlign.center,
                  
                        )
                      ),
                    ),
                    onTap: (){
                      if(space_page != 3){
                        setState(() {
                          space_page = 3;
                        });
                      }
                    },
                    )
                ]),
              ),
              Container(height: h/55,),

              space_page == 3 ? Center(child: Container(
                width: w/1.05,
                height: h/3,
                
                child: PageView.builder(itemBuilder: (x,o){

                  
                  Container c;
                  if(o == 0){
                  c = Container(
                    
                    child: Row(
                      
                    mainAxisAlignment: MainAxisAlignment.start,
                    
                    children: [

                      Container( child: SizedBox(
                        
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(wsr.quotesolvedstring, style: TextStyle(color: Colors.white, fontSize: th*180), 
                       
                        
                        maxLines: 2,textAlign: TextAlign.left,)),
                      )),

                      Container(
                        child: SizedBox(
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(AppLocalizations.of(context).translateKey("s172_"), style: TextStyle(color: Colors.white, fontSize: th*44), maxLines: 2,textAlign: TextAlign.left,))
                      ))


                  ],));
                  }else if(o == 1){
                    c = Container(
                    
                    child: Row(
                      
                    mainAxisAlignment: MainAxisAlignment.start,
                    
                    children: [

                      

                      Container(
                        child: SizedBox(
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(AppLocalizations.of(context).translateKey("s173_"), style: TextStyle(color: Colors.white, fontSize: th*44), maxLines: 2,textAlign: TextAlign.left,))
                      )),
                      Container( child: SizedBox(
                        
                        width: w/1.15/2,
                        height: h/3,
                        child: Center(child: Text(wsr.jokerusedstring, style: TextStyle(color: Colors.white, fontSize: th*180), 
                       
                        
                        maxLines: 2,textAlign: TextAlign.left,)),
                      )),


                  ],));
                  }else if(o == 2){
                    c = Container(
                    
                    child: Center(child: Column(
                      
                    mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [

                      

                      
                      Container( child: SizedBox(
                        
                        width: w/1.15,
                        height: h/7,
                        child: Center(child: Text((wsr.jokerusedint/wsr.quotesolvedint*100).round().toString()+"%", style: TextStyle(color: Colors.white, fontSize: th*170), 
                       
                        
                        maxLines: 2,textAlign: TextAlign.left,)),
                      )),
                      Container(
                        child: SizedBox(
                        
                        height: h/7,
                        child: Center(child: Text(AppLocalizations.of(context).translateKey("s174_"), style: TextStyle(color: Colors.white, fontSize: th*44), maxLines: 2,textAlign: TextAlign.center,))
                      )),


                  ],)));
                  }

                  


                  return Center(child: SizedBox(
                    width: w/1.05,
                    height: h/3,
                      child: c
                  ));

                  
                }, itemCount: 3),
              )):dataTableS()

          ],)
        ),

        ),




  
    


    )),
     
    ])),
    
      friendLook ?  SlideTransition(position: slideToFriend, child: FriendView(widget.hw, this.friendHandler, widget._state,immigrantState: this, immigrant: this.immigrant)) : Container()
    ]))
        

    ));
  
  }

  String coinData = "?";

  void loadCoins()async{

    var d = await FirebaseDatabase.instance.reference().child("Users").child(widget.user.fromUid).child("D1").once();
    String s = d.value;
    s = s.substring(0, s.indexOf("?"));

    int i = int.parse(s);

    if(i < 50 ){
      setState(() {
              coinData = "~50";
            });
    }else if(i < 100 ){
      setState(() {
              coinData = "~100";
            });
    }else if(i < 500 ){
      setState(() {
              coinData = "~500";
            });
    }else if(i < 1000 ){
      setState(() {
              coinData = "~1K";
            });
    }else if(i < 5000 ){
      setState(() {
              coinData = "~5K";
            });
    }else if(i < 25000 ){
      setState(() {
              coinData = "~25K";
            });
    }else if(i < 100000 ){
      setState(() {
              coinData = "~100K";
            });
    }else if(i < 250000 ){
      setState(() {
              coinData = "~250K";
            });
    }else if(i < 500000 ){
      setState(() {
              coinData = "~500K";
            });
    }else if(i < 750000 ){
      setState(() {
              coinData = "~750K";
            });
    }else if(i < 1000000 ){
      setState(() {
              coinData = "~1mil";
            });
    }else if(i < 2000000 ){
      setState(() {
              coinData = "~2mil";
            });
    }else if(i < 5000000 ){
      setState(() {
              coinData = "~5mil";
            });
    }else if(i < 10000000 ){
      setState(() {
              coinData = "~10mil";
            });
    }else if(i < 10000000 ){
      setState(() {
              coinData = "~100mil";
            });
    }else if(i < 1000000000 ){
      setState(() {
              coinData = "~1mrd";
            });
    }else {
      setState(() {
              coinData = ">1mrd";
            });
    }


  }

  void updateFriendHandler(FriendHandler n){
    setState(() {
          friendHandler = n;
        });
  }

  FriendHandler immigrant;



  killFriendPage(FriendHandler handler){

      print("hello=?");

      setState(() {
             // friendHandler = handler;
            });
    
          //print(friendHandler.friends.length);
    
          acc2.reverse().then((value) {
            setState(() {
                  friendLook = false;        
                        });
          });
        
  } 

  int ac = 0;

  showTagInfo(Tag t){

    showDialog(context: context, builder: (x) => CupertinoDialogAction(
      isDestructiveAction: true,
      isDefaultAction:true,
      onPressed: (){
        Navigator.of(context).pop();
      },
      child: 
            Container(
        width: w/1.333,
        height: h/3.333,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          color: dark?Colors.black:Colors.white,
          boxShadow: [
            BoxShadow(color: dark?Colors.black:Colors.white,
            offset: Offset(-1,-1), blurRadius: 1.0, spreadRadius: 2.0),
          ]

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Transform.scale(scale: 1.2, child: TagWidget(t, widget.hw, (){})),
            Container(height: h/33),
            Center(child: Text(t.conditionText(context, null, false), style: TextStyle(color:!dark?Colors.black:Colors.white, fontSize: th* 28)),)
          ]
        ),
      )
    ));

  }

  
  
  List<SpaceEc> day_ec_list = [
    new SpaceEc("12",2)
  ];
  List<SpaceEc> week_ec_list = [
    new SpaceEc("Mon",0)
  ];
  List<SpaceEc> month_ec_list = [
    new SpaceEc("1.",0)
  ];

  List<SpaceEc> getDataS(){
    if(wsr == null)return List.filled(1, SpaceEc("0",0));
    if(space_page == 0)return transformDayList(wsr.daylist);
    if(space_page == 1)return transformWeekList(wsr.weeklist);
    if(space_page == 2)return transformMonthList(wsr.monthlist);
  }

  List<SpaceEc> transformDayList(List<int> li){
    List<SpaceEc> lsed = [];
    //12 values
    //from 0 to 22 o'clock -> 0 2 4, 6 8 10, 12 14 16, 18 20 22
    int hours = 0;
    wsr.daylist.forEach((element) {
      SpaceEc ec = new SpaceEc(hours.toString() + "h", element);
      lsed.add(ec);
       hours+=2;
    });

    print(lsed.toString());

    return lsed;
  }

   List<SpaceEc> transformWeekList(List<int> li){
    List<SpaceEc> lsed = [];
    //12 values
    //from 0 to 22 o'clock -> 0 2 4, 6 8 10, 12 14 16, 18 20 22
    
   // lsed.add(SpaceEc("s",1));

    int day = 1;
    wsr.weeklist.forEach((element) {
      SpaceEc ec = new SpaceEc(AppLocalizations.of(context).translateKey("days_"+day.toString()),element);
      lsed.add(ec);
      day++;
    });

    

    return lsed;
  }

   List<SpaceEc> transformMonthList(List<int> li){
    List<SpaceEc> lsed = [];
    //12 values
    //from 0 to 22 o'clock -> 0 2 4, 6 8 10, 12 14 16, 18 20 22
    int date = 1;
    wsr.monthlist.forEach((element) {
      SpaceEc ec = new SpaceEc(date.toString() + ".", element);
      lsed.add(ec);
      date+=1;
    });

    return lsed;
  }

  

  Widget dataTableS(){

    String var0 = AppLocalizations.of(widget._state.context).translateKey("s160_");
    String var1 = AppLocalizations.of(widget._state.context).translateKey("s161_");
    return SizedBox(
      height: h/2.88,
      child: SfCartesianChart(
      plotAreaBorderColor: Colors.transparent,
      plotAreaBackgroundColor: Colors.transparent,
      

      
            primaryXAxis: CategoryAxis(
            
            axisLine: AxisLine(
              color: dark?Colors.white:Colors.black
            ),
            majorGridLines: MajorGridLines(color:Colors.transparent),
            minorGridLines: MinorGridLines(color: Colors.transparent),
            minorTickLines: MinorTickLines(color: Colors.transparent),
            majorTickLines: MajorTickLines(color: Colors.transparent),
            plotOffset: 0.0,
            rangePadding: ChartRangePadding.none
      ),
      onAxisLabelRender: (args) { 
                    // checked the name of the axis/ 
                    if (args.axisName == 'primaryYAxis') { 
                      // Floored the axis label value and set to its text argument to render the axis labels in  
                      // integers in the chart. 
                      args.text = args.value.toString().contains(".0") ? args.value.floor().toString() : "";
                    } 
                    args.textStyle = TextStyle(color: dark?Colors.white:Colors.black);
                  }, 

      crosshairBehavior: CrosshairBehavior(enable: false),
      
      primaryYAxis: NumericAxis(axisLine: AxisLine(
              color: dark?Colors.white:Colors.black
            ),
            name: 'primaryYAxis', 
            decimalPlaces: 0,
            majorGridLines: MajorGridLines(

                                width: 1,
              color: !dark?Colors.grey[700].withAlpha(180):Colors.grey[400].withAlpha(180)),
            
            minorGridLines: MinorGridLines(color: Colors.transparent,),

            minorTickLines: MinorTickLines(color: Colors.transparent),
            majorTickLines: MajorTickLines(color: Colors.transparent),
            
        minimum: 0,
       // decimalPlaces: 0,
        //numberFormat: intl.NumberFormat.compactLong(),
                  ),
        
      title: ChartTitle(text: ""),
      legend: Legend(
        isVisible: false
      ),
      
      
    

      tooltipBehavior: TooltipBehavior( 
        enable: true,
        color: dark?Colors.black:Colors.white,
        
         builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
                  print(data);
                  SpaceEc sec = data;
                 
                  return Flexible(
                    child: Container(
                    width: w/2.5,
                    height: h/23,
                    decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(20.0),
                      color: dark?Colors.black:Colors.white,
                    ),
                    child: Center(child:Text(
                    (sec.qr_value!=0?sec.qr_value.toString():"0")+var0+sec.time_qr,
                      
                      textAlign: TextAlign.center,
                      style: TextStyle(color: dark?Colors.white:Colors.black),
                    ))
                  ));
                }
        ),
        
      series:  space_page == 0? <ColumnSeries<SpaceEc,String>>[
        ColumnSeries<SpaceEc, String>(

          animationDuration: 0,

          gradient: trans2(!dark?currentStyle.getRealColorDark():currentStyle.getRealColorLight()),

          dataSource: getDataS(),
          xValueMapper: (SpaceEc spec, _) => spec.time_qr,
        
          yValueMapper: (SpaceEc spec, _) => spec.qr_value
        )
      ]:<ChartSeries<SpaceEc,String>>[
        AreaSeries<SpaceEc, String>(

          animationDuration: 0,
          
          gradient:trans1(dark?currentStyle.getRealColorDark():currentStyle.getRealColorLight()) ,

          dataSource: getDataS(),
          xValueMapper: (SpaceEc spec, _) => spec.time_qr,
        
          yValueMapper: (SpaceEc spec, _) => spec.qr_value,
          //lowValueMapper: (SpaceEc spec, _) => -spec.,
        )
      ] ,
    ));
  }

  LinearGradient trans1(List<Color> colors){
   final List<Color> color = <Color>[];
        color.add(colors[0].withAlpha(120));
        color.add(colors[0]);

        final List<double> stops = <double>[];
        stops.add(0);
        stops.add(1.0);

        final LinearGradient gradientColors =
            LinearGradient(colors: color, stops: stops, begin: Alignment.bottomCenter, end: Alignment.topCenter);
    return gradientColors;
  } LinearGradient trans2(List<Color> colors){
   final List<Color> color = <Color>[];
        color.add(colors[0].withAlpha(254));
        color.add(colors[0]);

        final List<double> stops = <double>[];
        stops.add(0);
        stops.add(1.0);

        final LinearGradient gradientColors =
            LinearGradient(colors: color, stops: stops, begin: Alignment.bottomCenter, end: Alignment.topCenter);
    return gradientColors;
  }
}

Route createZRoute(Hws hw, FriendHandler friendHandler, AccountState state, dynamic user, int i){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OtherAccount(hw, state, user, i),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin,   end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

