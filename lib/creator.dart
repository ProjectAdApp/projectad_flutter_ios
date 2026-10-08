
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectad/data.dart';
import 'package:projectad/home.dart';
import 'package:projectad/loading_gifs.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/visual/style.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'intent.dart';
import 'main.dart';

class Creator extends StatefulWidget {
  Hws hw;
  IntentX intentX;
  StartLoadingWidgetBodyState _state;
  HomeState _state2;

  Creator(this.hw, this._state, this._state2, this.intentX);
  @override
  _CreatorState createState() => _CreatorState();
}

class _CreatorState extends State<Creator> with WidgetsBindingObserver, SingleTickerProviderStateMixin{
  PageController _scrollController;

  
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

  @override
  void dispose() {
    //c.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();
    //this.c = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    //this.a = Tween(end: 1.0, begin: 0.0).animate(c);
    //
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 444),
    );

    y_animation =
        Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutSine,
      ),
    );

    y_animation.addListener(() {
      setState(() {});
    });

    _controller.forward();

    this.currentStyle= widget.hw.currentstyle;
    this.able = checkUserAbilities();

    this.edit_controller = TextEditingController();
    this.edit_controller2 = TextEditingController();

    this._scrollController = PageController();

    this.cdp = new CreatorDataPack();
  }

  bool dark;
  double h,w,th;
  Style currentStyle;

  AnimationController _controller;
  Animation<Offset> y_animation;


  int page = 0;
  int page_mode0 = 0;
  bool able = false;
  bool notify = false, notify2 = false;
  bool suggest_mode = false;
  List<String> suggestions = [];

  String validation(String s){
    while(s.contains(" ")){
      s = s.replaceAll(" ", "_");
    }

    if(s.startsWith("_")){
      return "";
    }

    s = s.toLowerCase();

    final pattern = RegExp("^[a-z0-9_]+\u0024");

    int stop = 0;
    for(String ss in s.characters){
      if(!pattern.hasMatch(ss)){
        break;
      }
      stop++;
    }

    s = s.substring(0, stop);

    return s;
  }

  String validation2(String s){
    int index = s.indexOf(",");
    if(index>0) s = s.substring(0, index);

    int index2 = s.indexOf("\"");
    if(index2>0) s = s.substring(0, index2);

    return s;

  }

  bool currentRunnerSuggestions = false;
  
  void loadSuggestions(UsernameDataSet uds){

    //loading suggestions
    //with additions
    //generating ideas
    
    final ex2 = edit_controller.text;

    var s = Suggestions(edit_controller.text.toString());
    List l = s.getSuggestions();

    List<String> l2 = [];

    for(String s in l){
      if(!uds.sList.contains(s)){
        l2.add(s);
      }

      if(l2.length > 5)break;
    }

    if(currentRunnerSuggestions)return;
    currentRunnerSuggestions = true;
    Future.delayed(Duration(milliseconds: 1000)).then((value) {

      currentRunnerSuggestions = false;

      if(ex2 == edit_controller.text){

        //show
        //
        setState(() {
          this.suggestions = l2;
          this.suggest_mode = true;

          //this.page_mode0 = 0;
        });

      }
    });


  }
 

  bool checkUserAbilities(){
    return !FirebaseAuth.instance.currentUser.isAnonymous;
  }

  void tapX(){
    if(page_mode0 == 3){

                            var text = edit_controller.text;

                            if(text.length > 2){

                              String base = text.substring(0,2);

                              for(UsernameDataSet uds in loadedBases){

                                if(uds.base == base || suggestions.contains(text)){

                                  //check 
                                  //
                                  
                                  if(!uds.sList.contains(text.substring(2))|| suggestions.contains(text)){

setState(() {
                            this.page=1;

                            this.cdp.addUserName(text);

                            FocusScope.of(context).unfocus();

                            this._scrollController.animateToPage(1, duration: Duration(milliseconds: 800), curve: Curves.easeInCirc);
                          
                          });

                          return;

                                  }

                                }

                              }

                            }

                          }else if(page_mode0 == 1){

                            Future.delayed(Duration(milliseconds: 200)).then((value){
                                tapX();
                            });

                            return;

                          }

                          setState(() {
                            this.notify = true;
                          });
  }

  TextEditingController edit_controller;
  TextEditingController edit_controller2;
  CreatorDataPack cdp;

  @override
  Widget build(BuildContext context) {
    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      
body: SlideTransition(
      
      position: y_animation,
      child: Container(
        width: w,
        height: h,
        color: dark?Colors.black:Colors.white,
        child: Column(children:[
          Container(height: h/29),
          Center(child: Container(
       
        child: Container(
          width: w,
          height: h-h/29,
          child: Stack(
          alignment: Alignment.topLeft,
          children: [
            GestureDetector(child: Stack(children:[Positioned(
              top: h/22,
              left: w/40,
            
              child: Container(
                width: w/7,
                height: w/7,

                child: Center(child: Icon(page==0?Icons.close:Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,
                ))),

            )]),
            onTap: (){
              //back
              if(page == 0){

                widget._state2.back2();

                return;

              }else{

                //scroll to previos
                //location
            setState(() {
              page--;
              _scrollController.animateToPage(page, duration: Duration(milliseconds: 800), curve: Curves.easeInCirc);
            });
              

              }
            },
            ),

            Positioned(

              //page
              top: w/7+h/33,

              width: w,
            
              
              child: SizedBox(
                width: w,
                height: h/1.7,
                child: PageView.builder(
                  controller: _scrollController,
                
                  itemBuilder: (c,index){

                if(index == 0){

                  //check adj
                  
                  if(able){

                    return new Container
                  (
                      width: w,
                      height: h/1.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Container(child: Center(child: Text(AppLocalizations.of(c).translateKey("s162_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*35, fontWeight: FontWeight.w300)))),
                        Container(child: Center(child: Text(AppLocalizations.of(c).translateKey("s163_"), style: TextStyle(color: dark?Colors.grey[400]:Colors.grey, fontSize: th*19, fontWeight: FontWeight.w500), textAlign: TextAlign.center,))),
                        Center(child: SizedBox(
                          width: w/1.15,

                          child:TextFormField(

                            onChanged: (s){

                                setState(() {
                                  this.page_mode0 = 1;
                                  this.suggest_mode = false;
                                  this.notify = false;

                                });


                                String obj  = validation(s);
                                if(obj != s ){
                                   edit_controller.text = obj;
                                  edit_controller.selection = TextSelection.fromPosition(TextPosition(offset: edit_controller.text.length));
                                }
                                update();


                            },

                            

                          cursorColor: dark?Colors.white:Colors.black,
                          controller: edit_controller,

                        style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*24),
                        
                          decoration: InputDecoration(

                      
                            //labelText: AppLocalizations.of(context).translateKey("LOBT8 "),
                            
                            //labelStyle: TextStyle(color: dark?Colors.white:Colors.black,
                            //fontSize: th*22),
                            errorMaxLines: 1,
                            errorText: page_mode0 == 2 ? AppLocalizations.of(context).translateKey("s164_"):(notify?AppLocalizations.of(context).translateKey("s165_"):null),
                            errorStyle: TextStyle(color: Colors.red, fontSize: th*17),
    
                            

                            hintStyle: TextStyle(color: dark?Colors.grey[400]:Colors.grey, fontSize: th*24),
                            hintText: AppLocalizations.of(context).translateKey("LOBT7 "),
                            filled: true,
                            fillColor: dark?Colors.grey[900]:Colors.white,
                            suffixIconConstraints: BoxConstraints(maxHeight: w/8, maxWidth: w/6),
                            suffixIcon: page_mode0 == 0?Container():
                            (page_mode0 == 1?Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                
                                Image.asset(cupertinoLoadingGif, scale: 10)
                              ],)
                            ):(
                              page_mode0 == 2?Container(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                
                                GestureDetector(child:Icon(Icons.cancel_outlined, color: dark?Colors.grey[400]:Colors.grey, size: w/13,),onTap: (){
                                  edit_controller.text = "";
                                  edit_controller.value = TextEditingValue.empty;
                                  this.page_mode0 = 0;
                                  setState(() {
                                    
                                  });
                                },)
                              ],)
                              ):Container(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                
                                Icon(Icons.check_circle_outline_outlined,color: dark?Colors.green[800]:Colors.green, size: w/13,)
                              ],)
                              )
                            )),
                            
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: page_mode0== 2 ? Colors.red :dark?Colors.white:Colors.black,
                                width: 2.0
                                
                                ),


                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: page_mode0== 2 ? Colors.red :dark?Colors.white:Colors.black,
                                  width: 2.0
                                ),

                              


                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: page_mode0== 2 ? Colors.red :dark?Colors.white:Colors.black,
                                  width: 2.0
                                ),

                              


                            ),

                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: page_mode0== 2 ? Colors.red :dark?Colors.white:Colors.black,
                                  width: 2.0
                                ),

                              


                            ),

                            
                            
                            


                          ),
                          maxLines: 1,
                        
                          maxLength: 27,
                          
                        )
                        )),
                        
                        //next button
                       suggest_mode? Container(
                            width: w/1.15,
                            height: suggestions.length*h/24+(suggestions.length-1)*0.5,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(
            0,8), // changes position of shadow
        ),
                              ]
                            ),
                            child: SizedBox( 
                              width: w/1.15,
                              height: suggestions.length*h/24 + (suggestions.length-1)*0.5,
                              child: ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(2),
                              separatorBuilder: (context, index) {
    return Divider(height: 0.5,thickness: 0.5,color: dark?Colors.grey[400].withAlpha(180):Colors.grey.withAlpha(180),);
  },
                              itemCount: suggestions.length,
                              
                              itemBuilder: (context,index){

                              return GestureDetector(
                                onTap: (){
                                  edit_controller.text = suggestions[index];
                                  edit_controller.selection = TextSelection.fromPosition(TextPosition(offset: edit_controller.text.length));
                                  setState(() {
                                    this.suggest_mode = false;
                                    this.page_mode0 = 3;
                                  });
                                },
                                child: Container(
                                  width: w/1.15,
                                  height: h/24,
                                  decoration: BoxDecoration(
                                    
                                    color: dark?Colors.grey[900]:Colors.white,
                               ),
                                  child: Row(
                                    
                                    children: [
                                      Container(width: w/45,),
                                      Container(width: w/1.4,
                                      child: Text(suggestions[index], style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*24),),),
                                      Container(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                
                                Icon(Icons.check_circle_outline_outlined,color: dark?Colors.green[800]:Colors.green, size: w/13,)
                              ],)
                              )
                                    ],),
                              ));
                              

                            }),
                        ))
:Center(child: GestureDetector(child: SizedBox(
                          width: w/1.15,
                          height: h/19,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(90),
                            color: dark?currentStyle.colors_dark[0][1]:currentStyle.colors_light[0][1],
                            
                            ),
                            child: Center(child: Text(AppLocalizations.of(context).translateKey("PSI4 "), style: TextStyle(color: dark?Colors.white:Colors.black,fontSize: th*23),textAlign: TextAlign.center)) 
                          ),
                        ),
                        onTap: (){

                          tapX();

                        },))//example list
                        
                                             ],),
                    );

                  }else{

                    return Container(
                      child: Center(child: Container(
                        width: w/1.05,
                        height: h/3,
                        child: Column(children: [
                            SizedBox(
                              width: w/2,
                              height: w/2,
                              child: Icon(
                                Icons.error,
                                size: w/2,
                              ),
                            ),
                            Text(AppLocalizations.of(context).translateKey("s166_"),style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*22),textAlign: TextAlign.center,)
                        ])
                      ),),
                    );

                  }

                }

                if(index == 1){

                  return new Container
                  (
                      width: w,
                      height: h/1.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Container(child: Center(child: Text(AppLocalizations.of(c).translateKey("s167_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*35, fontWeight: FontWeight.w300)))),
                        Container(child: Center(child: Text(AppLocalizations.of(c).translateKey("s168_"), style: TextStyle(color: dark?Colors.grey[400]:Colors.grey, fontSize: th*19, fontWeight: FontWeight.w500), textAlign: TextAlign.center,))),
                        Center(child: SizedBox(
                          width: w/1.15,

                          child:TextFormField(

                            onChanged: (s){

                                setState(() {
                                  this.notify2 = false;
                                });

                                String obj = validation2(s);
                                if(obj != s){
                                  edit_controller2.text = obj;
                                edit_controller2.selection = TextSelection.fromPosition(TextPosition(offset: edit_controller2.text.length));
                                }

                                //update();


                            },

                            

                          cursorColor: dark?Colors.white:Colors.black,
                          controller: edit_controller2,

                        style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*24),
                        
                          decoration: InputDecoration(

                      
                            //labelText: AppLocalizations.of(context).translateKey("LOBT8 "),
                            
                            //labelStyle: TextStyle(color: dark?Colors.white:Colors.black,
                            //fontSize: th*22),
               
                            errorMaxLines: 1,
                            errorText: (notify?AppLocalizations.of(context).translateKey("s170_"):null),
                            errorStyle: TextStyle(color: Colors.red, fontSize: th*17),
                            hintStyle: TextStyle(color: dark?Colors.grey[400]:Colors.grey, fontSize: th*24),
                            hintText: AppLocalizations.of(context).translateKey("LOBT8 "),
                            filled: true,
                            fillColor: dark?Colors.grey[900]:Colors.white,
                            
                            
                            
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: dark?Colors.white:Colors.black,
                                width: 2.0
                                
                                ),


                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: dark?Colors.white:Colors.black,
                                  width: 2.0
                                ),

                              


                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: dark?Colors.white:Colors.black,
                                  width: 2.0
                                ),

                              


                            ),

                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(90),
                              borderSide: BorderSide(
                                color: dark?Colors.white:Colors.black,
                                  width: 2.0
                                ),

                              


                            ),

                            
                            
                            


                          ),
                          maxLines: 1,
                        
                          maxLength: 30,
                          
                        )
                        )),
                        
                        //next button

Center(child: GestureDetector(child: SizedBox(
                          width: w/1.15,
                          height: h/19,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(90),
                            color: dark?currentStyle.colors_dark[0][1]:currentStyle.colors_light[0][1],
                            
                            ),
                            child: Center(child: Text(AppLocalizations.of(context).translateKey("s169_"), style: TextStyle(color: dark?Colors.white:Colors.black,fontSize: th*23),textAlign: TextAlign.center)) 
                          ),
                        ),
                        onTap: (){

                          
  setState(() {

                            print("setStateFF");
                            var text = edit_controller2.value.text;

                            if(text == null || text.length==0){
                              this.notify2 = true;
                              return;
                            }

                            this.cdp.addName(edit_controller2.text);
                            this.cdp.addTime(DateTime.now().millisecondsSinceEpoch.toString());

                            runUser(cdp).then((value) {
                              FocusScope.of(context).unfocus();

                              _controller.reverse(from: 1.0);

                            

                            IntentX xx = new IntentX();
                            xx.addParameter("data", this.cdp.toList());
                            

                            //Future.delayed(Duration(milliseconds: 500)).then((value) => {

                              widget._state2.widget.startLoadingWidgetBodyState.updatePage(4, xx);

                           // });
                            });

                          
                          
                          });

                       
                        
                        },))//example list
                        
                                             ],),
                    );

                }

                return null;

              }, 
              
              scrollDirection: Axis.horizontal,itemCount: 3),

            )
            )

          ]
        ),
      ))),
    ]))));
  }


  bool active_ = false;

  Future<void> runUser(CreatorDataPack uds) async{
print("runUser:"+uds.toString());
    if(active_)return;
    active_ = true;

    String val = uds.user_name;



    String base = val.substring(0,2);

    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("usd").doc(base.substring(0,1)).get();
    String list = ds.get(base.substring(1));
    list = list.replaceAll(",", "\",\"");
    list = "[\""+list.substring(1,list.length-1) + "\"]";

    List sl = jsonDecode(list);
    if(!sl.contains(val.substring(0,2))){
      
      sl.add(val.substring(2));
      FirebaseFirestore.instance.collection("usd").doc(base.substring(0,1)).update(
        {
          base.substring(1) : sl.toString().replaceAll("\"", "")
        }        
      );

      await FirebaseFirestore.instance.collection("usd").doc("userId").set({
        uds.user_name : FirebaseAuth.instance.currentUser.uid,
        
      }, SetOptions(merge: true));


    return FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("UN").set(uds.safe());
    }


  }

  int lastChange = 0;
  String base;
  List<UsernameDataSet> loadedBases;

  void update(){

    int temp = lastChange;
    this.lastChange = DateTime.now().millisecondsSinceEpoch;

   

      //test
      
      if(edit_controller.text.length > 2){
        this.base = edit_controller.text.substring(0,2);
        //check if base not changed after 666 milliseconds 
        //activate loading animation
        //start loading at 666 
        
        setState(() {
          this.page_mode0 = 1;
        });

if(loadedBases != null)for(UsernameDataSet uds in loadedBases){

          if(uds.base == this.base){

              checkList(uds);

              break;

          }

        }
        
        Future.delayed(Duration(milliseconds: 1100), (){

            if(edit_controller.text.length > 2){

              if(this.base == edit_controller.text.substring(0,2)){

                

                //start loading base
                
                CloudCombinatorix.loadFirestoreBase(base).then((value){

                  if(this.base == edit_controller.text.substring(0,2) && edit_controller.text.length>2){
checkList(value);
                  }

                  
                  
                });

              }

            }

        });

      }else{
        setState(() {
                                  this.page_mode0 = 0;
                                });
      }

    

  }

  void checkList(UsernameDataSet ss){

      if(loadedBases==null)loadedBases = [];
      loadedBases.add(ss);


      String cur = edit_controller.text.substring(2);

      bool success = true;

      for(String x in ss.sList){
        if(x == cur){
          success = false;
          break;
        }
      }

      setState(() {
        this.page_mode0 = success?3:2;
      });

      if(!success)loadSuggestions(ss);

  }






}