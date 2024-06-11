import 'dart:collection';

import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/dummy_data.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class services extends StatefulWidget {
  const services({super.key});

  @override
  State<services> createState() => _servicesState();
}

class _servicesState extends State<services> {
  bool newServiseMode = false;
  bool isContract = false ;
  String serviceName = "";
  String price = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Tooltip(
          message: "Adăugați un nou serviciu",
          child: newServiseMode
              ? Button(
                  onTap: sendToFirestore,
                  text: "adaugă",
                  color: Color(0xFF1ABC9C),
                )
              : FloatingActionButton(
                  onPressed: () {
                    this.newServiseMode = true ;
                    setState(() {});
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  backgroundColor: Color(0xFF1ABC9C),
                )),
      body:newServiseMode ? Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextFieldWidget(
              isItNumerical: false ,
              label: 'Nume Serviciu',
              hintText: 'Introduceți numele serviciului',
              onChanged: (s){print(s);},

            ),
            SizedBox(height: 16.0),
            customTextFieldWidget(
              label: 'Preț Serviciu',
              hintText: 'Introduceți prețul serviciului',
              isItNumerical: true,
              onChanged: (ss){},
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Contract:',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(width: 16.0),
                Switch(
                  value: isContract,
                  onChanged: (value) {
                    setState(() {
                      isContract = value;
                    });
                  },
                  activeColor: Color(0xFF1abc9c), // Green color when switch is on
                ),
              ],
            ),
            SizedBox(height: 16.0),

          ],
        ),
      ) :
      Center(
        child: Container(
            width: staticVar.golobalWidth(context),
            height: staticVar.golobalHigth(context),
            decoration: BoxDecoration(
                //    border: Border.all(color: Colors.black.withOpacity(.33)),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white),
            child: Card(
                elevation: 1,
                child: Center(
                  child: DataTable2(
                    columnSpacing: 5,
                    columns: [
                      staticVar.Dc("Nume serviciu"),
                      staticVar.Dc("Preț"),
                      staticVar.Dc("Contractat")
                    ],
                    rows: dummy.carCleaningServices.map((e) {
                      return DataRow(onLongPress: () {}, cells: [
                        DataCell(Center(child: Text(e["str"]))),
                        DataCell(Center(child: Text(e["price"].toString()))),
                        DataCell(Center(
                            child: Text(e["contractor_price"].toString()))),
                      ]);
                    }).toList(),
                  ),
                ))),
      ),
    );
  }



  void sendToFirestore() async {
    try {
      // Accessing the Firestore instance
      if(this.serviceName.trim() == "" || this.price.trim() == ""){
        MyDialog.showAlert(context, "Da", "Vă rugăm să completați toate câmpurile din formulare, inclusiv prețul și numele serviciilor. Vă mulțumim pentru colaborare!");

        return;
      }

      return ;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Adding data to Firestore
      await firestore.collection('services').add({
        'isContract': isContract,
        'serviceName': serviceName.trim(),
        'price': price.trim(),
      });

      print('Data added to Firestore successfully.');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }


}
