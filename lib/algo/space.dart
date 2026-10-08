import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectad/service/file_adapt.dart';
import 'package:intl/intl.dart' as intl;

class WideSpaceResolver{

  String src;

  final separators = ["#","!",","];

  String updatetimestring;
  int updatetimeint;

  String quotesolvedstring;
  int quotesolvedint;

  String jokerusedstring;
  int jokerusedint;

  List<int> daylist;
  String daystring;

  List<int> weeklist;
  String weekstring;

  List<int> monthlist;
  String monthstring;

  String privacystring;

  QuoteSpaceConnector connector;


  //case: 0,0,0,0,0  position of the 3rd (3.) , is 5. Result: 5. Search: ",". Count: 3
  int getPositionOfCountedObject(String content, String search, int count){

    int curr = 0;


    for (var i = 0; i < content.length; i++) {
      String segment = content[i];//char at pos 0 till content.lenght

      if(segment==search){
        curr++;
        //curr shows how often the search was already found
        //object found
        
        if(curr==count)return i;

      }

    }
    return -1;
  }

  List<int> codeList(List<String> strings){
    List<int> ints = List();
    for (String s in strings) {
      ints.add(int.parse(s));
    }
    return ints;
  }

  WideSpaceResolver(this.src){

    //prepare

    //updatetime#quote_solvedjoker_used,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0+M
    //                                         DAY              |      WEEK    |                          MONTH                               |Privacy

    this.connector=new QuoteSpaceConnector();

    print(src);

    updatetimestring = src.substring(0, src.indexOf(separators[0]));
    updatetimeint = int.parse(updatetimestring);
    print(updatetimestring);

    quotesolvedstring = src.substring(src.indexOf(separators[0])+1, src.indexOf(separators[1]));
    quotesolvedint = int.parse(quotesolvedstring);
    print(quotesolvedstring);

    jokerusedstring = src.substring(src.indexOf(separators[1])+1, src.indexOf(separators[2]));
    jokerusedint = int.parse(jokerusedstring);
    print(jokerusedstring);

    int daypos = getPositionOfCountedObject(src, ",",13);//of 13
    int weekpos = getPositionOfCountedObject(src, ",", 20);//of 20
    int monthpos = src.length-2;

    daystring = src.substring(src.indexOf(separators[2])+1, daypos);
    daylist = codeList(daystring.split(","));

    weekstring = src.substring(daypos+1, weekpos);
    weeklist = codeList(weekstring.split(","));

    monthstring = src.substring(weekpos+1, monthpos);
    monthlist = codeList(monthstring.split(","));

    privacystring = src.substring(src.length-2);

  }

  String prepareSource(){
    return DateTime.now().millisecondsSinceEpoch.toString()+separators[0]+quotesolvedstring+separators[1]+jokerusedstring+separators[2]+daystring+separators[2]+weekstring+separators[2]+monthstring+privacystring;
  }

  String prepareSource$(){
    return updatetimestring+separators[0]+quotesolvedstring+separators[1]+jokerusedstring+separators[2]+daystring+separators[2]+weekstring+separators[2]+monthstring+privacystring;
  }

  void updateJokerUse(){
    if(jokerusedint==null)jokerusedint=0;
    jokerusedint+=1;
    jokerusedstring = jokerusedint.toString();

    connector.saveChanges(prepareSource());

  }

  Future<void> update() async{

    connector.saveChanges(prepareSource());
    connector.finishQuote();

  }

  WideSpaceResolver safetyReload() {

    SpaceCheck check = SpaceCheck(this);
    WideSpaceResolver r0 = this;
    if(check.day()){
      r0 = clearDay(r0);
    }
    if(check.week()){
      if(r0 == null)r0 = this;
      r0 = clearWeek(r0);
    }

    if(check.month()){
      if(r0 == null)r0 = this;
      r0 = clearMonth(r0);
    }

    print(r0);

    return r0;


  }

  void updateQuoteSolve() async{

    this.updatetimeint=DateTime.now().microsecondsSinceEpoch;
    this.updatetimestring = updatetimeint.toString();
    //print(updatetimestring);

    //print(quotesolvedint);
    this.quotesolvedint+=1;
    this.quotesolvedstring = this.quotesolvedint.toString();
    //print(quotesolvedstring);

    int daytime = DateTime.now().hour;
    int daytime$index = daytime%2==0?(daytime/2).round():((daytime-1)/2).round();

    //print(daystring);

    //print(daytime$index);

    daylist[daytime$index]++;
    daystring = daylist.join(",");

    //print(daystring);

    int weektime = DateTime.now().weekday;
    int week$index /*this is because of (java.util.Data.week) */ =// weektime==7?weektime=0:weektime;
weektime-1;
    print("actual time__"+week$index.toString());

    weeklist[week$index]++;
    weekstring = weeklist.join(",");

    print(weekstring);

    int monthtime = DateTime.now().day;
    int monthtime$index = monthtime-1;

    print(monthtime$index);

    print(monthstring);

    monthlist[monthtime$index]++;
    monthstring = monthlist.join(",");

    print(monthstring);
    

    await connector.saveChanges(prepareSource());

    connector.finishQuote();

    print("final value"+prepareSource());

  }

   WideSpaceResolver clearDay(WideSpaceResolver wsr){
    print("clearD");
    for (var i = 0; i < wsr.daylist.length; i++) {
      wsr.daylist[i]=0;
    }
    wsr.daystring = wsr.daylist.join(",");
    return wsr;
  }
   WideSpaceResolver clearWeek(WideSpaceResolver wsr){
    print("clearW");
    for (var i = 0; i < wsr.weeklist.length; i++) {
      wsr.weeklist[i]=0;
    }
    wsr.weekstring = wsr.weeklist.join(",");
    return wsr;
  }
  WideSpaceResolver clearMonth(WideSpaceResolver wsr){
    print("clearM");
    for (var i = 0; i < wsr.monthlist.length; i++) {
      wsr.monthlist[i]=0;
    }
    wsr.monthstring = wsr.monthlist.join(",");
    return wsr;
  }

  
  bool equals(WideSpaceResolver wsr){

    return wsr.connector == connector
    && wsr.daylist == daylist
    && wsr.weeklist == weeklist
    && wsr.monthlist == monthlist
    && wsr.privacystring == privacystring
    && wsr.src == src;

  }




} 

class QuoteSpaceConnector{



  // a txt file, which represents the updated space src

  //the data of the file will be uploaded at a specific time

  //this reduces the cloud transfer count

  //the data will be published when you solve the quote

  Future<bool> saveChanges(String preparedsrc){
    return FileAdapter().writeFile("connector.txt",preparedsrc);
  }

  void finishQuote() async{
    String data = await FileAdapter().readFile("connector.txt");

    DatabaseReference ref = FirebaseDatabase.instance.reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("F");
    await ref.set(data);

  }

}

class SpaceCheck{
 
  int time;
  WideSpaceResolver resolver;

  SpaceCheck(this.resolver){
    this.time=resolver.updatetimeint;
  }

  bool day(){

    //day break
    
    DateTime now = DateTime.now();
    int timeNow = now.millisecondsSinceEpoch;

    int dayBreak = timeNow - (now.millisecond + now.second * 1000 + now.minute * 60 * 1000 + now.hour * 3600 * 1000 );

    return (resolver.updatetimeint < dayBreak);
  }
  bool week(){
    List<int> week = resolver.weeklist;

    //check last week break
    
    DateTime now = DateTime.now();
    int timeNow = now.millisecondsSinceEpoch;

    int weekBreak = timeNow - (now.millisecond + now.second * 1000 + now.minute * 60 * 1000 + now.hour * 3600 * 1000 ) - (now.weekday-1)*86400000;
  
    return (resolver.updatetimeint < weekBreak);

  }
  bool month(){

    DateTime now = DateTime.now();
    int timeNow = now.millisecondsSinceEpoch;

    int monthBreak = timeNow - (now.millisecond + now.second * 1000 + now.minute * 60 * 1000 + now.hour * 3600 * 1000 ) - (now.day - 1)*86400000;

    return (resolver.updatetimeint < monthBreak);

    
  }

}