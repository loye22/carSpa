import 'package:flutter/material.dart';

class MyDialog {
  static void showAlert(BuildContext context, String e , String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title' , style: TextStyle(fontSize: 18),),
       // content: Text('$e'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }







}