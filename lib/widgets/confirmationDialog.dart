


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class confirmationDialog{

  static void showElegantPopup({
    required BuildContext context,
    required String message,
    required VoidCallback  onYes,
    required VoidCallback onNo,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                onNo();
                Navigator.of(context).pop();
              },
              child: Text('Nu'),
            ),
            TextButton(
              onPressed: () {
                onYes();
                Navigator.of(context).pop();
              },
              child: Text('Da'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showElegantPopupWait({
    required BuildContext context,
    required String message,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                onNo();
                Navigator.of(context).pop();
              },
              child: Text('Nu'),
            ),
            TextButton(
              onPressed: () {
                onYes();
                Navigator.of(context).pop();
              },
              child: Text('Da'),
            ),
          ],
        );
      },
    );
  }




  static Future<void> showElegantPopupFutureVersion({
    required BuildContext context,
    required String message,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) async {
    Completer<void> completer = Completer<void>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                onNo();
                Navigator.of(context).pop();
                completer.complete();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                onYes();
                Navigator.of(context).pop();
                completer.complete();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }
}

