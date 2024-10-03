import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


import '../widgets/confirmationDialog.dart';
import 'enum.dart';

class staticVar {


  static TextStyle t1 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Color.fromRGBO(114, 128, 150, 1));

  static DataColumn Dc(String name) =>
      DataColumn(
        label: Center(
          child: Text(
            name,
            style: staticVar.t1,
          ),
        ),
      );

  static DataColumn Dc2(String name) =>
      DataColumn2(
        fixedWidth: 300,

        label: Center(
          child: Text(
            name,
            style: staticVar.t1,
          ),
        ),
      );

  static TextStyle titleStyle = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: Color.fromRGBO(20, 53, 96, 1));

  static TextStyle subtitleStyle1 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Color.fromRGBO(20, 53, 96, 1));

  static TextStyle tableTitle = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Color.fromRGBO(20, 53, 96, 1));

  static TextStyle subtitleStyle2 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Color.fromRGBO(114, 128, 150 , 1));
  static TextStyle subtitleStyle3 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Color.fromRGBO(114, 128, 150 , 1));

  static TextStyle subtitleStyle4Warrining = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Colors.red);

  static TextStyle subtitleStyle4Warrining2 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Colors.red);

  static TextStyle subtitleStyle4 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Colors.black);

  static TextStyle subtitleStyle5 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: Color.fromRGBO(20, 53, 96, 1));

  static TextStyle subtitleStyle6 = TextStyle(
      fontFamily: 'louie',
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Colors.black);

  static Color buttonColor = Color.fromRGBO(20, 53, 96, 1) ;

  static void showOverlay({
    required BuildContext ctx,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: ctx,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: onEdit,
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: onDelete,
              ),
            ],
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
    );
  }



  static double golobalWidth(BuildContext context ) => MediaQuery.of(context).size.width * 0.95 ;
  static double golobalHigth(BuildContext context ) => MediaQuery.of(context).size.height * 0.95 ;

  static double fullWidth(BuildContext context ) => MediaQuery.of(context).size.width  ;
  static double fullhigth(BuildContext context ) => MediaQuery.of(context).size.height  ;

  static Color c1 = Color.fromRGBO(33, 103, 199, 1) ;

  static Widget divider()=>  Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey , width:  .5)),);



  static Widget loading ({ double size = 100 , Color colors =const  Color(0xFF1ABC9C) , bool disableCenter = false })=> disableCenter ?  LoadingAnimationWidget.staggeredDotsWave(color:colors , size: size,) :    Center(child: LoadingAnimationWidget.staggeredDotsWave(color:colors , size: size,),);



  static Future<void> showSubscriptionSnackbar({required BuildContext context , required String msg , Color color = const Color(0xFF1ABC9C) }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(msg),
      ),
    );
  }


  static String formatDateFromTimestamp(dynamic input) {
    try {
      DateTime dateTime;

      if (input is Timestamp) {
        // Convert Timestamp to DateTime
        dateTime = DateTime.fromMillisecondsSinceEpoch(input.seconds * 1000);
      } else if (input is DateTime) {
        // Input is already DateTime
        dateTime = input;
      } else {
        // Handle other cases
        throw Exception('Invalid input type');
      }

      // Format the DateTime
      String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);

      return formattedDate;
    }
    catch(e){
      print("Error $e");
      return "Error $e";
    }
  }

  /// this function with show the timestamp as date with time ex,, 24 may 2024 15.00
  static String formatDateFromTimestampWithTime(dynamic input) {
    try {
      DateTime dateTime;

      if (input is Timestamp) {
        // Convert Timestamp to DateTime
        dateTime = DateTime.fromMillisecondsSinceEpoch(input.seconds * 1000);
      } else if (input is DateTime) {
        // Input is already DateTime
        dateTime = input;
      } else {
        // Handle other cases
        throw Exception('Invalid input type');
      }

      // Format the DateTime
      String formattedDate = DateFormat('dd MMM yyyy HH:mm').format(dateTime);

      return formattedDate;
    }
    catch(e){
      print("Error $e");
      return "Error $e";
    }
  }

  /// this function will return small container represnt the payment status
  static Widget getPaymentStatusWidget({required String status2}) {
    Color statusColor;
    String statusText;

    PaymentStatus status = parseToPaymentStatus(status2);
    // Determine color and text based on status
    switch (status) {
      case PaymentStatus.paid:
        statusColor = Colors.green;
        statusText = "Plătit";
        break;
      case PaymentStatus.unpaid:
        statusColor = Colors.red;
        statusText = "Neplătit";
        break;
      case PaymentStatus.partiallyPaid:
        statusColor = Colors.orange;
        statusText = "Parțial plătit";
        break;
      case PaymentStatus.init:
        statusColor = Colors.blue;
        statusText = "Inițializare";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Necunoscut";
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

 /// this function will return small container represnt the order status
  static Widget getOrderStatusWidget({required String status2 }) {
    Color statusColor;
    String statusText;

    orderStatus status = parseToOrderStatus(status2);

    // Determine color and text based on status
    switch (status) {
      case orderStatus.pending:
        statusColor = Colors.orange;
        statusText = "În așteptare";
        break;
      case orderStatus.canceled:
        statusColor = Colors.red;
        statusText = "Anulat";
        break;
      case orderStatus.inProgress:
        statusColor = Colors.blue;
        statusText = "În progres";
        break;
      case orderStatus.completed:
        statusColor = Colors.green;
        statusText = "Finalizat";
        break;
      case orderStatus.init:
        statusColor = Colors.grey;
        statusText = "Inițializare";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Necunoscut";
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// this function will return color represnt the order status
  static Color getOrderStatusColor({required String status2 }) {
    Color statusColor;
    String statusText;

    orderStatus status = parseToOrderStatus(status2);

    // Determine color and text based on status
    switch (status) {
      case orderStatus.pending:
        statusColor = Colors.orange;
        break;
      case orderStatus.canceled:
        statusColor = Colors.red;
        break;
      case orderStatus.inProgress:
        statusColor = Colors.blue;
        break;
      case orderStatus.completed:
        statusColor = Colors.green;
        break;
      case orderStatus.init:
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return statusColor;
  }

  /// this function will return small container represnt the emplyee paument status
  static Widget empPaymentStatus({required bool status2 }) {
    Color statusColor;
    String statusText;

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color:status2 ? Colors.green :  Colors.red,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        status2 ? "Plătit"  : "Neplătit",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }










  /// this is to deal with events colors
  static final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
  ];

  static int _currentIndex = 0;

  static Color getNextColor() {
    Color nextColor = colors[_currentIndex];
    _currentIndex = (_currentIndex + 1) % colors.length;
    return nextColor;
  }


  static bool inRomanian = true  ;










}







