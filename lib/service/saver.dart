import 'dart:collection';

class StaticSave{

  //this is a static class
  //runtime:
  //all vars will be destroyed after the user colsed the app
  //in the app the vars will be available in all possible classes

  static HashMap _hashMap = new HashMap();

  static void save(String name, dynamic value){
    _hashMap[name]=value;
    print(_hashMap);
  }

  static dynamic value(String name){
    if(!_hashMap.keys.contains(name))return null;
    return _hashMap[name];
  }

}