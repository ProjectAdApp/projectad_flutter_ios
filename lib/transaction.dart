import 'package:flutter/material.dart';
import 'package:projectad/service/hws.dart';

Route createTRoute(Hws hw) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TransactionPage(hw),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
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

class TransactionPage extends StatefulWidget {
  //const TransactionPage({ Key? key }) : super(key: key);

  final Hws hw;
  TransactionPage(this.hw);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
