import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asn1/asn1_tags.dart';
import 'package:pointycastle/asn1/primitives/asn1_boolean.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/visual/style.dart';
import 'account.dart';
import 'data.dart';
import 'loading_gifs.dart';
import 'main.dart';

class Edit extends StatefulWidget {

  
 
  Hws hw;
  String name,user_name,bio;
  File profilePic;
  List<Tag> widgets;
  StartLoadingWidgetBodyState sss;
  AccountState state;
  int ac;

  Edit(this.hw,this.name,this.user_name,this.bio,this.profilePic, this.sss,this.state, this.widgets, this.ac);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit>  with WidgetsBindingObserver, TickerProviderStateMixin{

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
    setState(() {
      
    });
  }

  double h,w,th;
  Style currentStyle;
  String filePath;

  List<Tag> tags;
  TagHandler tagHandler;

  String un, nn, bio;
  bool changedProfilePic = false;

  @override
  void initState() {

    print("init");
  
    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();

    this.tagHandler = TagHandler();
    this.tagHandler.load();

    this.profilePic = widget.profilePic;
    this.c1 = TextEditingController(text: widget.user_name);

this.c2 = TextEditingController(text: widget.name);

this.c3 = TextEditingController(text: widget.bio);

this.tags  = List.generate(widget.widgets.length, (index)=> widget.widgets[index]);

this.enabled = List.filled(15, true);

this.un = widget.user_name;
this.nn = widget.name;
this.bio = widget.bio;


_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 444),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    scaleAnimation = Tween<double>(begin: 0.0, end: h/6).animate(_scaleController);
    


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

     getApplicationDocumentsDirectory().then((value){
       this.filePath = value.path + "/profilePicEdit";
     });

      
     
    
    

  }

  

  AnimationController _controller;
  Animation<Offset> y_animation;
  AnimationController _scaleController;
  Animation scaleAnimation;

  File profilePic;

  bool dark;

  CameraController cameraController;
  TextEditingController c1,c2,c3;
  
  final picker = ImagePicker();

  bool focusTag = false;
  Tag focusedTag;
  List<bool> enabled;
  Widget w2;

  @override
  void dispose() {
    // TODO: implement dispose
    this._controller.dispose();
    super.dispose();
  }

  bool reImp = false;

  bool asd = false;

  @override
  Widget build(BuildContext context) {


    bool b23;
    if(focusTag){
      b23 = condition(focusedTag);
    }

    if(reImp){
      _controller.forward();
      reImp = false;
    }
    
     
    this.dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SlideTransition(
        position: y_animation,
        child: Container(

      width: w,

      color: dark?Colors.black:Colors.white,
        child: Column(
          
          children:[
          Container(height: h/99),
          Center(child: Container(
       
        child: Container(

          width: w,
          height: h-h/99,
          child: Stack(
            fit: StackFit.expand,
           clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            
            
          
           

            ListView(
              //cr: CrossAxisAlignment.center,
              children: [
            //  Container(height: h/33),
Center(child: Container(child: Row(children: [GestureDetector(child: Container(
                width: w/7,
                height: w/7,
                child: Center(child: Icon(Icons.close, color: dark?Colors.white:Colors.black,
                ))),

            

            onTap: (){
              //back
              print("tap");

              _controller.reverse().then((value) => widget.state.killEdit(null));
              
              }
            
            ),
            Container(width: w-w/7-w/5),
            checkIsNew() ? GestureDetector(child: Container(
                width: w/5,
                height: w/7,

                child: Center(child: Text(AppLocalizations.of(context).translateKey("s18_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th* 23)
                ))),

            
            
            onTap: () async {
              //back
              if(asd)return;
              asd = true;
              String value = null;
              if(checkIsNew()){
                //update
                bool b1 = tags.length != widget.widgets.length;
    for(Tag tt in tags){
      print(tt.en);
      if(!widget.widgets.contains(tt)){
        b1 = true;
        break;
      }
    }

    String tag_data = TagHandler.getTagStringFromList(widget.widgets);
    String user_name = widget.user_name.toString();
    String name = widget.name;
    final String privacy = widget.state.privacy;
    final String time0 = DateTime.now().millisecondsSinceEpoch.toString();
    bool hasPb = widget.profilePic != null;
    String bio = widget.bio;

    if(b1){
      tag_data = TagHandler.getTagStringFromList(tags);
    }
    if (c1.text != widget.user_name){
      user_name = c1.text;

      FirebaseFirestore.instance.collection("usd").doc("userId").set({
        user_name : FirebaseAuth.instance.currentUser.uid,
        widget.user_name : FieldValue.delete()
      }, SetOptions(merge: true));

      //add to new 

      

      FirebaseFirestore.instance.collection("usd").doc(widget.user_name.substring(0,1)).get().then((value){
        String js = value.get(widget.user_name.substring(1,2));
        

        if(widget.user_name.substring(0,2) == user_name.substring(0,2)){
if(js.contains(", "+widget.user_name.substring(2))){
          js = js.replaceFirst(", "+widget.user_name.substring(2), ","+user_name.substring(2));
        }
        if(js.contains(","+widget.user_name.substring(2))){
          js = js.replaceFirst(","+widget.user_name.substring(2), ","+user_name.substring(2));
        }
        }else{
if(js.contains(", "+widget.user_name.substring(2))){
          js = js.replaceFirst(", "+widget.user_name.substring(2), "");
        }
        if(js.contains(","+widget.user_name.substring(2))){
          js = js.replaceFirst(","+widget.user_name.substring(2), "");
        }
        }

        FirebaseFirestore.instance.collection("usd").doc(widget.user_name.substring(0,1)).set({
          widget.user_name.substring(1,2) : js
        }, SetOptions(merge: true));
        
      });

      if(widget.user_name.substring(0,2) != user_name.substring(0,2)){
      
      FirebaseFirestore.instance.collection("usd").doc(user_name.substring(0,1)).get().then((value){
        String js = value.get(user_name.substring(1,2));
        if(js == null)js = "";
        js = js.substring(0, js.length-1) + "," + user_name.substring(2) + "]";

        FirebaseFirestore.instance.collection("usd").doc(user_name.substring(0,1)).set({
          user_name.substring(1,2) : js
        }, SetOptions(merge: true));
        
      });

      }



    }
    if (c2.text != widget.name) {
      name = c2.text;
    }
    if (c3.text != widget.bio) {
      bio = c3.text;
      if(bio.contains(",")){
        bio = bio.replaceAll(",", "");
      }
      if(bio.contains("[")){
        bio = bio.replaceAll("[", "");
      }
      if(bio.contains("]")){
        bio = bio.replaceAll("]", "");
      }
      if(bio.contains("\"")){
        bio = bio.replaceAll("\"", "");
      }
    }
    if (changedProfilePic && profilePic != widget.profilePic){
      hasPb = profilePic != null;
    
      if(hasPb)await ProfilePicManager().upload(profilePic, time0, context);
      else if(widget.profilePic != null)await ProfilePicManager().delete();
    }

    value = "[" + tag_data + "," + user_name + "," + name + "," + bio + "," + hasPb.toString() + "," + privacy + "," + time0 + "]";
    await FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("UN").set(value);

              }
              
try{
              _controller.reverse().then((value0) => widget.state.killEdit(value));
}catch(e){print(e);}
asd = false;              
              }
            
            ):Container()]))),
Container(
              height: h/5,
              width: h/5,

              child: GestureDetector(
                onTap: (){
                  showCupertinoModalPopup(context: context, 
                  barrierDismissible: true,

                  builder: (bc){
                    return CupertinoActionSheet(
                      

                      actions: [
                        CupertinoActionSheetAction(
                          child: Text(AppLocalizations.of(context).translateKey("s175_")),
                          onPressed: () async{
 Navigator.of(context).pop();
                            /*Navigator.pop(context);
                             Navigator.push(context, new CupertinoPageRoute(
                              builder: (co) => Edit(widget.hw,widget.name,widget.user_name, widget.bio,widget.profilePic,widget.sss)
                            ));*/
                            final pickedFile = await picker.getImage(source: ImageSource.camera);
                            setState(() {
                              if(profilePic == null)return;
                              this.changedProfilePic = true;
                              
                              this.profilePic = File(pickedFile.path);
                            });
                           
                              
                            
                          },
                        ),
                         CupertinoActionSheetAction(
                          child: Text(AppLocalizations.of(context).translateKey("s176_")),
                          onPressed: () async{Navigator.of(context).pop();
                            final pickedFile = await picker.getImage(source: ImageSource.gallery);
                            if(pickedFile == null){
                              return;
                            }
                            String path = await ProfilePicManager().getPath();
                            if(path == pickedFile.path){
                              //same
                              
                              setState(() {
                                changedProfilePic = false;
                                return;
                              });
                            }

                            setState(() {
                              changedProfilePic = true;
                              this.profilePic = File(pickedFile.path);
                            });
                            
                            //gallery
                          },
                        ),
                        profilePic != null ? CupertinoActionSheetAction(
                          child: Text(AppLocalizations.of(context).translateKey("s193_"), style: TextStyle(color: Colors.red)),
                          onPressed: () async{ Navigator.of(context).pop();
                            setState(() {
                              profilePic = null;
                              changedProfilePic= widget.profilePic != null;
                            });
                           
                            //remove
                          },
                        ):Container(width: 0, height: 0),
                      ],
                      cancelButton: CupertinoActionSheetAction(
        child: Text(AppLocalizations.of(context).translateKey("BAB ")),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context, AppLocalizations.of(context).translateKey("BAB "));
        },
      ),
                    );
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children:[SizedBox(
              
              height: h/5,
              width: h/5,

              child: CircleAvatar(radius: 50.0,
              backgroundColor: dark?Colors.black:Colors.white,
              backgroundImage: profilePic == null ? null : FileImage(profilePic),
              child: profilePic == null  ? Icon(Icons.account_circle_rounded, size: h/5,color: Colors.grey[700],) : Container()),
            
            )]))),
            
            Center(child: Text(AppLocalizations.of(context).translateKey("s177_"), textAlign: TextAlign.center,style: TextStyle(color: Colors.grey, fontSize: th*16),),),
            //Divider(thickness: 2, color: Colors.grey,),
            /*String vers_change;
              switch(index){
                case 0:{vers_change = AppLocalizations.of(context).translateKey("LOBT7 "); break;}
                case 1:{vers_change = AppLocalizations.of(context).translateKey("LOBT8 "); break;}
                case 2:{vers_change = AppLocalizations.of(context).translateKey("s178_"); break;}
                case 3:{vers_change = AppLocalizations.of(context).translateKey("s179_"); break;}
              }*/
              Container(height: h/22,),
           
             ListView.separated(
               shrinkWrap: true,
               physics: NeverScrollableScrollPhysics(),
               separatorBuilder: (q,r){
                 return Center(child: Container(width: w/1.05, child: Divider(height: 3, color:dark?Colors.grey[400]:Colors.grey[900])));
               },
              itemCount: 4,
              
              itemBuilder: (x,index){

              String vers_change = "";
              String s_0 = "";
              switch(index){
                case 0:{vers_change = AppLocalizations.of(context).translateKey("LOBT7 "); s_0 = widget.user_name;break;}
                case 1:{vers_change = AppLocalizations.of(context).translateKey("LOBT8 "); s_0 = widget.name;break;}
                case 2:{vers_change = AppLocalizations.of(context).translateKey("s178_"); s_0 = widget.bio; break;}
                case 3:{vers_change = AppLocalizations.of(context).translateKey("s179_");}
              }

              


              return Container(
                //color: Colors.orange,
                child: SizedBox( width: w,
              //height: index == 3 ? h/3:h/20,
              child: Column(children:[Center(child: Container(width: w/1.05, child: GestureDetector(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Container(width: w/1.05/2,
                height: h/20,
                child: Center(child: Container(
                    width: w/1.05/2,
                    child: Text(vers_change+":", style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*23))))),
                Container(
                  width: w/1.05/2,
                  height: h/20,
                  child: Center(child: Container(
                    width: w/1.05/2,
                    child: Text(
                      
                      (index == 0 ? c1.text : index == 1 ? c2.text : index == 2 ? c3.text : ""), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*23))),
                ))
              ]), onTap: (){
                Navigator.push(context, createRoute(widget.hw, index, (index == 0 ? c1.text : index == 1 ? c2.text : index == 2 ? c3.text : ""), this));
              }
                
              ))),
            
            index == 3 ? Column(children: [
              Center(child: Container(

            
              width: w/1.05,
              child: Wrap(
                direction: Axis.horizontal,

                children: 
                  tags0(this.tags)
                
              )



            )),

            Container(height: h/100,),

             Container(
               //!dark?Colors.grey[400]:Colors.grey[900]),
               child: Center(
              child: Container(
              width: w,
              color: Colors.grey[350].withAlpha(180),
              child: Column(
                
                children: [
             
               Container(height: h/50),
               focusTag ? AnimatedBuilder(
                 animation: scaleAnimation,
                 builder: (wr,qw){return Container(
                 height: scaleAnimation.value,
                 child: Center(child: Container(
                   width: w/1.05,
                   height: h/6,
                   child: Stack(
                     //mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Positioned(
                         left: 3,
                         top: 0,
                         bottom: w/22,
                         child: 
                       Container(
                          //color: dark?Colors.black:Colors.white,
                         height: h/8,
                         width: //w/30 + w/50*focusedTag.text(context).length+(w/30 + w/50*focusedTag.text(context).length)/9,
                        w/2.05,
                          child: Center(
                            
                          
                            
                              child: Transform.scale(
                                scale: 1.2,
                                child: w2)
                              
                   
                          
                            )
                       )),

                        Positioned( 
                          right: 2,
                          child: Container(
                                          
                                                      
                            
                            width: w/2.22,
                            child: Center(child: Container(height: h/7, width: w/2.22, child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              
                              children: [
                                //heADER
                                Text(focusedTag.nameText(context), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th* 33, fontWeight: FontWeight.w700)),

                                Text(focusedTag.conditionText(context, cup, true), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th* 19, fontWeight: FontWeight.w400)),

                                GestureDetector(child: Container(
                                  width: w/4,
                                  height: h/33,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(90),
                                    color: b23 ? (!dark?Colors.white:Colors.black) : (dark?Colors.grey[700]:Colors.grey.withAlpha(180)),
                                    border:  Border.all(color: dark?Colors.grey:Colors.grey[600]),


                                  ),
                                  child:       Center(child:                         Text(tags.contains(focusedTag) ? AppLocalizations.of(context).translateKey("s192_"): AppLocalizations.of(context).translateKey("s191_"), style: TextStyle(color:dark ?  Colors.white: Colors.black, fontSize: th* 19, fontWeight: FontWeight.w400))),
                                ),onTap: (){
                                  //add tag
                                  
                                  if(tags.contains(focusedTag)){

                                    removeTagFromMine();

                                  }else addTagToMine();

                                 

                                }),


                              ]
                            )))
                                                      )
                        ),
                        Positioned(
                          right: 0,
                          left: 0,
                          bottom: 3,
                          child: Divider(height: 3, color: dark?Colors.grey[400]:Colors.grey[900])
                        )
                   ],)
                 ),),
               );}):Container(),
               Container(height: h/50),
               Container(width: w/1.05,
               child: Text(AppLocalizations.of(context).translateKey("s180_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th* 23),),),
                Container(child: Center(child: Container(

            
              width: w/1.05,child: Wrap(
                direction: Axis.horizontal,
                children: 
                  tags_s(tagHandler.getStandardTags(yourTags: this.tags))
                
              )))),
              Container(height: h/66),
               Container(width: w/1.05,
               child: Text(AppLocalizations.of(context).translateKey("s181_"), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th* 23),),),
                Container(child: Center(child: Container(

            
              width: w/1.05,child: Wrap(
                direction: Axis.horizontal,
                children: 
                  tags_s(tagHandler.getSpecialTags())
                
              ))))
              ]
              )))),

              Container(color: Colors.grey[350].withAlpha(180), height: h/44),
            
             ])
            :Container()
              ])
              ));

            })
            ,
            //wrap
            
        ]
          )]))))]
      ))
      
    ));

    

  }

  void changeStates(){



  }

  bool condition(Tag t){
    if(cup == null) cup = CompleteUserPack(spaceResolver: widget.state.wsr, qpc: widget.hw.v.getFromMultiple("d1").toString().substring(0,widget.hw.v.getFromMultiple("d1").toString().indexOf("?")),uds: UsernameDataSet(null,null, username: widget.user_name, nname: widget.name, bio: widget.bio, hasPb: widget.state.hasProfilePic, time0: widget.state.time0, privacy: widget.state.privacy),d1:  widget.hw.v.getFromMultiple("d1") );
   

    return t.conidition(cup);
  }

  CompleteUserPack cup;
  void addTagToMine(){

    if(condition(focusedTag)){

    

      List<Tag > tags0 = this.tags;
      if(tags0.contains(focusedTag))return;
      tags0.add(focusedTag);

      this.stored_values.add(focusTagId);

      setState((){this.tags = tags0;});

    }

  }

  void removeTagFromMine(){

    List<Tag> tags0 = this.tags;
    tags0.remove(focusedTag);
    setState(() {
      this.tags = tags0;
    });

  }

  void focusTag$(Tag t, int nums){

    if(focusTagId == nums)return;

    print("put position"+nums.toString());

    //refresh null to widgets__
    
   
    setState(() {
     this.w2 = Container();
    });
    
    Future.delayed(Duration(milliseconds: 14)).then((value){
setState(() {
      if(!focusTag)_scaleController.forward();
       widgets__ = [];
    tags_s(tagHandler.getStandardTags());
    tags_s(tagHandler.getSpecialTags());
    int nums0 = nums;
      nums = additional(nums, t,widgets__);

      if(nums == -1){

        this.focusedTag = (own_list[nums0] as TagWidget).tag;
        this.focusTagId = nums0;
        this.w2 = (own_list[nums0] as TagWidget);

      }else{
      this.focusedTag = t;
      this.focusTagId = nums ;
      this.w2 = widgets__[nums];
      }

      this.focusTag = true;
      

      

      print("tag33:"+w2.toStringDeep());
     

      });
    });
    
      
    
  }

  int additional(int nums, Tag tm, List<Widget> widgets){
    for(var w in widgets){
      if(w is Container)continue;
      TagWidget w1 = w;
      if(w1.tag.tD == tm.tD){
        return nums;
      }
    }
    return -1;
  }

  List<Widget> widgets__ = [];
  int focusTagId = -1;

  int getTagId(Tag t){

    List<Tag> s1 = tagHandler.getStandardTags();
    List<Tag> s2 = tagHandler.getSpecialTags();

    if(s1.indexOf(t) != -1)return s1.indexOf(t);
    else return s2.indexOf(t)+s1.length;


  }

  List<Widget> own_list = []; 
  List<Widget> tags0(List<Tag> tags){

      List<Widget> ws = [];
      for (var i = 0; i < tags.length; i++) {
        Tag tag = tags[i];
        ws.add(TagWidget(tag, widget.hw, (){
  print("focus Tag"+getTagId(tag).toString());
  if(tag.default$ == null || !tag.default$)focusTag$(tag, i);
}));

      }
      //widgets__.addAll(ws);
      
      own_list = ws;
      return ws;

      
  }

  List<int> stored_values = [];

  int realVal(int unreal){
    
    return unreal;
  }

  List<Widget> tags_s(List<Tag> tags){

    List<Widget> widgets = [];

    //opt tags with this.tags
    
    if(tags == null)return widgets;

    this.tags.forEach((element) {
      if(tags.contains(element)){
        //double element
        //remove element from list with dummy
        tags[tags.indexOf(element)] = TagHandler.dummy();
      }
    });

    print(tags.toString());

    //List<Widget > cancel = [];
    for (var i = 0; i < tags.length; i++) {
      Tag tag = tags[i];
      if(tag.default$ == null || !tag.default$)widgets.add(
        TagWidget(tag, widget.hw, (){
          print("focus100"+getTagId(tag).toString());
          focusTag$(tag,getTagId(tag));
        }));else{
          Widget w = Container(height: 0,width:0);
          widgets.add(w);
          //cancel.add(w);
        }
      
    }
    if(widgets__.length <= 15) widgets__.addAll(widgets);
    
    return widgets;

    


  }

  

  bool checkIsNew(){

    print("check");

    bool b1 = tags.length != widget.widgets.length;
    for(Tag tt in tags){
      print(tt.en);
      if(!widget.widgets.contains(tt)){
        b1 = true;
        break;
      }
    }

    print(un+"/"+widget.user_name);

    return (b1)
    || (c1.text != widget.user_name)
    || (c2.text != widget.name)
    || (c3.text != widget.bio)
    || (changedProfilePic && profilePic != widget.profilePic);


  }

  void receiveWithIndex(int index, String text){
    if(index == 0){
      c1.text = text;
    }
    if(index == 1){
      c2.text = text;
    }
    if(index == 2){
      c3.text = text;
    }
    setState(() {
      
    });
  }






}
Route createRoute(Hws hws, int index, String tt, _EditState state) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EditElement(hws, index,tt, state),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
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

class EditElement extends StatefulWidget {

  Hws hw;
  int index;
  final String tt;
  _EditState state;

  EditElement(this.hw, this.index, this.tt, this.state);

  @override
  _EditElementState createState() => _EditElementState();
}

class _EditElementState extends State<EditElement> with WidgetsBindingObserver{

  @override
  void didChangePlatformBrightness() {
    setState(() {
      
    });
    super.didChangePlatformBrightness();
  }

  double w,h,th;

  

  TextEditingController co;

  @override
  void dispose() {
    co.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    this.w = widget.hw.getWidth();
    this.h = widget.hw.getHeight();
    this.th = widget.hw.getTH();
    String s = widget.tt;

    this.co = TextEditingController(text: s);
    
    super.initState();
  }

  void loadSuggestions(UsernameDataSet uds){

    //loading suggestions
    //with additions
    //generating ideas
    
    print("loadSug");

    final ex2 = co.text;

    var s = Suggestions(co.text.toString());
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

      if(ex2 == co.text){

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
  bool currentRunnerSuggestions = false;
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
  String validation3(String s){
    int index = s.indexOf("");
    if(index>0) s = s.substring(0, index);

    int index2 = s.indexOf("\"");
    if(index2>0) s = s.substring(0, index2);

    return s;

  }
  bool dark;

  /*
  <key>NSContactsUsageDescription</key>  
	<string>Use your contacts to find people, you already know, in ProjectAd</string>  
  */

  @override
  Widget build(BuildContext context) {
    this.dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        color: dark?Colors.black: Colors.white,
        child: Stack(children: [
          Positioned(
            
            top: w/8,
            child: Container(width: w,
          height: h/22,
          child: Center(child: Container(
            width: w/1.05,
            child: Container(child: Row(
            
            children: [
             
           GestureDetector(child: Container(width: w/7,height: w/7,
              child: Icon(Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,),),onTap: (){
                Navigator.of(context).pop();
              },),
              Container(height: w/7,
              width: w/1.05-w/7-w/7,
              child: Center(child:Text(widget.index == 0 ? AppLocalizations.of(context).translateKey("s194_") : (widget.index == 1 ?AppLocalizations.of(context).translateKey("s195_"):AppLocalizations.of(context).translateKey("s196_")  ), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*29, ),textAlign: TextAlign.center))),
(page_mode0 == 3 && widget.index == 0 && co.text != widget.tt) || (co.text != null && co.text.length > 0 && widget.index > 0 && co.text != widget.tt) ? GestureDetector(child: Container(width: w/7,height: w/7,
              child: Center(child: Text(AppLocalizations.of(context).translateKey("s18_ "),style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*23),textAlign: TextAlign.right,))), onTap: (){
                widget.state.receiveWithIndex(widget.index, co.text);
                Navigator.pop(context);
              },): Container()
                         ],
          ),))

          )),

          ),
          Positioned(
            left: 0,
            top: h/22+w/7,
            right: 0,


            child: Center(child: Container(
              width: w/1.05,
              child:TextField(
                onChanged: (s){

                  if(widget.index == 0){
                    setState(() {
                                  this.page_mode0 = 1;
                                  this.suggest_mode = false;
                                  this.notify = false;

                                });


                                String s0  = validation(s);
                                if( s0 != s){
                                co.text = s0;  
                                co.selection = TextSelection.fromPosition(TextPosition(offset: co.text.length));
                                }

                                update();
                  }
                  if(widget.index == 1){
                     setState(() {
                                  
                                  this.notify = false;

                                });
                    String s0  = validation2(s);
                                if( s0 != s){
                                co.text = s0;  
                                co.selection = TextSelection.fromPosition(TextPosition(offset: co.text.length));
                                }}
                  if(widget.index == 2){
                     setState(() {
                                  
                                  this.notify = false;

                                });
                    String s0  = validation3(s);
                                if( s0 != s){
                                co.text = s0;  
                                co.selection = TextSelection.fromPosition(TextPosition(offset: co.text.length));
                                }}

                },
                controller: co,
                maxLength: widget.index == 0 ||   widget.index == 1 ? 30 : 150,
                maxLines: widget.index == 0 ||   widget.index == 1 ? 1 : 4,

                style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*23),
                cursorColor: dark?Colors.white:Colors.black,
              
            decoration: InputDecoration(
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
                                  co.text = "";
                                  co.value = TextEditingValue.empty;
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
                            
              hintText: widget.index == 0 ? AppLocalizations.of(context).translateKey("LOBT7 ") : (widget.index == 1 ? AppLocalizations.of(context).translateKey("LOBT8 "):AppLocalizations.of(context).translateKey("s178_")),
              hintStyle: TextStyle(color: dark?Colors.grey[400]:Colors.grey[900], fontSize: th*23),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color:  dark?Colors.grey[400]:Colors.grey[900], width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color:  dark?Colors.grey[400]:Colors.grey[900], width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color:  dark?Colors.grey[400]:Colors.grey[900], width: 2),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color:  dark?Colors.grey[400]:Colors.grey[900], width: 2),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color:  dark?Colors.grey[400]:Colors.grey[900], width: 2),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color:  dark?Colors.grey[400]:Colors.grey[900], width: 2),
              )
            ),
          )))),

          Positioned(
            right: 0,
            left: 0,
            top: h/4,
            child: suggest_mode? Center(child: Container(
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
                                  co.text = suggestions[index];
                                  co.selection = TextSelection.fromPosition(TextPosition(offset: co.text.length));
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
                        ))):Container()
          )

        ],),
      )
    );
  }
  void update(){

    int temp = lastChange;
    this.lastChange = DateTime.now().millisecondsSinceEpoch;

   

      //test
      
      if(co.text.length > 2){
        this.base = co.text.substring(0,2);
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

            if(co.text.length > 2){

              if(this.base == co.text.substring(0,2)){

                

                //start loading base
                
                CloudCombinatorix.loadFirestoreBase(base).then((value){

                  if(this.base == co.text.substring(0,2) && co.text.length>2){
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

    

  }void checkList(UsernameDataSet ss){


      if(loadedBases==null)loadedBases = [];
      loadedBases.add(ss);


      String cur = co.text.substring(2);

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
  int lastChange = 0;
  String base;
  List<UsernameDataSet> loadedBases;
}
