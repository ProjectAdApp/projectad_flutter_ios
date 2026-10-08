
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:projectad/intent.dart';
import 'package:projectad/mail.dart';
import 'package:projectad/main.dart';
import 'package:projectad/service/hws.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/service/product.dart';
import 'package:projectad/service/saver.dart';
import 'package:projectad/visual/style.dart';
import 'package:projectad/visual/typewriter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class Shop extends StatefulWidget {

  Hws hw;

  IntentX intentX;

  StartLoadingWidgetBodyState state;

  String pointstxt;

  Shop(this.hw,this.state,this.intentX){
    this.pointstxt=intentX.getValue("count");
  }

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> with WidgetsBindingObserver, TickerProviderStateMixin{

  double h=0,w=0,th=0;

   bool dark;

  String pointstxt;
  int pointscount;

  Style currentstyle;

  bool isReady;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
    

  }

  



   AnimationController _controller1;
   Animation<Offset> _offsetAnimation;

  Animation sigmanim;
   AnimationController sigmacontr;

  bool available = false;

  @override
  void initState() {
    
    this.h = widget.hw.getHeight();
    this.w = widget.hw.getWidth();
    this.th = widget.hw.getTH();

    this.pointstxt=widget.pointstxt;
    this.pointscount=int.parse(pointstxt);

    this.sigmacontr = AnimationController(vsync: this, duration: Duration(seconds: 1));
    this.sigmanim = Tween(begin: 0.0, end: 1.0).animate(sigmacontr);

    this.currentstyle= widget.hw.currentstyle;
    available = StaticSave.value("shop.text");
    if(available==null)available=false;

    this.slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 333));
    this.slideAnimation = Tween<Offset>(begin: Offset(0,1), end: Offset(0,0)).animate(slideController);

    _controller1 = AnimationController(vsync: this, duration: Duration(seconds: 1));

    _offsetAnimation = Tween<Offset>(
      begin:  const Offset(0.0, -1.5),
      end:  Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    super.initState();

    _controller1.forward();
  }

  @override
  void dispose() {
    _controller1.dispose();
    super.dispose();
  }

  void finished(){
    StaticSave.save("shop.text", true);
    setState(() {
      available=true;
    });
    
  }

  bool focus = false;
  bool productfocus = false;
   Product p;

  void focusProduct(Product product){
    this.p = product;
   
    setState(() {
      focus = true;
      productfocus = true;
      sigmacontr.forward();
      slideController.forward();
    });
     
  }

  
  Animation<Offset> slideAnimation;
  AnimationController slideController;
  

  @override
  Widget build(BuildContext context) {

    this.dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    Image im = Image(image: AssetImage("images/qp.png"), color: dark?Colors.white:Colors.black,);

    return Scaffold(
      body: Container(
        width: w,
        height: h,
        color: dark?Colors.black:Colors.white,
      
         child: Stack(children: [Column(
        children: <Widget>[
          Container(height: h/33),
          
          Container(width: w,
          height: h/12 ,child: SlideTransition(position: _offsetAnimation,
          child:   Row(
            children: <Widget>[
              Container(width: w/32,),
              Container(width: w/8, height: w/8, child: GestureDetector(
                onTap: (){
                  widget.state.updatePage(0, null);
                },
                child: Icon(Icons.arrow_back_ios, color: dark?Colors.white:Colors.black,),)),
              Container(width: w/32,),
              Container(width: w/8, height: w/8, ),
              Container(width: w/2.75, height: w/8, child: Center(child:AutoSizeText(AppLocalizations.of(context).translateKey("s111_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),textAlign: TextAlign.center,),)),
              Container(width: w/32,),
              Container(width: w/3.45, height: w/8,
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    focus = true;
                    productfocus= false;
                    
                    
                  });
                },
                
                child: Center(child: Container(width: w/3.45-w/30, height: w/12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: dark?Colors.white:Colors.black, width: 1.5)), child: Center(child: Row(
                children: <Widget>[
                  Container(height: w/10,width: w/6,child: Center(child:Container(width: w/6, child: AutoSizeText(pointstxt,style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*30),textAlign: TextAlign.right,)),)),
                  Container(height: w/10  , width: w/27,child: im, )
                ]
              )),)),))
            ]
          ))
          ),
             Container(
            width: w,
            height: h/3,
            color: dark?Colors.black:Colors.white,
            child: FlatButton(
              onPressed: (){
                
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
              child:  Container(width: w-w/12, child: available?AutoSizeText(
                                AppLocalizations.of(context).translateKey("s115_ "),textAlign: TextAlign.left,   style: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*32),)

              :TypewriterAnimatedTextKit(
                onTap: (){
                 
                },
                onNext: (s,s1){},
                onNextBeforePause: (vav,a){},
                
                pause: Duration(microseconds: 90),
                onFinished: finished,
                
                
                textAlign: TextAlign.left, text: [AppLocalizations.of(context).translateKey("s115_ ")], speed: Duration(milliseconds: 90),

                displayFullTextOnTap: true, isRepeatingAnimation: false,repeatForever: false, textStyle: TextStyle(color: dark?Colors.white:Colors.black, fontSize:  th*32),)))
            ),
          ),
          Container(height: h/25,),
          //wave,
          Container(
            height: h/12, width: w,
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
    ))),


        Container(height: h/2.3275, width: w, decoration: BoxDecoration(gradient: LinearGradient(colors: !dark?currentstyle.getListDark()[3]:currentstyle.getListLight()[3], begin: Alignment.centerLeft, end: Alignment.centerRight)), child: Center(
          child:         
           Center(child: Products(widget.hw, this))
        )),
       // Container(height: h/100, width: w, decoration: BoxDecoration(gradient: LinearGradient(colors: dark?currentstyle.getListDark()[3]:currentstyle.getListLight()[3], begin: Alignment.centerLeft, end: Alignment.centerRight)))

        
         
        
        ]),
        
        focus?BackdropFilter(filter: ImageFilter.blur(
          sigmaX:7,
          sigmaY:7,
        ),
          child: productfocus?
          SlideTransition(position: slideAnimation, child: Container(
            width: w,
            height: h,
            color: dark?Colors.black:Colors.white,
            child: Center(child: 
            GestureDetector(
              
              child: SingleChildScrollView(child: Container(
                height: h*1.3,
                width: w,
                child: Stack(children: [
                Positioned(
              top: h/22,
              left: w/40,
            
              child: GestureDetector(child: Container(
                width: w/7,
                height: w/7,

                child: Center(child: Icon(Icons.close, color: dark?Colors.white:Colors.black,
                ))), onTap:(){
                  setState(() {
                                      productfocus = false;
                                      focus = false;
                                      slideController.reverse().then((value) => slideController.reset());
                                    });
                }),

            ),
              Positioned(
                top: h/22+w/6,
                left: 20,
                right: 20,
                child: Center(child: SizedBox(
                  width: w/1.2,
                  height: h/4,

                  child: Image(image: p.img,))),
              ),
              
              Positioned(
                top: h/4+h/22+w/6,
                left: 20,
                right: 20,
                child: Column(children: [
                  Text(p.title, textAlign: TextAlign.center, style: TextStyle(
                    color: dark?Colors.white:Colors.black,
                    fontSize: th*33),),
                  Container(
                    height: h/33,
                  ),
                  Container(
                  decoration: BoxDecoration(
                    color: dark?Colors.white: Colors.black87,
                    borderRadius: BorderRadius.circular(33),
                    
                  ),
                  child: GestureDetector(child: SizedBox(
                    width: w/1.3,
                    height: h/21,
                    child: Center(child: Text(AppLocalizations.of(context).translateKey("s151_")+p.price, style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: th * 31,)))),
                    onTap: (){

                      

                      buy(context);

                    },
                )),Container(
                    height: h/33,
                  ),
                  Container(
                    width: w/1.2,
                    height: h/5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(33),
                      color: Colors.grey[200].withAlpha(180),
                    ),
                    child: Center(child: SizedBox(
                      width: w/1.3,
                      height: h/5.1,
                      child: Center(child: Text(p.subtitle, textAlign: TextAlign.center, style: TextStyle(
                      color: Colors.black, fontSize: th * 21, 
                    ),)),)),
                  )
                  ])
              ),

              Positioned(
                top: h-h/6,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(

               //     borderRadius: BorderRadius.circular(33/2),
                  //  color: (dark?Colors.white:Colors.black87)
                  ),
                  child: Center(child: SizedBox
                  (
                    width: w/1.3,
                    height: h/21,
                     
                      child: Text(AppLocalizations.of(context).translateKey("s202_")
                      , style: TextStyle(color: dark?Colors.white:Colors.black, fontWeight: FontWeight.w500, fontSize: th * 28),textAlign: TextAlign.left,),
                    
                ))),
              ),
              Positioned(
                 top: h-h/40-h/15,
                  left: 20,
                  right: 20,
                  child: Column(children: [
                    Container(
                      width: w/1.3,
                      height: h/5,
                      child: 
                    Text(p.info, style: TextStyle(color: dark?Colors.white: Colors.black, fontSize:  th* 21, fontWeight: FontWeight.w300))),
                     Container(
                      width: w/1.3,
                      height: h/5,
                      child: 
                    Text(p.condition, style: TextStyle(color: dark?Colors.white: Colors.black, fontSize:  th* 21, fontWeight: FontWeight.w300)),),
                    
                  ],) 
              )

              ],),
                          )))))):Container(
                             width: w,
            height: h,
            child: Center(child: 
            GestureDetector(
              onTap: (){
                setState(() {
                  focus=false;
                });
              },
              child: ListView(
                children: [
                  
                  Container(height: h/15,),
                  Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("STORE4_ "), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*49),textAlign: TextAlign.center,)),
                Container(height: h/15,),Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("STORE5_ "), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*30),textAlign: TextAlign.center,)),
                Container(height: h/15,),Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("STORE6_ "), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*30),textAlign: TextAlign.center,)),
                Container(height: h/15,),Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("STORE7_ "), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*30),textAlign: TextAlign.center,)),
                Container(height: h/15,),Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("STORE8_ "), style: TextStyle(color:dark?Colors.white:Colors.black, fontSize: th*30),textAlign: TextAlign.center,)),
                 Container(height: h/15,),]),

              ),
                          ),
                        )):Container()
                
                        ])));
                  }
                
                  void buy(BuildContext context) async{
                    if(int.parse(pointstxt)>=int.parse(p.price.substring(0, p.price.length-2))){
                      //buy


                      DatabaseReference ref =  FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("D1");
                      String val1 = (await ref.once()).value;
                      String val = val1.substring(0, val1.indexOf("?"));


                      if(int.parse(val)>=int.parse(p.price.substring(0, p.price.length-2))){


                        MailS ss = new MailS();
                        await ss.sendo(context, p);
                        await ss.sends(FirebaseAuth.instance.currentUser.uid+" bought "+p.title , "email:"+FirebaseAuth.instance.currentUser.email+" , price:"+p.price+" , has: "+val);


                        int next = int.parse(val);
                        int next2 = int.parse(p.price.substring(0, p.price.length-2));

                        next = next-next2;

                        await ref.set(next.toString()+val1.substring(val1.indexOf("?")));
call(next.toString());


                        


                      }else{

                        Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s203_"), toastLength: Toast.LENGTH_SHORT);

                      }

                    


                    }else Fluttertoast.showToast(msg: AppLocalizations.of(context).translateKey("s203_"),toastLength: Toast.LENGTH_SHORT);
  }
  void call(String s){
    setState(() {
      focus = false;
      pointstxt = s;
    });
  }
}

class Products extends StatefulWidget {

  Hws hw;

  _ShopState state;

  Products(this.hw, this.state);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> with SingleTickerProviderStateMixin, WidgetsBindingObserver{


  

  double w; 
  double h;
   double th;

  bool isReady = false;

  List<Product> products;
  List<String> names;
  List<String> imgnames;

   Animation fadeanim;
   AnimationController fadecontr;

  PageController pc = PageController(initialPage: 0);

  bool dark = true;
  

  @override
  void initState() {
    super.initState();
    this.w = widget.hw.getWidth();
    this.h = widget.hw.getHeight();
    this.th = widget.hw.getTH();

    fadecontr = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    fadeanim = Tween(begin: 0.0,end:1.0).animate(fadecontr);

    names = List();
    imgnames = List();
    
    products=StaticSave.value("products");
    print("product:"+products.toString());
    if(products==null){
      buildProducts();
    }else{
      configName();
      setState(() {
        isReady=true;
        fadecontr.forward();
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      
    });
  }

  @override
  void dispose() {
    fadecontr.dispose();
    
    super.dispose();
  }

  void configName(){
    for (var i = 0; i < products.length; i++) {
      if(!names.contains(products[i].title)){
        names.add(products[i].title);
      }
    }
  }

  void buildProducts() async{
    products=List();
    String jsonBundle = await rootBundle.loadString('lang/products.json');
    print(jsonBundle);
    Map<String, dynamic> jsonMap = json.decode(jsonBundle);
    for (var i = 0; i < 15; i++) {
      var sub = jsonMap[(i+1).toString()][Localizations.localeOf(context).languageCode.toUpperCase()];

      Product product = Product(
        
        title: sub["title"], price: sub["price"],subtitle: sub["subtitle"], info: sub["info"], ending: sub["ending"], condition: sub["condition"], img: AssetImage("images/img_storage_product_${i+1}.png"));
      
      if(!names.contains(sub["title"])){
        names.add(sub["title"]);
        products.add(product);
      }
    }

    print(names);

    setState(() {
        isReady=true;
        fadecontr.forward();
      });

      StaticSave.save("products", products);
  }



  List<Widget> pageViews(){
    List<Widget> widgets = List();
    for (var i = 0; i < names.length; i++) {
      widgets.add(GestureDetector(
        onTap: (){
          widget.state.focusProduct(products[i]);
        },
        child: Container(
      width: w,
      height: h/2.5,
      child: Column(        mainAxisAlignment: MainAxisAlignment.center,
children: [
        Container(width: w/2,height: h/3,child: Container(
          child: Image(image: products[i].img)),),
        Container(child: Center(child: AutoSizeText(
          names[i],
          textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*40),)))
      ],),
      )));
    }
    widgets.add(GestureDetector(
        
        child: Container(
      width: w,
      height: h/2.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Container(width: w/1.1,height: h/12,child: Center(
          child: AutoSizeText(AppLocalizations.of(context).translateKey("s120_ "), style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*40),)),),
        Container(
          height: h/9,
          child: Center(child: AutoSizeText(
          AppLocalizations.of(context).translateKey("s121_ "),
          textAlign: TextAlign.center, style: TextStyle(color: dark?Colors.white:Colors.black, fontSize: th*32),))),
         Container(height: h/7, 
         child: Center(child: GestureDetector(
           onTap: () {
               widget.state.widget.state.updatePage(3, widget.state.widget.intentX);
    },
           
           
           child: Container(
           decoration: BoxDecoration(color: dark?Colors.white:Colors.black, borderRadius: BorderRadius.circular(90)),

           height: h/10, width: w/1.5,child: Center(child: AutoSizeText(AppLocalizations.of(context).translateKey("s122_ "),textAlign: TextAlign.center,  style: TextStyle(color: dark?Colors.black:Colors.white, fontSize: th*40),))),),)) 
      ],),
      )));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    dark = WidgetsBinding.instance.window.platformBrightness==Brightness.dark;
    return Container(
      width: w,
      height: h/2.5,
      child: isReady?FadeTransition(
        opacity: fadeanim as Animation<double>,
        child: PageView(
        controller: pc,
        children: pageViews(),
        
      )):Container()
    );
  }
}