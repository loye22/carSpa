import 'dart:html';

import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/confirmationDialog.dart';
import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/dummy_data.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class services extends StatefulWidget {
  const services({super.key});

  @override
  State<services> createState() => _servicesState();
}

class _servicesState extends State<services> {
  bool newServiseMode = false;
  bool isContract = false;
  bool isLoading = false;
  bool editMode = false;

  String serviceName = "";
  String price = "";

  List<Map<String, dynamic>> servicesFromFirebase = [];

  Map<String,dynamic> editDataMode = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: Duration(milliseconds: 900))],
      child: Scaffold(
        floatingActionButton: editMode ?
        // will handel the edit mode actions
        this.isLoading
            ? staticVar.loading(disableCenter: true)
            : Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // The update function
            // this funciton will be updating the DB using editDataMode Map

            Button(
              onTap:updateRecord,
              text: "Actualizare",
              color: Color(0xFF1ABC9C),
            ),
            Button(
              onTap: () {
                this.editMode = false;
                editDataMode = {} ;
                setState(() {});
              },
              text: "Înapoi",
              color: Colors.red,
            ),
          ],
        )
        // this gonna hanel the new servises mode
            :(newServiseMode
            ? (this.isLoading
            ? staticVar.loading(disableCenter: true)
            : Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              onTap: sendToFirestore,
              text: "adaugă",
              color: Color(0xFF1ABC9C),
            ),
            Button(
              onTap: () {
                this.newServiseMode = false;
                setState(() {});
              },
              text: "Back",
              color: Colors.red,
            ),
          ],
        ))
            : Tooltip(
          message: "Adăugați un nou serviciu",
          child: FloatingActionButton(
            onPressed: () {
              this.newServiseMode = true;
              setState(() {});
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Color(0xFF1ABC9C),
          ),
        )),
        body: editMode
             // this part gonna hadel the edit mode
            ? Animate(
          effects: [
            FadeEffect(duration: Duration(milliseconds: 900))
          ],
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customTextFieldWidget(
                  editMode: true,
                  initialValue: editDataMode["serviceName"] ?? "404NotFound",
                  isItNumerical: false,
                  label: 'Nume Serviciu',
                  hintText: 'Introduceți numele serviciului',
                  onChanged: (servise) {
                    editDataMode["serviceName"]  = servise;
                  },
                ),
                SizedBox(height: 16.0),
                customTextFieldWidget(
                  editMode: true,
                  initialValue:editDataMode["price"].toString() ?? "404NotFound" ,
                  label: 'Preț Serviciu',
                  hintText: 'Introduceți prețul serviciului',
                  isItNumerical: true,
                  onChanged: (price2) {
                    editDataMode["price"]  = price2;
                  },
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Contract:',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(width: 16.0),
                        Switch(
                          value: editDataMode["isContract"] ?? false ,
                          onChanged: (value) {
                            setState(() {
                              editDataMode["isContract"]  = value;
                            });
                          },
                          activeColor: Color(
                              0xFF1abc9c), // Green color when switch is on
                        ),
                      ],
                    ),
                    Text(
                        "Când activați acest comutator, înseamnă că prețul acestui serviciu va fi specificat pentru contractori.")
                  ],
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        )
            :
            // this part gonna handel the display data and add new servises
            (newServiseMode
                ? Animate(
                    effects: [
                      FadeEffect(duration: Duration(milliseconds: 900))
                    ],
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customTextFieldWidget(
                            isItNumerical: false,
                            label: 'Nume Serviciu',
                            hintText: 'Introduceți numele serviciului',
                            onChanged: (servise) {
                              this.serviceName = servise;
                            },
                          ),
                          SizedBox(height: 16.0),
                          customTextFieldWidget(
                            label: 'Preț Serviciu',
                            hintText: 'Introduceți prețul serviciului',
                            isItNumerical: true,
                            onChanged: (price2) {
                              this.price = price2;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    activeColor: Color(
                                        0xFF1abc9c), // Green color when switch is on
                                  ),
                                ],
                              ),
                              Text(
                                  "Când activați acest comutator, înseamnă că prețul acestui serviciu va fi specificat pentru contractori.")
                            ],
                          ),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  )
                : Animate(
                    effects: [
                      FadeEffect(duration: Duration(milliseconds: 1200))
                    ],
                    child: Center(
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
                                    staticVar.Dc("Preț / Lei"),
                                    staticVar.Dc("Contractat"),
                                    staticVar.Dc("Adauga la"),
                                    staticVar.Dc("Actiuni")
                                  ],
                                  rows: this.servicesFromFirebase.map((e) {
                                    String nameMap =
                                        e["serviceName"] ?? "NotFound404";
                                    String priceMap =
                                        e["price"]?.toString() ?? "NotFound404";
                                    bool isContractMap =
                                        e["isContract"] ?? false;
                                    dynamic date =
                                        e["addedAt"] ?? "NotFound404";

                                    return DataRow(onLongPress: () {}, cells: [
                                      DataCell(Center(child: Text(nameMap))),
                                      DataCell(Center(child: Text(priceMap))),
                                      DataCell(
                                        Center(
                                            child: isContractMap
                                                ? StatusLabel(
                                                    color: Colors.green,
                                                    text: "B2B",
                                                  )
                                                : Text("*****")),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            staticVar
                                                .formatDateFromTimestamp(date),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  this.editMode = true ;
                                                  this.editDataMode = e ;
                                                  setState(() {});
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  await deleteServiceByDocId(
                                                      docId: e["docId"],
                                                      context: context);
                                                  print(
                                                      'Delete button pressed');
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ))),
                    ),
                  )),
      ),
    );
  }

  // this function will insert new servise to the Database
  void sendToFirestore() async {
    try {
      isLoading = true;
      setState(() {});
      // Accessing the Firestore instance
      double priceAsDouble = double.tryParse(price.trim()) ?? 0.0;
      if (this.serviceName.trim() == "" ||
          this.price.trim() == "" ||
          priceAsDouble == 0) {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați toate câmpurile din formulare, inclusiv prețul și numele serviciilor. Vă mulțumim pentru colaborare!");
        print("please enter all the data ");

        isLoading = false;
        setState(() {});
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Adding data to Firestore
      await firestore.collection('services').add({
        'isContract': isContract,
        'serviceName': serviceName.trim(),
        'price': priceAsDouble,
        'addedAt': DateTime.now()
      });
      print('Data added to Firestore successfully.');
      fetchServices();
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Date adăugate cu succes.");

      isLoading = false;
      this.newServiseMode = false;
      isContract = false;
      setState(() {});
    } catch (e) {
      print('Error adding data to Firestore: $e');
      MyDialog.showAlert(context, "Ok", 'Error adding data to Firestore: $e');
      isLoading = false;
      this.newServiseMode = false;
      isContract = false;
      setState(() {});
    }
  }

  // this function will fetch the services from the firebase
  Future<void> fetchServices() async {
    try {
      this.price = "";
      this.isLoading = true;
      setState(() {});
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
          .collection('services')
          .orderBy('addedAt', descending: true)
          .get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      List<Map<String, dynamic>> services = docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
      this.servicesFromFirebase = services;
      // print(services.first);
      setState(() {});
    } catch (e) {
      print('Error fetching services: $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching services: $e');
    } finally {
      this.isLoading = false;
      setState(() {});
    }
  }

  // This funciton gonna delete the serices by ID
  Future<void> deleteServiceByDocId(
      {required String docId, required BuildContext context}) async {
    try {
      confirmationDialog.showElegantPopupWait(
          context: context,
          message: "Esti sigur că vrei să ștergi acest serviciu?",
          onYes: () async {
            // check id doc exsist
            final DocumentReference docRef =
                FirebaseFirestore.instance.collection('services').doc(docId);
            DocumentSnapshot docSnapshot = await docRef.get();
            if (!docSnapshot.exists) {
              staticVar.showSubscriptionSnackbar(
                  context: context,
                  msg: "Eroare: Acest serviciu nu mai există. ",
                  color: Colors.red);
              return;
            }

            await FirebaseFirestore.instance
                .collection('services')
                .doc(docId)
                .delete();
            print('Document with ID $docId deleted successfully');
            // refresh the table
            fetchServices();
            staticVar.showSubscriptionSnackbar(
                context: context, msg: "Șters cu succes");
          },
          onNo: () {});
    } catch (e) {
      print('Error deleting document: $e');
      MyDialog.showAlert(context, "Ok", 'Error deleting document: $e');
    }
  }

// This function will handel the edit fucntionalty
  Future<void> updateRecord() async {
    try {
      this.isLoading = true ;
      setState(() {});
      // Get reference to the Firestore collection
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('services');
      double priceAsDouble = double.tryParse(this.editDataMode["price"].toString() ?? "0.0") ?? 0.0 ;
      if(priceAsDouble == 0){
        MyDialog.showAlert(context, "Ok", "error while parsing the double");
        return;
      }
      // Update the document with the specified docId
      await collectionRef.doc(this.editDataMode["docId"]).update({
        'serviceName' :this.editDataMode["serviceName"],
        'price' :  priceAsDouble   ,
        'isContract' :this.editDataMode["isContract"],
        'lastEdit' : DateTime.now()
      });
      fetchServices();
      print('Record updated successfully!');
      staticVar.showSubscriptionSnackbar(context: context, msg: "Înregistrarea a fost actualizată cu succes!") ;

      this.isLoading = false;
      this.editMode = false ;
      setState(() {});

    } catch (error) {
      print('Error updating record: $error');
      MyDialog.showAlert(context, "Ok", 'Error updating record: $error') ;
      // Handle error here
    }
  }
}

class StatusLabel extends StatelessWidget {
  final String text;
  final Color color;

  StatusLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
