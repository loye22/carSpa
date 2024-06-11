import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


import '../widgets/confirmationDialog.dart';

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

  static Color c1 = Color.fromRGBO(33, 103, 199, 1) ;

  static Widget divider()=>  Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey , width:  .5)),);



  static Widget loading ({ double size = 100 , Color colors =const  Color(0xFF2C3E50) })=> Center(child: LoadingAnimationWidget.staggeredDotsWave(color:colors , size: size,),);

  static Future<void> showSubscriptionSnackbar({required BuildContext context , required String msg}) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
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


}







