
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectad/account.dart';
import 'package:projectad/intent.dart';
import 'package:projectad/loading_gifs.dart';
import 'package:projectad/service/language/AppLocalizations.dart';

import 'service/hws.dart';

class Request {
  final String fromUID;
  Request(this.fromUID, {this.lookup});

  RequestLookup lookup;

  

}

/*
 * handle your own requests
 * 
 * Ask list is a json array <string> and collects the uids which request a user
 * 
 * Wer list is a json array <string> and collects the uids of users with the user requests
 * 
 * Con list is a json array <string> and collects the uids the user is connected with
 *   
 */
class RequestHandler {
  List ids;
  AccountState state;
  
  RequestHandler(String data,{this.state}){
 if(data != null && data != ""){
   if(data == "[]"){ids = [];return;}
    data = data.replaceAll(",", "\",\"");
    data = data.replaceAll("[", "[\"");
    data = data.replaceAll("]", "\"]");

    this.ids = jsonDecode(data);

 }
  }

  inform(){
    state.updateRequest(this);
  }

  int length(){

    if(requests != null)return requests.length;

    if(ids == null)return 0;
    return ids.length;
  }

  List<Request> requests;
  int nFailed = 0;
  Function whenFinshed;
  

  void create(Function whenFinished){

    this.whenFinshed = whenFinished;
    if(requests == null)requests = [];
    else {
      whenFinshed.call();
      return;
    }

    if(ids.length == 0){
      whenFinshed.call();
    }

    ids.forEach(loadUID);
    
  }

  var path = FirebaseDatabase.instance.reference().child("Users");

  void loadUID(dynamic uid){

    Request request = new Request(uid);

    this.path.child(uid).child("UN").once().then((value){



      if(value.value != null){
        String data = value.value;

        data = data.replaceAll(",", "\",\"");
        data = data.replaceAll("[", "[\"");
        data = data.replaceAll("]", "\"]");

        List l = jsonDecode(data);



        request.lookup = RequestLookup(uid, username: l[1], name: l[2], bio: l[3], hasProfilePicture: l[4] == "true", tagList: l[0], updateTime: int.parse(l[6]));

        requests.add(request);

        print("added "+ l[1]+ " to the list");

        checkMark();

      }else {
        nFailed++;
        checkMark();
      }
    });

    
    

    

  } 

  Future<void> removeRequestAt(String uid) async{

    String uid0 = FirebaseAuth.instance.currentUser.uid;

    var _path = path.child(uid0).child("Wer");
    _path.once().then((value) {
      String data = value.value;
      if(data != null){
        if(data.contains(uid)){

          if(data.contains(","+uid)){
            data = data.replaceAll(","+uid, "");
          }else{
            if(data.contains(uid+",")){
              data = data.replaceAll(uid+",", "");
            }else{
              data = data.replaceAll(uid  , "");
            }
          }

          _path.set(data);

        }
      }
    }); 


   

    var _path2 = path.child(uid).child("Ask");
    var value = await  _path2.once();
      String data = value.value;
      if(data != null){
        if(data.contains(uid0)){

          if(data.contains(","+uid0)){
            data = data.replaceAll(","+uid0, "");
          }else{
            if(data.contains(uid0+",")){
              data = data.replaceAll(uid0+",", "");
            }else{
              data = data.replaceAll(uid0  , "");
            }
          }

          await _path2.set(data);

        }
      }
    

  }

  Future<void> sendRequestTo(String uid, FriendHandler handler, RequestHandler handler2) async{

    if(handler2 != null)handler2.requests.forEach((element) {
      if(element.fromUID == uid){
        //oh no
        handler.addFriend(uid);
        return;
      }
    });else {
      var ask = path.child(FirebaseAuth.instance.currentUser.uid).child("Ask");
      var dara = await ask.once();
      String s = dara.value;
      print(s);
      print(uid);
      if(s != null && s.contains(uid)){
        handler.addFriend(uid);
        return;
      }
    }   

    var _path = path.child(FirebaseAuth.instance.currentUser.uid).child("Wer");
    _path.once().then((value) {
      String data = value.value;

      if(data == null){
        data = "["+uid +"]";
        _path.set(data);
      }else 

      if(!data.contains(uid)){
        if(data.length > 3){
          //min one
          data = data.replaceAll("]", ","+uid+"]");
        }else{
          data = "["+uid+"]";
        }
        _path.set(data);
      }
    }); 

    var _path2 = path.child(uid).child("Ask");
    var value = await _path2.once();
    var uid0 = FirebaseAuth.instance.currentUser.uid;
    String data = value.value;
      if(data == null || !data.contains(uid0) ){
        if(data != null && data.length > 3){
          //min one
          data = data.replaceAll("]", ","+uid0+"]");
        }else{
          data = "["+uid0+"]";
        }
      }
    await _path2.set(data);

  }
  

  Future<void> removeRequest(String uid) async {

      //search request

      var r;
      for(var request in requests){
        if(request.fromUID == uid)r = request;
      }
      if(r != null )requests.remove(r);

      var _path = path.child(FirebaseAuth.instance.currentUser.uid).child("Ask");

      var _path2 = path.child(uid).child("Wer");

      _path.once().then((snap) 
      {
        String data = snap.value;

        if(data == null){
          data = "["+uid+"]";
        }

        if(data != null){

        if(data.contains(",")){
          if(data.contains(uid+","))data = data.replaceFirst(uid+",", "");
          else data = data.replaceFirst(","+uid, ""); 
        }else data = data.replaceFirst(uid, "");
        }
        _path.set(data);

        
      });

      final String uuid = FirebaseAuth.instance.currentUser.uid;

      var snap = await _path2.once();
        String data = snap.value;

        if(data != null){
          if(data.contains(","+uuid)){
            data = data.replaceAll(","+uuid, "");
          }else{
            if(data.contains(uuid+",")){
              data = data.replaceAll(uuid+",", uuid);
            }else{
              data = data.replaceAll(uuid, "");
            }
          }
        }

      
        await _path2.set(data);


      

      

    }

  void checkMark(){
    if(nFailed + requests.length == ids.length){
      whenFinshed.call();
      whenFinshed = null;
    }
  }

  

  
}

class FriendHandler {
  List ids;
  List<Friend> friends;
  
  
  FriendHandler(String data){
    if(data == "[]"){
      ids = [];
      return;
    }
    if(data != null && data != ""){
      data = data.replaceAll(",", "\",\"");
      data = data.replaceAll("[", "[\"");
      data = data.replaceAll("]", "\"]");
      this.ids = jsonDecode(data);
    }
  }

  void removeExt(String uid){
    if(friends == null || friends.length == 0)return;
    var f;
    for(var fr in friends){
      if(fr.fromUID == uid)f = fr;
    }
    friends.remove(f);
  }

  void addExt(String uid){
    Friend f = Friend(uid);
    if(friends == null)friends = [];
    friends.add(f);

    if(ids == null)ids = [];
    ids.add(uid);

  }

  

  int length(){
    if(friends != null)return friends.length;
    if(ids == null)return 0;

    print(ids);

    return ids.length;
  }

  Function whenFinshed;

  void create(Function whenFinished){

    print("create...");
    print(ids);

    this.whenFinshed = whenFinished;
    if(friends == null)friends = [];
    else {

      if(friends.length == 0 || friends [0].lookup != null){
        whenFinshed.call();
        return;
      }
    }

    if(ids == null || ids.length == 0){
      ids = []; 
      whenFinshed.call();
    }

    ids.forEach(loadUID);
  }

  Future<void> killFriend(String uid) async{


    var f;
    for(Friend fr in friends){
      if(fr.fromUID == uid){
        f = fr; break;
      }
    }
   // if(f != null)friends[friends.indexOf(f)].active = false;

    var uid0 = FirebaseAuth.instance.currentUser.uid;

    var myPath = path.child(uid0).child("Con");

    myPath.once().then((value){

      String data = value.value;

      if(data != null){
        if(data.contains(","+uid)){
          data = data.replaceAll(","+uid, "");
        }else{
          if(data.contains(uid+",")){
            data = data.replaceAll(uid+",", "");

          }else{
            data = data.replaceAll(uid, "");
          }
        }

        myPath.set(data);

      }

    });

    var yourPath = path.child(uid).child("Con");

    var value = await yourPath.once();

      String data = value.value;

      if(data != null){
        if(data.contains(","+uid0)){
          data = data.replaceAll(","+uid0, "");
        }else{
          if(data.contains(uid0+",")){
            data = data.replaceAll(uid0+",", "");

          }else{
            data = data.replaceAll(uid0, "");
          }
        }
      }

        await yourPath.set(data);

      
    
  

  }

  chain(OwnRequestHandler handler, FriendHandler f) async{
    
    
    if(friends == null)return;
    if(f.friends == null){
      f.create((){
        chain(handler, f);
      });
      return;
    }
    int var0 = 0;
    var uid = FirebaseAuth.instance.currentUser.uid;
    for(var friend in friends){
      
      //detect friend  beeing

     
    
     
      friends[var0].friends = false;
      f.friends.forEach((element) {
        if(element.fromUID == friend.fromUID){
          friends[var0].friends = true;
        }
      });
      if(handler.currentOwnRequests.contains(friend.fromUID)){
        friends[var0].requested = true;
      }
      
      var0++;
    }
  }



  var path = FirebaseDatabase.instance.reference().child("Users");

  Future<void> addFriend(String uid) async{

    final String _uid = FirebaseAuth.instance.currentUser.uid;
    //own
    path.child(_uid).child("Con").once().then((value){
      String data = value.value;
if(data == null){

        data = "["+uid+"]";

      }
      if(!data.contains(uid)){
        if(data.length > 3){
          //min one
          data = data.replaceAll("]", ","+uid+"]");
        }else{
          data = "["+uid+"]";
        }
      }

      path.child(_uid).child("Con").set(data);

    });

    var value = await path.child(uid).child("Con").once();
    
    String data = value.value;

      if(data == null){

        data = "["+_uid+"]";

      }
      if(!data.contains(_uid)){
        if(data.length > 3){
          //min one
          data = data.replaceAll("]", ","+_uid+"]");
        }else{
          data = "["+_uid+"]";
        }
      }

      await path.child(uid).child("Con").set(data);


  }

  void loadUID(dynamic uid){

    Friend request = new Friend(uid);

    this.path.child(uid).child("UN").once().then((value){



      if(value.value != null){
        String data = value.value;

        data = data.replaceAll(",", "\",\"");
        data = data.replaceAll("[", "[\"");
        data = data.replaceAll("]", "\"]");

        List l = jsonDecode(data);



        request.lookup = RequestLookup(uid, username: l[1], name: l[2], bio: l[3], hasProfilePicture: l[4] == "true", tagList: l[0], updateTime: int.parse(l[6]));

        friends.add(request);

        print("added "+ l[1]+ " to the list");

        checkMark();

      }else {
        nFailed++;
        checkMark();
      }
    });

    
    

    

  } 

  int nFailed = 0;

  void checkMark(){
    if(nFailed + friends.length == ids.length){
      whenFinshed.call();
      whenFinshed = null;
    }
  }


}

class OwnRequestHandler {
  List<String> currentOwnRequests = [];

  Future<void> init() async{

    DatabaseReference reference = FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("Wer");

    var data = await reference.once();
    if(data.value != null){
      //exists
      //eList
      String s = data.value;
      s = s.replaceAll(",", "\",\"");
      s = s.replaceAll("[", "[\"");
      s = s.replaceAll("]", "\"]");

      List l = jsonDecode(s);
      currentOwnRequests = l.cast<String>();

    }
  }

} 

class RequestLookup {
  String username;
  String name;
  String bio;
  String none;
  
  int updateTime;

  String tagList;

  bool hasProfilePicture;

  Image profilePic;

  String uid;

  RequestLookup(this.uid, {this.username,this.none, this.name, this.bio, this.updateTime, this.hasProfilePicture, this.tagList, this.profilePic});

}

Future<List> loadFriendAndRequests() async{

  DatabaseReference userReference = FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid);

  var request = userReference.child("Ask");

  var friend = userReference.child("Con");

  String requests = (await request.once()).value;

  String friendList = (await friend.once()).value;

  RequestHandler requestHandler = RequestHandler(requests);

  FriendHandler friendHandler = FriendHandler(friendList);

  return [requestHandler,friendHandler];
}

Future<FriendHandler> loadFriends(String fromUID)async{
 DatabaseReference userReference = FirebaseDatabase.instance.reference().child("Users").child(fromUID);

  var friend = userReference.child("Con");

  String friendList = (await friend.once()).value;

  FriendHandler friendHandler = FriendHandler(friendList);

  return friendHandler;
}



class Friend {

  bool active = true;
  bool requested = false;
  bool friends = true;
  bool you = false;

  Friend(this.fromUID);

  String fromUID;
  RequestLookup lookup;
}

class RequestView extends StatefulWidget {
  
  Hws hw;
  RequestHandler requestHandler;
  AccountState accountState;
  

  RequestView(this.hw,this.requestHandler, this.accountState);

  @override
  _RequestViewState createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> with WidgetsBindingObserver{

  var w,h,th;
  RequestHandler requestHandler;
  FriendHandler friendHandler;
  bool dark;

  @override
    void didChangePlatformBrightness() {
      super.didChangePlatformBrightness();
      setState(() {
              
            });
    }

  bool ready = false;  
  bool empty = false;

  @override
    void initState() {
      
      this.w = widget.hw.getWidth();
      this.h = widget.hw.getHeight();
      this.th = widget.hw.getTH();
      this.requestHandler = widget.requestHandler;

      this.friendHandler = widget.accountState.friendHandler;

      requestHandler.create((){
        print("ready");
        setState(() {
                  this.requests = requestHandler.requests;
                  
                  ready = true;
                  print(requests);
                  if(requests == null || requests.length == 0){
                    empty = true;
                  }

                  print(empty);
                });
        
      });
      
  }



  List<Request> requests;

  //final ScrollController controller = ScrollController(initialScrollOffset: 0, keepScrollOffset: false);

  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return Container(
      height: h,
      width: w,
      color: dark ? Colors.black : Colors.white,
      child: Stack(children:[
        
        Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        Container(height: h/23),

        Container(width: w,
          height: h/21,
          
            child: Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/8, child: GestureDetector(
                onTap: (){
                  widget.accountState.updateRequest(requestHandler);
                  
                  

                  widget.accountState.killRequestPage(requestHandler);
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
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("s51_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),textAlign: TextAlign.center,),))  
            ]
          ),),

        Container(height: h/23,),

        ready ? (empty ? Container(
          width: w/1.1,
          height: h/1.2,
          child: Center(child: Text(AppLocalizations.of(context).translateKey("s206_"), style: TextStyle(color: Colors.grey, fontSize:  th * 21),))
        )  :   SingleChildScrollView(
          child: Container(
          

            width: w/1.1,
            
            child:MediaQuery.removePadding(context: context,
            removeTop: true, 
            child: StatefulBuilder(builder: (x,s){

              print("rebuild");
             
              
              return  ListView.separated(
             
              
              //physics: NeverScrollableScrollPhysics(),
              dragStartBehavior: DragStartBehavior.start,
              shrinkWrap: true,
              key: UniqueKey(),
              itemBuilder: (c,i){
              return ElementView(
                widget.hw,
              
                key: UniqueKey(),
                groundClick: (){
                                    Navigator.push(context, createZRoute(widget.hw, friendHandler,widget.accountState,requests[i],0));

                },
                behavior: ElementButtonBehavior.CHOOSE,
                 title: requests[i].lookup.username,subtitle: requests[i].lookup.name,task: ImageFileLoadTask(requests[i].fromUID),button1: AppLocalizations.of(context).translateKey("s49_ "),fb1: (){
                //accept
                //kill request in own ASK
                //add to CON of the other
                String uid = requests[i].fromUID;
                
                
                  requestHandler.removeRequest(uid).then((value){
                   friendHandler.addFriend(uid).then((value){
                     print("update");

                      //add friend
                      FriendHandler fh = friendHandler;
                      fh.addExt(uid);
                      widget.accountState.updateFriend(fh);
                      widget.accountState.setState(() {
                                              
                                            });
                      

                    setState(() {
                                          requests = requestHandler.requests; 
                                        });
                   }); 



                   widget.accountState.requestHandler = requestHandler;
                   print(widget.accountState.requestHandler.requests);
                   widget.accountState.setState(() {
                                        
                                      });
                     
                                });
              },
              button2: AppLocalizations.of(context).translateKey("s63_ "),
              fb2: (){
                //decline

                String uid = requests[i].fromUID;

                

                setState(() {
                                  requestHandler.removeRequest(uid); 
                                  requests = requestHandler.requests; 
                                });

                                widget.accountState.requestHandler = requestHandler;
                                print(widget.accountState.requestHandler.requests);
                                widget.accountState.setState(() {
                                        
                                      });

              });
            }, separatorBuilder: (c,i){
              return Container(
                width: w/1.1,
                height: 1,
                color: Colors.grey[200].withAlpha(120),
              );
            }, itemCount: 
          requests == null ? 0 : requests.length);})),
          )
        ) ) : Container()
        ])
      
      ])

    );
  }
}

class FriendView extends StatefulWidget {
  
  Hws hw;
  FriendHandler friendHandler;
  AccountState accountState;
  FriendHandler immigrant;
  OtherAccountState immigrantState;
  

  FriendView(this.hw,this.friendHandler, this.accountState ,{this.immigrant, this.immigrantState});

  @override
  _FriendViewState createState() => _FriendViewState();
}

class _FriendViewState extends State<FriendView> with WidgetsBindingObserver{

  var w,h,th;
  
  FriendHandler friendHandler;
  bool dark;

  @override
    void didChangePlatformBrightness() {
      super.didChangePlatformBrightness();
      setState(() {
              
            });
    }

  bool isImmigrant;

  FriendHandler immigrant;

  bool ready = false;  
  bool empty = false;

  int finLength;

  @override
    void initState() {
      
      this.w = widget.hw.getWidth();
      this.h = widget.hw.getHeight();
      this.th = widget.hw.getTH();
      this.friendHandler = widget.friendHandler;
      this.immigrant = widget.immigrant;

      this.isImmigrant = widget.immigrant != null;

      if(isImmigrant){
this.immigrant = widget.immigrant;
immigrant.create(() async{
  if(widget.accountState.ownRequestHandler.currentOwnRequests == null){
    await widget.accountState.ownRequestHandler.init();
  }
  immigrant.chain(widget.accountState.ownRequestHandler, friendHandler);

print("ready");
        setState(() {
                  this.friends = immigrant.friends;
                  this.finLength = friends.length;
                  
                  ready = true;
                  print(friends);
                  if(friends == null || friends.length == 0){
                    empty = true;
                  }

                  print(empty);
                });
        
   
});
      }else{
friendHandler.create((){
        print("ready");
        setState(() {
                  this.friends = friendHandler.friends;
                  this.finLength = friends.length;
                  
                  ready = true;
                  print(friends);
                  if(friends == null || friends.length == 0){
                    empty = true;
                  }

                  print(empty);
                });
        
      });
      }

      
      
  }



  List<Friend> friends;

  bool fh0 = true;

  //final ScrollController controller = ScrollController(initialScrollOffset: 0, keepScrollOffset: false);

  
  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return Container(
      height: h,
      width: w,
      color: dark ? Colors.black : Colors.white,
      child: Stack(children:[
        
        Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        Container(height: h/23),

        Container(width: w,
          height: h/21,
          
            child: Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/8, child: GestureDetector(
                onTap: (){

                  print("hello!");

                  setState(() {
                                      fh0 = false;
                                      friends = [];
                                    
                                    });

                  if(isImmigrant)widget.immigrantState.killFriendPage(friendHandler);
                  else widget.accountState.killFriendPage(friendHandler);
                  
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
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("s56_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),textAlign: TextAlign.center,),))  
            ]
          ),),

        Container(height: h/23,),

        ready ? (empty ? Container(
          width: w/1.1,
          height: h/1.2,
          child: Center(child: Text(AppLocalizations.of(context).translateKey("s207_"), style: TextStyle(color: Colors.grey, fontSize:  th * 21),))
        )  :   SingleChildScrollView(
          child: Container(
            
            

            width: w/1.1,
            
            child:MediaQuery.removePadding(context: context,
            removeTop: true, 
            child: StatefulBuilder(builder: (x,s){

              print("rebuild");
             
              
              return  ListView.separated(
             
              
              //physics: NeverScrollableScrollPhysics(),
              dragStartBehavior: DragStartBehavior.start,
              shrinkWrap: true,
              key: UniqueKey(),
              itemBuilder: (c,i){

                if(friends == null || friends.length == 0){
                  return Container();
                }

              return ElementView(
                widget.hw,
                key: UniqueKey(),
                friendHandler: friendHandler,
                uid: friends[i].fromUID,
                state: widget.accountState,
                groundClick: (){
                  
                  Navigator.push(context, createZRoute(widget.hw, friendHandler,widget.accountState,friends[i],isImmigrant ? friends[i].friends ? 0 : (friends[i].requested ? 2 : 1) : 0 ));
                },
                
                Start: isImmigrant ? friends[i].friends ? 0 : (friends[i].requested ? 2 : 1) : 0,
                behavior: ElementButtonBehavior.TOTAL,
                 title: friends[i].lookup.username,subtitle: friends[i].lookup.name,task: ImageFileLoadTask(friends[i].fromUID),button1: AppLocalizations.of(context).translateKey("s49_ "),fb1: (){
                //accept
                //kill request in own ASK
                //add to CON of the other
              
              },
              button2: AppLocalizations.of(context).translateKey("s63_ "),
              fb2: (){
                //decline

                

              });
            }, separatorBuilder: (c,i){
              return Container(
                width: w/1.1,
                height: 1,
                color: Colors.grey[200].withAlpha(120),
              );
            }, itemCount: //lookup firebase 
          finLength);})),
          )
        )) : Container()
        ])
      
      ])

    );
  }
}

class ElementImageCache {

  Future<File> searchFor (String uid) async{

    Directory dir = await getTemporaryDirectory();
    File f = (await dir.list().firstWhere((element) => element !=null && element.path.endsWith(uid+"snap"), orElse: () => null));
    return f;

  }

  Future<File> loadSnap(String uid) async{

    Directory dir = await getTemporaryDirectory();

    File newImageFile = File(dir.path+"/"+uid+"snap");
    if(!await newImageFile.exists()){
      await newImageFile.create();
    }

    await FirebaseStorage.instance.ref().child("profs/"+uid+"snap.jpg").writeToFile(newImageFile).future;

    return newImageFile;

  }

}

class ImageFileLoadTask {
  String uid;
  ImageFileLoadTask(this.uid);

  
  

  Future<File> create() async{
    
    File product = await ElementImageCache().searchFor(uid);
    if(product == null){
      product = await ElementImageCache().loadSnap(uid);
    }

    return product;
  }
  

}

enum ElementButtonBehavior {
  CHOOSE,
  TOTAL
}

class ElementView extends StatefulWidget {
  
  final Hws hw; 

  final String title;
  final String subtitle;

  final String button1;
  final String button2;

  final Function fb1;
  final Function fb2;

  final String uid;

  final AccountState state;

  final FriendHandler friendHandler;

  final ImageFileLoadTask task;

  final ElementButtonBehavior behavior;

  final Key key;

  final int Start;

  final Function groundClick;


  ElementView(this.hw, {this.groundClick, this.Start,this.friendHandler, this.state, this.uid, this.title, this.subtitle, this.task,this.behavior, this.button1, this.button2, this.fb1, this.fb2, this.key});

  @override
  _ElementViewState createState() => _ElementViewState();
}

class _ElementViewState extends State<ElementView> with WidgetsBindingObserver{

  

  bool imageReady = false;
  bool load = true;

  double w,h,th;
  bool dark;

  File prod;

  @override
    void didChangePlatformBrightness() {
      
      super.didChangePlatformBrightness();
      setState(() {
              
            });
    }

    FriendHandler friendHandler;
    double opacity = 1.0, scale = 1.0;

  @override
    void initState() {
      
      super.initState();

      w = widget.hw.getWidth();
      h = widget.hw.getHeight();
      th = widget.hw.getTH();
      

      widget.task.create().then((value){
        setState(() {
          prod = value;
                  imageReady = true;
                });
      });

      friendHandler = widget.friendHandler;

    }

    void openUser(){
      widget.groundClick.call();
    }

  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return Container(
     
      width: w / 1.2,
      height: h / 13,
      child: Row(children: [
        
        GestureDetector(child: (imageReady && prod != null && prod.lengthSync() > 0 ? CircleAvatar(radius: 22.0,
              backgroundColor: dark?Colors.black:Colors.white,
              backgroundImage: imageReady && prod != null && prod.lengthSync() > 0 ? FileImage(prod) : null,)
         :
          Container()), onTap: (){
            openUser();
          },),
            //imageReady && prod != null && prod.lengthSync() > 0

        GestureDetector(child: imageReady && prod != null && prod.lengthSync() > 0 ? Container(): Container(
          height: h/13,
          width: w / 8,
          child: Center(child: Icon(Icons.account_circle_rounded, size: h/ 15 ,color: Colors.grey,) )
        ), onTap: openUser,),

        Container(
          width: w/26,
          
        ),
        GestureDetector(child: Container(
          height: h/14,
          width: w / 2.39,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: h / 33,
                width: w / 2,
      
                child: Center(child: Container(
                  
                  width: w/2,child: Text(widget.title, style: TextStyle(
                  fontSize: th * 23,
                  color: dark?Colors.white:Colors.black
                ),textAlign: TextAlign.left,),))
              ),
              Container(
                height: h / 33,
                width: w / 2,
                child: Center(child: Container(
                  width: w/2,
                  child: Text(widget.subtitle, style: TextStyle(
                  fontSize: th * 23,
                  color: dark?Colors.white:Colors.black
                ),textAlign: TextAlign.left,),))
              )
            ],
          ),
        ), onTap: openUser,)
, Container(
          width: w/55,
          
        ),

        

        load && widget.behavior == ElementButtonBehavior.CHOOSE  ? GestureDetector(child: Container(
          width: w/7,
          height: h/26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Colors.blue,
            
          ),
          child: Center(child: 
          Text(widget.button1, style: TextStyle(color: Colors.white, fontSize: th * 20, fontWeight: FontWeight.w400),textAlign: TextAlign.center,),),
        ),
        onTap: ()
       {
         widget.fb1.call();
         setState(() {
                    load = false;
                  });
       } ,
        
        ) : Container() ,
        load && widget.behavior == ElementButtonBehavior.CHOOSE ? Container(
          width: w/44,
        ): Container(),
        load && widget.behavior == ElementButtonBehavior.CHOOSE ? GestureDetector(child: Container(
          width: w/7,
          height: h/26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: dark?Colors.white:Colors.black,
              width: 1.5
            )
            
          ),
          child: Center(child: 
          Text(widget.button2, style: TextStyle(color: dark ? Colors.white: Colors.black, fontSize: th * 20, fontWeight: FontWeight.w400),textAlign: TextAlign.center,),),
        ),
        onTap: ()
       {
         widget.fb2.call();
         setState(() {
                    load = false;
                  });
       } ,
        ) : Container(),
load ? Container(

        ) : Container(
          width: w / 7 * 2,
          height: h / 26,
          child: Center(
            child: Image.asset(cupertinoLoadingGif, scale: 10.0,),
          ),
        ),
        widget.behavior == ElementButtonBehavior.TOTAL ? 
        Container(
          width: w / 4 * scale,

          child: Opacity(opacity: opacity, child: SwitchConnectionButton(
          widget.hw, 
          otFunc: true,
          offAction: (){
            this.setState(() {
             
                          opacity = 1.0;
                          scale = 1.0;
                           load = true;
                        });
          },
          onAction: (){
            this.setState(() {
              
                          opacity = 0.00001;
                          scale = 0.000001;
                        });
                        this.setState(() {
                                                  load = false;
                                                });
          },
          firstImp: widget.Start,
          uid0: widget.uid,
          handlerUpdate: (h){
            print("updateFrind");
            widget.state.updateFriend(h);
          },
          friendHandler: widget.friendHandler,

        ))): Container(),
        

        
        
        
      ],),      
    );
  }
}

class SwitchConnectionButton extends StatefulWidget {
  //const SwitchConnectionButton({ Key? key }) : super(key: key);

  final String on;
  final String off;

  final Hws hw;

  final Function onAction;
  final Function offAction;

  final bool otFunc;

  final int firstImp;

  final String uid0;
  final Function(FriendHandler) handlerUpdate;
  final FriendHandler friendHandler;
  final RequestHandler requestHandler;


  SwitchConnectionButton(this.hw,{this.firstImp = 0,this.requestHandler, this.on,this.otFunc, this.off, this.onAction, this.offAction, this.uid0, this.handlerUpdate, this.friendHandler});

  @override
  _SwitchConnectionButtonState createState() => _SwitchConnectionButtonState();
}

class _SwitchConnectionButtonState extends State<SwitchConnectionButton> with WidgetsBindingObserver{

  double w, h, th;

  String s1, s2, s3;

  Function f1, f2, f3;

  int internState =0;

  /*
  0 - friends
  1 - not friends
  2 - requested
  */

  //1 is blue 0,2 nor

  @override
    void didChangePlatformBrightness() {
      super.didChangePlatformBrightness();
      setState(() {
              
            });
    }

    @override
      void dispose() {
        print("dfispose");
        super.dispose();
      }

    @override
      void initState() {
        


        super.initState();

        this.internState = widget.firstImp;


        this.w = widget.hw.getWidth();
        this.h = widget.hw.getHeight();
        this.th = widget.hw.getTH();

        this.s1 = widget.on;
        this.s2 = widget.off;

        

        

        this.f1 = widget.onAction;
        this.f2 = widget.offAction;

        if(widget.otFunc){


          f1 = (){

            if(widget.uid0 == FirebaseAuth.instance.currentUser.uid){
              Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s70_ "), toastLength: Toast.LENGTH_SHORT);
              return;
            }

            //unfollow

            widget.onAction.call();

            widget.friendHandler.killFriend(widget.uid0).then((value) {




                FriendHandler fh = widget.friendHandler;
                fh.removeExt(widget.uid0);

                widget.handlerUpdate.call(fh);

                

                widget.offAction.call();

                

                                  internState = 1;
                          print("f2");
                
                  setState(() {
                                      
                                    });
                

              
            });


          };

          f2 = (){
            if(widget.uid0 == FirebaseAuth.instance.currentUser.uid){
              Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s70_ "), toastLength: Toast.LENGTH_SHORT);
              return;
            }

            //request again

            widget.onAction.call();

            print("f2");

            RequestHandler(null).sendRequestTo(widget.uid0, widget.friendHandler, widget.requestHandler).then((value) { print("f2");
              

              

              widget.offAction.call();

setState(() {
                                  internState = 2;
                                });
              
              
            });


          };

          f3 = (){
            if(widget.uid0 == FirebaseAuth.instance.currentUser.uid){
              Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s70_ "), toastLength: Toast.LENGTH_SHORT);
              return;
            }

            //decline own request

            widget.onAction.call();

            RequestHandler(null).removeRequestAt(widget.uid0).then((value){

              
              widget.offAction.call();
setState(() {
                                  internState = 1;
                                });
              });

            

          };

        }

      

      }

  @override
  Widget build(BuildContext context) {

    bool dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    if(s1 == null){
          s1 = AppLocalizations.of(context).translateKey("s208_");
        }
        if(s2 == null){
          s2 = AppLocalizations.of(context).translateKey("s209_");
        }
        if(widget.otFunc)s3 = AppLocalizations.of(context).translateKey("s59_ ");
    return GestureDetector(child: Container(
      width: w/4,
      height: h/25,
      decoration: internState == 1 ? BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue
      ) : BoxDecoration(
        border: Border.all(color: dark ? Colors.white: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(15),
        
      ),
      child: Center(child: Text(internState == 0 ? s1 : (internState == 1 ? s2 : s3), style: TextStyle(
        color: internState == 1 ? Colors.white : (dark ? Colors.white : Colors.black),
        fontSize:  th * 21,
        fontWeight: FontWeight.w500
      ),))),
  onTap: (){

    if(internState == 0){
      if(check())f1.call();
    }else{
      if(internState == 1){
        if(check())f2.call();
      }else{
        if(check())f3.call();
      }
    }

  },

    );
  }

  int chicks = 0;
  int timez = 0;

  bool check(){
    if(chicks % 5 == 0 && chicks > 0 ){
      Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("TOAST4 "), toastLength: Toast.LENGTH_SHORT);
      Future.delayed(Duration(seconds: 5)).then((value){
        chicks++;
      });
      return false;
    }else{
      chicks++;
      return true;
    }
  }

}

class UnknownUser {
  bool isFriend = false;
  bool isRequested = false;
  String fromUid;
  RequestLookup lookup;

  

  UnknownUser(this.fromUid);
}

class UnknownUserSearch {
  Map<String,List<UnknownUser>> alreadyFound = {};


  FirebaseFirestore firebaseFirestore;

  Future<List<UnknownUser>> search(String article) async{
    if(article.length > 2){

      if(firebaseFirestore == null){
        firebaseFirestore = FirebaseFirestore.instance;
      }

      print(alreadyFound);
      if(alreadyFound.containsKey(article))return alreadyFound[article];

      DocumentSnapshot ds = await firebaseFirestore.collection("usd").doc(article.substring(0,1)).get();
      String eList = ds.get(article.substring(1,2));
      if(eList.contains(", ")){
        eList = eList.replaceAll(", ", ",");
      }
      eList = eList.replaceAll(",", "\",\"");
      eList = "[\""+eList.substring(1,eList.length-1)+"\"]";

      List names = jsonDecode(eList);

      String f = names.first;
      if(f != null && f.startsWith(",")){
        names[0] = f.substring(1);
      }

      if(names != null && names.length > 0 ){
        if(names[0] == "")names.removeAt(0);
      }

      List<String> bestMatch = [];
      print(names);
      names.forEach((element) {
        print(element);
        if(element.contains(article.substring(2)))bestMatch.add(article);
      });

      

      //6 matches to the top

      if(bestMatch.length == 0){
        //no found!
        alreadyFound[article] =  null;
        return null;
      }else{

        List<UnknownUser> users = [];
        for ( var element in bestMatch.getRange(0, bestMatch.length >= 6 ? 6 : bestMatch.length)) {
          
          var value =  await getUIDFromUsername(element);

            print("received uid"+value.toString());

            users.add(value);

           

            if(users.length == bestMatch.length || users.length == 6){

              //finsihed

              List<String> uid = [];
              List<UnknownUser> us2 = [];
              users.forEach((element) {
                print(element.fromUid);
                if(!uid.contains(element.fromUid)){
                  uid.add(element.fromUid);
                  us2.add(element);
                }
              });
              users = us2;

              if(!alreadyFound .containsKey(article))alreadyFound[article] = users;

              print("return us"+users.toString());

              return users;
              

            }

          

        }

      }


      

    }else return null;
  }



  Future<UnknownUser> getUIDFromUsername(String username) async{
    print(username);     
    var snap = await firebaseFirestore.collection("usd").doc("userId").get();
    var snap0;
    try{
    snap0 = await snap.get(username); 
    }catch(e){
      Fluttertoast.showToast(msg: 'Not found', toastLength: Toast.LENGTH_SHORT);
    }
    if(snap0 != null){
      return UnknownUser(snap0);
    }else return null;
  }

}

class SearchView extends StatefulWidget {
  final Hws hw;
  final FriendHandler fh;
  final String yourUsername;
  final AccountState state;
  SearchView(this.hw, this.fh, this.yourUsername, this.state);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with WidgetsBindingObserver, SingleTickerProviderStateMixin{

  double w, h, th;
  bool dark;

  @override
    void didChangePlatformBrightness() {
      // TODO: implement didChangePlatformBrightness
      super.didChangePlatformBrightness();
      setState(() {

            });
    }

    List<UnknownUser> usersx;

  Map<String, UnknownUser> mapStringUser = {};

  void loadUID(dynamic uid){

    if(mapStringUser.containsKey(uid)){
      setState(() {
              load = false;
            });
      return;       
    }

    UnknownUser request = new UnknownUser(uid);

    

    FirebaseDatabase.instance.reference().child("Users").child(uid).child("UN").once().then((value){

      print(value.value);

      if(value.value != null){
        String data = value.value;

        data = data.replaceAll(",", "\",\"");
        data = data.replaceAll("[", "[\"");
        data = data.replaceAll("]", "\"]");

        List l = jsonDecode(data);



        request.lookup = RequestLookup(uid, username: l[1], name: l[2], bio: l[3], hasProfilePicture: l[4] == "true", tagList: l[0], updateTime: int.parse(l[6]));

        if(request.lookup == null){
          print("problem");
          request.lookup = RequestLookup(uid, username: l[1], name: l[2], bio: l[3], hasProfilePicture: l[4] == "true", tagList: l[0], updateTime: int.parse(l[6]));

        }


        if(friendHandler.ids != null && friendHandler.ids.contains(request.fromUid)){
          request.isFriend = true;
        }

        if(widget.state.ownRequestHandler.currentOwnRequests != null && widget.state.ownRequestHandler.currentOwnRequests.contains(request.fromUid)){
          request.isRequested = true;
        }

        

        setState(() {
                  usersFound.add(request);
                });

          

         if(usersFound.last.lookup == null){
           usersFound.last.lookup = RequestLookup(uid, username: l[1], name: l[2], bio: l[3], hasProfilePicture: l[4] == "true", tagList: l[0], updateTime: int.parse(l[6]));
         }       

         mapStringUser[uid] = request;

        checkMark();

      }else {
        print("fail");
        nFailed++;
        checkMark();
      }
    });

    
    

    

  } 

  int nFailed = 0;

  void checkMark(){
    if(nFailed + usersFound.length == usersx.length){

      List<UnknownUser> del = [];
      usersFound.forEach((element) {
        print("checking...");
        print(element.lookup);
        if(element.lookup == null){
          del.add(element);
        }
      });

      del.forEach((element) {
        usersFound.remove(element);
      });

      setState(() {
              load = false;
            });
            
    } 
  }



  Animation<Offset> _offsetAnimation;
  AnimationController animationController;

  TextEditingController editingController = TextEditingController();

  @override
    void initState() {

      super.initState();

      this.w = widget.hw.getWidth();
      this.h = widget.hw.getHeight();
      this.th = widget.hw.getTH();

      this.friendHandler = widget.fh;

      this.sr = UnknownUserSearch();

      animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

     animationController.forward();
    }

  UnknownUserSearch sr;

  List<UnknownUser> usersFound = [];

  FriendHandler friendHandler;

  FocusNode fn = FocusNode();

  bool load = true;

  bool available = true;

  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

    return Scaffold(
      body: 
      Container
      (
        width: w,
        height: h,
        color: dark ? Colors.black : Colors.white,
        child: Column(
          children:[
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
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("mng2_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),textAlign: TextAlign.center,),)),
              Container(width: w/6, height: w/8),
              Container(width: w/8,
              
               height: w/8, 
                ),
            
            ]
          ),)),

          Container(height: h/33,),
          Center(child: Container(
            width: w / 1.1,
            child: Center(child: TextField(
              focusNode: fn,
              controller: editingController,
              
              style: TextStyle(color: !dark ? Colors.black : Colors.white),
              decoration: InputDecoration(
              
                
              suffixIconConstraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
                maxHeight: 50,
                maxWidth: 50
              ),
                suffixIcon: Container(
                  child: GestureDetector(
                    onTap: (){

                      setState(() {
                                              load = true;
                                              usersFound = [];
                                              usersx = [];
                                            });
                      //search

                   /*   if(editingController.text == widget.yourUsername){
                        setState(() {
                                                  load = false;
                                                });
                                                return;
                      }*/

                      sr.search(editingController.text).then((value) {
                        if(value == null){
                          Fluttertoast.showToast(msg: 'Not found', toastLength: Toast.LENGTH_SHORT);
                        }
                                                usersx = value;
                                                usersx.forEach((element) {
                                                  print("load"+element.toString());
                                                  loadUID(element.fromUid);
                                                });

                                                setState(() {
                                                  usersFound = value;
                                                  available = false;
                                                  
                                                });
                      });
                    },
                    child: Center(child: Icon(Icons.search, color: dark ? Colors.white : Colors.black),),
                  )
                ),
                labelStyle: TextStyle(color: dark?Colors.white:Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                
                hoverColor: Colors.transparent,
                filled: true,
                fillColor: Colors.grey.withAlpha(90),
                focusColor: Colors.transparent,
                labelText: AppLocalizations.of(context).translateKey(
                  "s210_"
                ),
                errorText: "",
                hintText: "",

              ),
            
              cursorColor: !dark?Colors.black:Colors.white,
            ),
          ))),

           load ? ( available ? Container(): Container(child: Image.asset(cupertinoLoadingGifSmall, height: h/40,))): Container(
             width: w/ 1.1,
             height: h / 1.5,
             child:  ListView.separated(itemBuilder: (a,b){

              print(usersFound[b].lookup);
              if(usersFound[b].lookup == null)return Container();

              return ElementView(
                widget.hw,
                uid: usersFound[b].fromUid,
                key: UniqueKey(),
                groundClick: (){
                                    Navigator.push(context, createZRoute(widget.hw, friendHandler,widget.state,usersFound[b], usersFound[b].isFriend ? 0 : usersFound[b].isRequested ? 2 : 1));

                },
                behavior: ElementButtonBehavior.TOTAL,
                Start: usersFound[b].isFriend ? 0 : usersFound[b].isRequested ? 2 : 1,
                 title: usersFound[b].lookup.username,subtitle: usersFound[b].lookup.name,task: ImageFileLoadTask(usersFound[b].fromUid),button1: AppLocalizations.of(context).translateKey("s49_ "), fb1: (){

                 }, button2: AppLocalizations.of(context).translateKey("s63_ "),
                 fb2: (){

                 },
                   
                //accept
                //kill request in own ASK
                //add to CON of the other
              /* SwitchConnectionButton(widget.hw, otFunc: true,firstImp: usersFound[b].isFriend ? 0 : 1, handlerUpdate: (x){
                
              },friendHandler: friendHandler,onAction: (){

              },offAction: (){

              },*/);
            }, separatorBuilder: (a,b){
              if(usersFound[b].lookup == null)return Container();
              return Divider(
                height: 1,
              );
            }, itemCount: realLength(usersFound))
           )
          ]

        ), 
      ),
    );
  }

  int realLength(List<UnknownUser> us){
    int length = us.length;
    us.forEach((element) {
      if(element.lookup == null){
        length = length - 1;
      }
    });
    return length;
  }
}
Route createFRoute(Hws hw, FriendHandler friendHandler, String username, AccountState state){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SearchView(hw,friendHandler,username, state),
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

