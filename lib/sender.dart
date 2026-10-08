import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectad/main.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'intent.dart';
import 'mail.dart';

class Sender extends StatefulWidget {

  Hws hw;

  IntentX intentX;

  Sender(this.hw, this.state, this.intentX);

  StartLoadingWidgetBodyState state;
  
  @override
  _SenderState createState() => _SenderState();
}

class _SenderState extends State<Sender> with WidgetsBindingObserver, TickerProviderStateMixin{

  double w=0,h=0,th=0;

  bool dark = false;

   AnimationController controller1, controller2, controller3;
  Animation a1, a2, a3;

  TextEditingController namec1,namec2;

  @override

  void initState() {
    super.initState();
    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();

    this.controller1 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    this.controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    this.controller3 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    this.namec1 = TextEditingController();
    this.namec2 = TextEditingController();

    this.a1 = Tween(begin: 0.0, end: 1.0).animate(controller1);
    this.a2 = Tween(begin: 0.0, end: 1.0).animate(controller2);
    this.a3 = Tween(begin: 0.0, end: 1.0).animate(controller3);



  }

  int count = 0;
  int count2 = 0;

  @override
  Widget build(BuildContext context) {
    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    return Scaffold(
      body: Container(width: w,height: h,
      color: dark?Colors.black:Colors.white,
      child: Stack(children: [

        Positioned(

          left: w/10,
          top: h/10,

          
          child: GestureDetector(child: Icon(Icons.close, color: Colors.grey,),onTap: (){

          widget.state.updatePage(1, widget.intentX);

        },)),

        Positioned(

          top: h/4,
          left: w/8,
          
          child: Column(children: [

            Container(
              height: h/12,
              width: w/8*6,
              child: new Theme(
                data: new ThemeData(
                  primaryColor: Colors.grey,
                  accentColor: Colors.grey,
                  hintColor: Colors.grey
                ),
                child: TextField(

                
                
                cursorColor: dark?Colors.white:Colors.black,
                controller: namec1,
                
                style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*35),
                showCursor: true,
                onChanged: (s){
                  setState(() {
                                      this.count=s.length;

                  });
                },
                decoration: InputDecoration(
                  
                  border: new UnderlineInputBorder(
                    
        borderSide: new BorderSide(
          
          color: dark?Colors.white:Colors.black
        )
      ),
      
                  hintText: AppLocalizations.of(context).translateKey("s123_ "),
                  hintStyle: TextStyle(color:Colors.grey),
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent
                  

                ),

            ))),
            Container(height: h/20,
            child: AutoSizeText(this.count.toString()+"/30", style: TextStyle(color: Colors.grey),),),
            Container(
              height: h/12,
              width: w/8*6,
              child: Theme(
                data: ThemeData(hintColor: Colors.transparent, accentColor: Colors.transparent, primaryColor: Colors.transparent),
                child: TextField(
                cursorColor: dark?Colors.white:Colors.black,
                controller: namec2,
                style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*35),
                showCursor: true,
                onChanged: (s){
                  setState(() {
                                     this.count2=s.length;
 
                  });
                },
                
                decoration: InputDecoration(
                  
                  hintText: AppLocalizations.of(context).translateKey("s124_ "),
                  hintStyle: TextStyle(color:Colors.grey),
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  border: new UnderlineInputBorder(
        borderSide: new BorderSide(
          color: dark?Colors.white:Colors.black
        )
      ),

                ),

            ))),
            Container(height: h/20,
            child: AutoSizeText(this.count2.toString()+"/300", style: TextStyle(color: Colors.grey),),),

            Container(height: h/7,),

            GestureDetector(
              onTap: () async{

                SharedPreferences sp = await SharedPreferences.getInstance();

                int lasttime = sp.getInt("companyt");

                if(lasttime
                ==null)lasttime = 0;

                //time interference 3 min

                if(lasttime+180000<DateTime.now().millisecondsSinceEpoch){

                if(namec1.text.length>2 && namec1.text.length<30 && namec2.text.length>30 && namec2.text.length<300){

                  if(lasttime+180000<DateTime.now().millisecondsSinceEpoch){

                    sp.setInt("companyt", DateTime.now().millisecondsSinceEpoch);

                await MailS().sends("Company access:"+namec1.text, "Name: "+namec1.text+"\n Message: "+namec2.text);
                widget.state.updatePage(1, widget.intentX);

                

                }
                }
                }
                
              },
              
              child: Container(
              width: w/1.5,
              height: h/12,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(90),
              color: dark?Colors.white:Colors.black),
              child: Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("s125_ "),textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: th*45),),),
            ),)

        ],))

      ],),),
    );
  }
}