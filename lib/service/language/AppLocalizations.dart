import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations{
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of (BuildContext context){
    return Localizations.of<AppLocalizations>(context,   AppLocalizations);
  
  
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocationsDelegate();

  Map<String, String> _lS;
  Map<String,String> _shortS = new Map();
  Future<bool> load() async {
    print("lang:"+locale.languageCode);
    String jsonBundle = 
      await rootBundle.loadString('lang/lang.json');
      Map<String, dynamic> jsonMap = json.decode(jsonBundle);

      jsonMap.forEach((key, value) {
        if(key.endsWith(locale.languageCode))_shortS[key.substring(0, key.length-2)]=value;
      });

      _lS = jsonMap.map((key, value){
      return MapEntry(key, value.toString());});

      return true;
    
  }

  String translateText(String text){
    //search text in _lS
    String fser, fps;
    _lS.forEach((key, value){
      if(value==text){
        fser=key;
      }else{
        if(value.contains(text)){
          fps=key;
        }
      }
    });
  
    fser = fser!=null?fser:(fps!=null?fps:"");
    fser = fser.substring(0, fser.length-2);

    return _shortS[fser];

  }
  String translateKey(String key){
    return _shortS[key];
  }
}
  class _AppLocationsDelegate extends LocalizationsDelegate<AppLocalizations> {
      const _AppLocationsDelegate();

      @override
  bool isSupported(Locale locale) {
    print(locale.languageCode);

    return ['en','de','fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
        AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;


  }