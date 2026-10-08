import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectad/main.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/visual/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatefulWidget {

  StartLoadingWidgetBodyState state;

  Hws hw;

  Setting(this.hw, this.state);


  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> with WidgetsBindingObserver, TickerProviderStateMixin{

  double w=0,h=0,th=0;

   bool dark;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

@override
  void dispose()   {
    animationController.dispose();
    c1.dispose();
    c2.dispose();
    c3.dispose();
    c4.dispose();
    
    super.dispose();
  }



  void load() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    currentStyle = Style.fromId(sp.getInt("style_id"));
    
  }

  @override
  void initState() {
    super.initState();

    this.w = widget.hw.getWidth();
    this.h = widget.hw.getHeight();
    this.th = widget.hw.getTH();

    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    loadStyle();

    animationController.forward();

    c1 = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    c2 = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    c3 = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    c4 = AnimationController(vsync: this, duration: Duration(milliseconds: 333));

    fade1 = Tween(begin: 0.0, end:1.0).animate(c1);
    fade2 = Tween(begin: 0.0, end:1.0).animate(c2);
    fade3 = Tween(begin: 0.0, end:1.0).animate(c3);
    fade4 = Tween(begin: 0.0, end:1.0).animate(c4);

    c1.forward().then((value){
c2.forward().then((value){
  c3.forward();
});
    });



  }

  


   Animation fade1;
   Animation fade2;
   Animation fade3;
  Animation fade4;
   AnimationController c1;
   AnimationController c2;
   AnimationController c3;
   AnimationController c4;


   Animation<Offset> _offsetAnimation;
   AnimationController animationController;

  int attachedcolor = 0;
  Style currentStyle;

  void loadStyle(){
    currentStyle = widget.hw.currentstyle;
  }

  Style colorstylesync(int i){
    switch(i){
      case 0: return Style.red;
      case 1: return Style.yellow;
      case 2: return Style.green;
      case 3: return Style.blue;
    }
    return null;
  }

  void updateStyle(Style s) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt("style_id", s.id);
    setState(() {
      this.currentStyle=s;
    });

    Hws hw = widget.hw;
    hw.currentstyle = s;

    widget.state.updateHws(hw);
  }

  Widget colorplat(int i){

    return Container(
      width: w/8,
      height: w/8,
      child: Center(

        child: GestureDetector(
          onTap: (){
            updateStyle(colorstylesync(i));
          },
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(90),
            border: currentStyle.id==colorstylesync(i).id?Border.all(color: dark?Colors.white:Colors.black, width: 3.0):Border(),
            color: dark?(colorstylesync(i).colors_dark[0][1]):(colorstylesync(i).colors_light[0][1])
          ),

        )
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    return Scaffold(
      body: Container(height: h,width: w,
      color: dark?Colors.black:Colors.white,
      child: Column(children: [

        Container(height: h/33),

        Container(width: w,
          height: h/12
          ,child: SlideTransition(
            position: _offsetAnimation,
            child: Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/8, child: GestureDetector(
                onTap: (){
                  widget.state.updatePage(0, null);
                },
                child: Icon(Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,),)),
              Container(width: w/32,),
              Container(width: w/8, height: w/8, ),
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("s71_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*46),textAlign: TextAlign.center,),)),
              
              
            ]
          ),)),

          Container(
            width: w,
            height: h/7,
            
            child: FadeTransition(opacity: fade1 as Animation<double>,child: 
            /*
            Color scheme
            -----------
            c1/c2/c3/c4/
            */
          Container(
            color: dark?Colors.black:Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Color scheme title
                Container(width: w,
                height: h/15,
                child: AutoSizeText(AppLocalizations.of(context).translateKey("s153_"), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*38),textAlign: TextAlign.center,)),
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                  Spacer(),
                  colorplat(0),
                  Spacer(),
                  colorplat(1),
                  Spacer(),
                  colorplat(2),
                  Spacer(),
                  colorplat(3),
                  Spacer(),
                ],),)
            ],),
          ),
          
          )),
          Container(height: h/17,),
         Container(
            width: w,
            height: h/3,
            
            child: FadeTransition(opacity: fade2 as Animation<double>,child: 
            /*
            Color scheme
            -----------
            c1/c2/c3/c4/
            */
          Container(
            color: dark?Colors.black:Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Color scheme title
                Container(width: w,
                height: h/15,
                child: AutoSizeText(AppLocalizations.of(context).translateKey("s154_"), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*38),textAlign: TextAlign.center,)),
                Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                  accountaction(0),
                  accountaction(1),
                  
                 
                ],),)
            ],),
          ),
          
          )),
          Container(height: h/17,),
 Container(
            width: w,
            height: h/7,
            
            child: FadeTransition(opacity: fade3 as Animation<double>,child: 
            /*
            Color scheme
            -----------
            c1/c2/c3/c4/
            */

            Column(children: [
Container(
            color: dark?Colors.black:Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Color scheme title
                GestureDetector(
                  onTap: () async{
                    //delete cache
                    int length = ( await getTemporaryDirectory()).statSync().size;
                 ( await getTemporaryDirectory()).list().forEach((element) {
                   element.deleteSync();
                 });

                   Fluttertoast.showToast(msg: "👍", toastLength: Toast.LENGTH_SHORT);
                
                  },
                  child: Container(
                    width: w/1.2,
                    height: h/17,
                  decoration: BoxDecoration(color: dark?Colors.white:Colors.black,
                  borderRadius: BorderRadius.circular(45)),
                  child: Center(child: AutoSizeText(
                  AppLocalizations.of(context).translateKey("s211_"),
                  style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: th*38),
                  textAlign: TextAlign.center,
                
                ))))
            ],),
          ),
          Spacer(),
          Container(
            color: dark?Colors.black:Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Color scheme title
                GestureDetector(
                  onTap: (){
                    launch("https://projectad.de");
                  },
                  child: Container(
                    width: w/1.2,
                    height: h/17,
                  decoration: BoxDecoration(color: dark?Colors.white:Colors.black,
                  borderRadius: BorderRadius.circular(45)),
                  child: Center(child: AutoSizeText(
                  AppLocalizations.of(context).translateKey("s76_ "),
                  style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: th*38),
                  textAlign: TextAlign.center,
                
                ))))
            ],),
          ),
            ]),
          
          )),
        



      ])),
    );
  }
  String actiontext(int i){
    switch(i){
      case 0:return AppLocalizations.of(context).translateKey("s44_ ");
      case 1:return AppLocalizations.of(context).translateKey("s87_ ");
     
    }
    return "";
  }
  Function actionfunc(int i){
    switch(i){
      case 0: return (){
        FirebaseAuth auth = FirebaseAuth.instance;
        try{
        auth.sendPasswordResetEmail(email: auth.currentUser.email).then((value){
          Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translateKey("s48_ "),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1
    );
        
        });}catch(e){
          print(e);
        }
      };
      case 1: return (){
        FirebaseAuth auth = FirebaseAuth.instance;
        try{
          auth.signOut().then((value){  
            widget.state.pushback();
            widget.state.restartApplication();  
          });
        }catch(e){
          print(e);
        }
      };
    }
  }
  Widget accountaction(int i){
    return GestureDetector(onTap: actionfunc(i) as void Function(),
    child: Container(
      width: w,
      height: h/12,
      child: Center(child: 
      Container(
        width: w/1.2,
        height: h/17,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: dark?Colors.white:Colors.black
      ),
      child: Center(child: AutoSizeText(actiontext(i), style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: th*38), textAlign: TextAlign.center,)),
  ),)
    ),);
  }
}