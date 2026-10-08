
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class FileAdapter{

Future<String> readFile(String name) async {
  String text;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$name');
    text = await file.readAsString();
  } catch (e) {
    text = "404";
  }
  return text;
}

Future<bool> writeFile(String name, String content) async{
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$name');
    await file.writeAsString(content);
    return true;
  } catch (e) {
    return false;
  }
}


Future<String> readAsset(String dir, String name) async{
   return await rootBundle.loadString('$dir/$name');
}


}