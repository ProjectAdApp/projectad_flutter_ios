import 'dart:io';
import 'dart:typed_data';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projectad/service/FormValidator.dart';
import 'package:projectad/service/authlysis.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/service/pwdreset.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'service/LoginRequestData.dart';

Route createRoute(Hws hws, StartLoadingWidgetBodyState state) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AuthDisp(hws,state),
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
  );
}

class AuthDisp extends StatefulWidget {

  Hws hws;

  StartLoadingWidgetBodyState state;

  AuthDisp(this.hws,this.state);

  @override
  _AuthDispState createState() => _AuthDispState();
}

class _AuthDispState extends State<AuthDisp> with WidgetsBindingObserver, TickerProviderStateMixin{

  bool dark = true;
  bool supportsAppleSignIn = false;

  @override
  void didChangePlatformBrightness() {
    setState(() {
      dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;

      cc = AnimationController(vsync: this, duration: Duration(seconds: 1));
      ct = Tween(begin:0.0, end: 1.0).animate(cc);

      cc.forward();
    });
    super.didChangePlatformBrightness();
  }

  AnimationController pwdbounce;
  Animation pwdanim;

  @override
  void initState() {
        bool dark2 = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;

    cc = AnimationController(vsync: this, duration: Duration(seconds: 1));
    ct = Tween(begin: 0.0, end:1.0).animate(cc);


    cc.forward();

    pwdbounce = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    pwdanim = Tween(begin: 0.0, end: 0.2).animate(pwdbounce);
    pwdbounce.addListener(() => setState(() {}));

    fn = new FocusNode();
    print("1");


    Future.delayed(Duration(milliseconds: 100)).then((value)  {
      setState(() {
        
hinttext = "Email";
    labeltext = "Email";
    preparedText = AppLocalizations.of(context).translateKey("PSI4 ");
    errortext = AppLocalizations.of(context).translateKey("TOAST2 ");
    icon = Icon(Icons.alternate_email, color: dark2?Colors.white:Colors.black,);
    pwd = false;
      });
    }
    );

    

    super.initState();
  }

  void signIn(){
    print("sign in");
    validationResponse=null;
    if(from.currentState.validate()){

      print("111");

      from.currentState.reset();


      print("112");
        //next page

        this.emailtext=currenttext;

        print("object");
        cc.reset();
        setState(() {
          hinttext = AppLocalizations.of(context).translateKey("s36_ ");
          labeltext = hinttext;
          errortext = "";
          preparedText = register?AppLocalizations.of(context).translateKey("s145_"):AppLocalizations.of(context).translateKey("s144_");
          icon = Icon(Icons.vpn_key, color: dark?Colors.black:Colors.white,);
          
          pwd = true;
          });
        cc.forward().then((x) => (){
          
          
        });

        

    }
  }

  Future<void> checkUserState() async{
    String uuid = FirebaseAuth.instance.currentUser.uid;
    
   if((await FirebaseDatabase.instance.reference().child("Users").child(uuid).child("B1").once()).value==null){
     //there dosn't exist a uid store
     //build the uid store
     return buildUserStore(uuid);
   }
   return;

  }

  Future<int> getAsyncTime() async{
    DatabaseReference ref = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
    double offset = (await ref.once()).value;
    int offsetx = offset.toInt();
    return DateTime.now().millisecondsSinceEpoch-offsetx;
  }

  Future<void> buildUserStore(String uuid) async{
    String time = (await getAsyncTime()).toString();
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(uuid);
    reference.child("B1").set("?--?");
    reference.child("D1").set("0?"+(await getAsyncTime()).toString());
    reference.child("F").set(time+"#00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0+M");
    reference.child("UN").set(time);
    
  }

  void saveEmailInMemory(String mail) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("email", mail); 
  }

  void operateWithFirebase(AuthorizationResult result) async{
    print("successfull sign in");
final AppleIdCredential appleIdCredential = result.credential;

saveEmailInMemory(appleIdCredential.email);


OAuthProvider oAuthProvider =
    new OAuthProvider("apple.com");
final AuthCredential credential = oAuthProvider.credential(
  idToken:
      String.fromCharCodes(appleIdCredential.identityToken),
  accessToken:
      String.fromCharCodes(appleIdCredential.authorizationCode),
);

final UserCredential _res = await FirebaseAuth.instance
    .signInWithCredential(credential);
    FirebaseAuth.instance.currentUser.reload().then((value){
checkUserState().then((value){
widget.state.restartApplication();
});

    });  }

  Animation ct;
  AnimationController cc;

  String errortext = "x";
  
  final  from = new GlobalKey<FormState>();

  FocusNode fn ;


  String hinttext = "",labeltext = "",smarttext = "", preparedText = "", currenttext = "", emailtext = "", passwordtext= "";
  Icon icon;
  bool pwd = false;
  bool laststep = true;



  void finish() {

    


    this.passwordtext = currenttext;
   if(from.currentState.validate()){
        cc.forward();
      

    AuthAnalysis analysis = AuthAnalysis(register, email: emailtext, pass: passwordtext);

    analysis.load().then((value){

      print("last");
      print(value);

      if(value==1){
        //success

        setState(() {
          validationResponse=null;
        });

        

        widget.state.restartApplication();

        
        
      }else{
        print(value);

        String s;

        switch(value){
          case 0: s = AppLocalizations.of(context).translateKey("TOAST1 ");break;
          case -1: s = AppLocalizations.of(context).translateKey("s29_ ");break;
          case -2: s = AppLocalizations.of(context).translateKey("INN ");break;
          case -3:{ 
            s = AppLocalizations.of(context).translateKey("TOAST5 ");
            pwdAnim();
            break;
          }
          case -4: s = AppLocalizations.of(context).translateKey("s146_");break;

        }

        print(s);
        print("???");

        setState(() {
          validationResponse = s;
        });

        print(validationResponse);

      }




      if(from.currentState.validate()){
        cc.forward();
      }


    });
   }

  }

  void xjd(){

    register=false;

    setState(() {
      laststep=false;
    });

  }

  void pwdAnim(){
    
    /*TickerFuture tickerFuture = pwdbounce.repeat(reverse: true);
    tickerFuture.timeout(Duration(milliseconds:  800*10), onTimeout:  () {
      pwdbounce.forward(from: 0);
      pwdbounce.stop(canceled: true);
    });  */}

  void jxk(){

    register = true;

    setState(() {
      laststep=false;
    });

  }

  void updateToEmail(){
setState(() {
  hinttext = AppLocalizations.of(context).translateKey("Email");
    labeltext = "";
    preparedText = AppLocalizations.of(context).translateKey("PSI4 ");
    errortext = AppLocalizations.of(context).translateKey("TOAST2 ");
    icon = Icon(Icons.alternate_email, color: dark?Colors.white:Colors.black,);
});
  }

  void xx(){

    if(pwd){
      updateToEmail();
      from.currentState.reset();
      setState(() {
        pwd = !pwd;
        
      });
      return;
    }
    if(!laststep){
      setState(() {
        from.currentState.reset();
        laststep = !laststep;
      });
    }



  }

  bool register = true;

  String validationResponse;

  @override
  Widget build(BuildContext context) {

    print(preparedText);

    print(hinttext);  
    dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;

    if(!pwd)icon = Icon(Icons.alternate_email, color: dark?Colors.black:Colors.white);

        SvgPicture mainimage = SvgPicture.asset('images/pad.svg', color: dark?Colors.white:Colors.black, semanticsLabel: "");
    return Scaffold(
resizeToAvoidBottomInset: false,
      body:  GestureDetector(
        onTap: (){FocusScope.of(context).unfocus();},child: Container(
      color: dark?Colors.black:Colors.white,
      width: widget.hws.getWidth(),
      height: widget.hws.getHeight(),
     
      child: Column(
        children: <Widget>[
          Container(height: widget.hws.getHeight()/9),
          Container(height: widget.hws.getHeight()/4, width: widget.hws.getWidth()/4, child: mainimage),
          Container(height: widget.hws.getHeight()/9),
          Container(height: widget.hws.getHeight()/2.8, width: widget.hws.getWidth()/1.2, child: 
          FadeTransition(opacity: ct as Animation<double>,
            child: Column(
            children: laststep?<Widget>[

               Container(height: widget.hws.getHeight()/12, width: widget.hws.getWidth()/1.4,child: FlatButton(onPressed: xjd, shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(25.0),
  side: BorderSide(color: dark?Colors.white:Colors.black, width: 2.0),
  
),color: dark?Colors.white:Colors.black,
 child:  FadeTransition(opacity: ct as Animation<double>, child: AutoSizeText(AppLocalizations.of(context).translateKey("LOGIN_ "), style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: widget.hws.getTH()*40),textAlign: TextAlign.center,)))),
 
 Container(height: widget.hws.getWidth()/12),
 
 Container(height: widget.hws.getHeight()/12, width: widget.hws.getWidth()/1.4,child: FlatButton(onPressed: jxk, shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(25.0),
  side: BorderSide(color: dark?Colors.white:Colors.black, width: 2.0),
  
),color: dark?Colors.white:Colors.black,
 child:  FadeTransition(opacity: ct as Animation<double>, child: AutoSizeText(AppLocalizations.of(context).translateKey("s140_"), style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: widget.hws.getTH()*40),textAlign: TextAlign.center,))))
 
 
 ]:<Widget>[
              
              Form(key: from, child: TextFormField(
                
                focusNode: fn,


style: TextStyle(
        color: dark?Colors.black:Colors.white,
    ),
    onChanged: (s){
      this.currenttext=s;
    },
                
                decoration: InputDecoration(
                  
                  hintText: hinttext,


                  
                  
                  hintStyle: TextStyle(color: dark?Colors.grey:Colors.grey, fontSize: widget.hws.getTH()*30),
                  labelText: labeltext,
                  labelStyle: TextStyle(color: dark?Colors.black:Colors.white, fontSize: widget.hws.getTH()*30),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  focusColor: dark?Colors.white:Colors.black,
                  fillColor: dark?Colors.white:Colors.black,
                  filled: true,
                  alignLabelWithHint: false,
                  prefixIcon: icon,
                
                  
                  
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

print("editing compltete");

             
                  },
                  onFieldSubmitted: (s){
FocusScope.of(context).unfocus();
                  },
                  onSaved: (s){
FocusScope.of(context).unfocus();
                  },
            textInputAction: TextInputAction.continueAction,
                validator: (text){

                  print(text);
                    

                  
                  if(pwd){

    if(text.length<6)return AppLocalizations.of(context).translateKey("s141_");
    if(text.length>16)return AppLocalizations.of(context).translateKey("s142_");
    this.currenttext=text;
    return validationResponse;
  }

  if(isEmail(text)){
                    print("isNotEmail");
                    return AppLocalizations.of(context).translateKey("TOAST2 ");
                  }else{
                    return null;
                  }


                  
                },
              )),

              Container(
                height: widget.hws.getHeight()/20
              ),
              
              Container(height: widget.hws.getHeight()/12, width: widget.hws.getWidth()/1.2, child: StatefulBuilder(builder:(x,c){return GestureDetector(onTap: pwd?finish:signIn, child: Container(decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(25.0),
  border: Border.all(color: dark?Colors.white:Colors.black, width: 2.0),
  color: dark?Colors.white:Colors.black,

),
 child:  FadeTransition(opacity: ct as Animation<double>, child: Center(child: AutoSizeText(preparedText, style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: widget.hws.getTH()*40),textAlign: TextAlign.center,)))));})),
 
 (pwd&&register)?Container(height: widget.hws.getHeight()/12, width: widget.hws.getWidth()/1.2,
 child: GestureDetector(
   
   onTap: () async{

     if(register)return;

     PWDReset reset = new PWDReset(email: emailtext);

    int i = await reset.reset();

     if(i>0)Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translateKey("s48_ "),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1
    );
    if(i==-1)Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translateKey("TOAST4 "),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1);
        if(i==0)Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translateKey("TOAST1 "),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1);
   },
   child: Container(
   child: Center(
     child: AutoSizeText(AppLocalizations.of(context).translateKey("ESI5 "),style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: widget.hws.getTH()*31+(widget.hws.getTH()*31*pwdanim.value)),)
   ),
 ),),):Container()
 
 
 
 ]))),
 Container(height: widget.hws.getHeight()/12),
 Container(height: widget.hws.getHeight()/12, width: widget.hws.getWidth()*1.4, child: laststep?Container():FlatButton(
   
   child: 
 
 AutoSizeText(
   
   AppLocalizations.of(context).translateKey("STORE3_ "), style: TextStyle(fontSize: widget.hws.getTH()*31, color: dark?Colors.white:Colors.black),
 
 ),highlightColor: Colors.transparent, hoverColor: Colors.transparent, splashColor: Colors.transparent, onPressed: xx,)
    )]))));
  
        

}


bool isEmail(String em) {

  String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  RegExp regExp = new RegExp(p);

  return !regExp.hasMatch(em);
}
}

