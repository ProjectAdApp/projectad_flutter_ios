import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:projectad/env.dart';
import 'package:projectad/imp.dart';
import 'package:projectad/service/file_adapt.dart';
import 'package:projectad/service/varhandlerx.dart';

class QuoteAlgo{

  String uuid;

  final String newq = "?--?";
  final String solved = "!!";


  static String generateQuoteCode(String quote){
    print(quote);
    if(quote.startsWith(" ") )quote = quote.substring(1);
    if(quote.endsWith(" "))quote=quote.substring(0,quote.length-1);
    List<String> words = quote.split(" ");
    String code = "";
    words.forEach((element) {
      print(element);
      if(element!=null && element.length>0){
      code = code + element.substring(0,1);
      }
    });
    return code;
  }
  

  Future<List<String>> callResult(String uuid, Locale locale) async{

    this.uuid= uuid;



    //get the cloud data for a result
    //possible results:
    //1. new quote
    //2. quote is finished
    //3. quote is not finished

    //returns the displaying text
    
    
    print("callResult");

    String obj = (await FirebaseDatabase.instance.reference().child("Users/"+uuid+"/B1").once()).value;

  

    if(obj==newq){
      //generate new quote
      if(!shortblock)return generateNewQuote(uuid, locale);
    }
    if(obj.startsWith("!!")){
      //quote is solved
      return [obj.substring(2)];
    }
    return [obj.substring(0, obj.indexOf("%")), obj.substring(obj.indexOf("%%")+2, obj.indexOf('\u0024')==-1?obj.length:obj.indexOf('\u0024'), )];
  }



  Future<List<String>> generateNewQuote(String uuid, Locale locale) async{

    print("generateNewQuote");

    //clear old quote

    await QuoteDataHandler.kill();
    
        String quote;
    
        if(locale.languageCode=="de"){
          quote =  await getGermanQuotes();
        }
        if(locale.languageCode=="en"){
          quote =  await getEnglishQuotes();
        }
        if(locale.languageCode=="fr"){
          quote =  await getFrenchQuotes();
        }

        print("loading new quotation:"+quote);
    
        //list words into a map (not a list)
    
        HashMap map = getWords(quote);
    
        //pick a random element
    
        Random r = new Random();
        int rane = r.nextInt(map.length);
        
        String failword = map[rane];
    
        int indexX1 = getIndexOfXChar(quote," ",rane);
        int indexX2 = getIndexOfXChar(quote," ",rane+1);
    
        String ss1 = quote.substring(0, indexX1+1);
        String ss2 = quote.substring(indexX1+1, indexX2!=-1?indexX2:quote.length);
        String ss3 = indexX2!=-1?quote.substring(indexX2):"";
    
        String replacement = fillStringWith(failword.length, "_");
        print("the replacement $replacement");
    
        ss2 = ss2.replaceAll(failword, replacement);
    
        Vhx vhx = new Vhx(null, false);
        vhx.supportMultiple(true);
    
        String finished = ss1+ss2+ss3;
    
        String ssresult = finished+"%%"+failword;
    
        vhx.setMultiple(finished, "0");
        vhx.setMultiple(failword, "1");
        print(ssresult);

        this.shortblock=true;

        if(!ssresult.contains("_"))return generateNewQuote(uuid, locale);
        else{
        await FirebaseDatabase.instance.reference().child("Users/"+uuid+"/B1").set(ssresult);

        this.shortblock=false;
    
        return [finished, failword];
        }
    
      }

      bool shortblock = false;
    
      String fillStringWith(int lenght, String spam){
        String s = "";
        for (var i = 0; i < lenght; i++) {
          s = s + spam;
        }
        return s;
      }
    
      HashMap getWords(String q){
        HashMap map = new HashMap();
        int pos = 0;
        for (var i = 0; i < q.length; i++) {
          int index1 = getIndexOfXChar(q, " ", i);
          int index2 = getIndexOfXChar(q, " ", i+1);
        
          if(index2!=-1){
            map[pos]=clearWord(q.substring(index1+1, index2), clearlist);
            pos++;
            
          }else{
            map[pos]=clearWord(q.substring(index1+1), clearlist);
            pos++;
            break;
          }
        }
        return map;
      }
    
      List<String> clearlist = [".",",",":","%",'\u0024',"/","!","?","-","–"," "];
    
      String clearWord(String word, List<String> badcharacters){
        badcharacters.forEach((element) {
          if(word.contains(element))word.replaceAll(element, "");
        });
        return word;
      }
    
      int getIndexOfXChar(String src, String search, int timesbefore){
    
        //ex: src: Hallo, search: l, timesbefore; 0
        //
        // --> H!=l
        // --> a!=l
        // --> l==l --> how many l were before: 0 --> return the index
        //actually ist over but...
        // --> l==l --> how many l were before: 1 !
        // --> a!=l
    
        for (int i = 0; i < src.length; i++) {
          String result = src.substring(i, i+1);
          //print(result+"result == search "+search);
          if(result==search){
            if(timesbefore==0)return i;
            timesbefore--;
          }
        }
    
        //there dosne't exist (timesbefore+1) objects of (search)
        return -1;
      }
    
      DatabaseReference getPath(){
        return FirebaseDatabase.instance.reference();
      }
    
      int ix,iy;

      Future<String> decryptData(String code) async{


          String data = await decrypt(code);
          print("this is data");


        try{
          List<dynamic> arr = jsonDecode(data);

          Random random = new Random();
          int nrx = random.nextInt(arr.length);

          String code0 = arr[nrx];
          
          return code0;
        }catch(e){
          return "e";
        }
      }

      Future<String> decrypt(String code) async{
        Digest sha1 = Digest("SHA-1");
Uint8List key = sha1.process(utf8.encode(Env.quotesKey)).sublist(0, 16);
Uint8List ciphertext = base64.decode(code);
ECBBlockCipher cipher = ECBBlockCipher(AESFastEngine());
PaddedBlockCipher paddedCipher = new PaddedBlockCipherImpl(new PKCS7Padding(), cipher);
PaddedBlockCipherParameters<CipherParameters, CipherParameters> paddingParams = new PaddedBlockCipherParameters(KeyParameter(key), null);
paddedCipher.init(false, paddingParams);
Uint8List plainText = paddedCipher.process(ciphertext);
return (utf8.decode(plainText));
       
      }
    
      Future<String> getGermanQuotes() async {
        Random ran = new Random();
        ix = ran.nextInt(3);//0,1,2,3
        iy = ran.nextInt(100);//0,1,2,...,99

        int var0 = ran.nextInt(2);

        final d = Directory((await getApplicationDocumentsDirectory()).path+"/cry");

        File f = new File(d.path+"/quotes_de"+var0.toString()+".cry");

        String s = await decryptData(await f.readAsString());
        if(s == "e")return getGermanQuotes();
        return s;

    
      //  return (await getPath().child("QuotesDeutsch").child(ix.toString()).child(iy.toString()).once()).value;
      }
      Future<String> getEnglishQuotes() async{
        Random ran = new Random();
        ix = ran.nextInt(50);//0,1,..,49
        iy = ran.nextInt(100);//0,1,2,...,99
    
        int var0 = ran.nextInt(49);

        final d = Directory((await getApplicationDocumentsDirectory()).path+"/cry");

        File f = new File(d.path+"/quotes_en"+var0.toString()+".cry");

        String s = await decryptData(await f.readAsString());
        if( s  == "e")return getEnglishQuotes();
        return s;
      }
      Future<String> getFrenchQuotes(){
        return getEnglishQuotes();
      }
    }
    
    class QuoteDataHandler{
    
      static final seperators = ["#",","];
    
      String src;
      QuoteDataHandler(this.src);
    
      String getQuoteCode(){
        print(src);
        if(src=="")return "";
        return src!=""?src.substring(0, src.indexOf(seperators[0])):"";
      }
    
      List<String> getJokers(){
        print(src);
        if(src=="")return null;
        return src!=""?src.substring(src.indexOf(seperators[0])+1).split(","):"" as List<String>;
      }
    
      static String _real(List<String> x){
        String s = "";
        x.forEach((element) {
          s = s +","+ element;
        });
        return s;
      }
    
      static Future<void> setData(String qc, List<String> jokers) async {
        String data = qc+seperators[0]+_real(jokers);
        await FileAdapter().writeFile("quoters.txt", data);
      }
    
      static Future<void>kill() async{
        await FileAdapter().writeFile("quoters.txt", "");
      }

}

class QuotePre {

  static Future<bool> check() async{

    final output = await getApplicationDocumentsDirectory();
    File zip_f = new File(output.path+"/cry/quotes_de1.cry");
    return await zip_f.exists();

  }

  static Future<void> access() async{
    print("access1");
    final zipFile = await rootBundle.load('srcs/cry.zip');
  
    File fx = new File(Directory.systemTemp.path+"/ueo"+DateTime.now().millisecondsSinceEpoch.toString());
    print(fx);
    fx.createSync();
    fx.writeAsBytesSync(zipFile.buffer.asUint8List(zipFile.offsetInBytes, zipFile.lengthInBytes));
    print("access");
    print(zipFile);
    final output = await getApplicationDocumentsDirectory();
    Directory zip_f = new Directory(output.path+"/cry");
    if(!await zip_f.exists()){

      await zip_f.create();

    }

    try {
      await ZipFile.extractToDirectory(zipFile: fx, destinationDir: zip_f);
      fx.delete();
    } catch (e) {
      print(e);
    }



  }
}