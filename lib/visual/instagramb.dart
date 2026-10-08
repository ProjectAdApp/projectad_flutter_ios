import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/flutter_insta.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/insta31.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart';

class InstagramWrapper extends StatefulWidget {

  Hws hw;
  String uuid;
  HomeState state;

  InstagramWrapper(this.hw,this.uuid, this.state);

  @override
  InstagramWrapperState createState() => InstagramWrapperState();
}

class InstagramWrapperState extends State<InstagramWrapper> with WidgetsBindingObserver, SingleTickerProviderStateMixin{

  double h,w,th;

  String username;
  List<String> followers;

  Animation<Offset> _offsetanim;
  AnimationController _animationController;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();

    this._animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    this._offsetanim = Tween<Offset>(begin: Offset(-w/6, 0.0),end: Offset.zero).animate(_animationController);

    resolve();
  }

  @override
    void dispose() {
      this._animationController.dispose();
      super.dispose();
    }

  void back(){
    this._animationController.reverse();
  }

  

  InstagramHandler v1;

  void resolve()async{

    this.v1 = InstagramHandler();

    int i = await v1.checkInstagramState(widget.uuid);

    if(i==1){
      _animationController.forward();
    }
  }

  

  bool dark;

  @override
  Widget build(BuildContext context) {

    dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;

    

    return SlideTransition(
      position: _offsetanim,
      child: Container(
      height: w/8,
      width: w/6,
      child: Center(child: GestureDetector(
        onTap: (){
          widget.state.widget.startLoadingWidgetBodyState.createAlertDialog(dark, context, (){
            back();
          });

        },
        
          child: Container(
            width: w/8,
            height: w/8,
            decoration: BoxDecoration(
          color: Colors.black,
        //border: Border.all(color: Colors.white, width: 3.0),
        borderRadius: BorderRadius.circular(90),

      ),
      child: Icon(Icons.add, color: Colors.white,)
    )))));
  }
}