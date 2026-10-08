import 'dart:collection';

/// Simple hander with x (10th-Level) code.
/// @author Valentin Ahrend
/// @version 1.0
/// @since 06.09.20
/// 
/// this class is used to handle variables in a smart an easy handling way.
/// handling means to set, save and get the T-operator variables 

class Vhx{
  Object localvariable;
  HashMap localvariables = new HashMap();
  bool multipleSupported=false;

  Vhx(Object v, bool m){
    if(v==null)return;
    this.multipleSupported=m;
    if(multipleSupported || v.runtimeType==localvariable.runtimeType)throw new FormatException();
    this.localvariable=v;
  }

  void supportMultiple(bool s){
    this.multipleSupported=s;
  }

  Object get(){
    if(multipleSupported)throw new FormatException();
    return localvariable;
  }

  void set(Object v){
    if(multipleSupported)throw new FormatException();
    this.localvariable=v;
  }

  Object getFromMultiple(String name){
    if(!multipleSupported)throw new FormatException();
    return localvariables[name];
  }

  void setMultiple(Object v, String name){
    if(!multipleSupported)throw new FormatException();

    
    this.localvariables[name]=v;
    
  }


  


}