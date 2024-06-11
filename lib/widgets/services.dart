import 'package:car_spa/widgets/button.dart';
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

  String serviceName = "";
  String price = "";

  List<Map<String, dynamic>> servicesFromFirebase = [];

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
        floatingActionButton: newServiseMode
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
              ),
        body: newServiseMode
            ? Animate(
                effects: [FadeEffect(duration: Duration(milliseconds: 900))],
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
            : Center(
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
                              staticVar.Dc("Contractat"),
                              staticVar.Dc("Added at")
                            ],
                            rows: this.servicesFromFirebase.map((e) {
                              String nameMap =
                                  e["serviceName"] ?? "NotFound404";
                              String priceMap =
                                  e["price"]?.toString() ?? "NotFound404";
                              bool isContractMap = e["isContract"] ?? false;
                              dynamic date = e["addedAt"] ?? "NotFound404";

                              return DataRow(onLongPress: () {}, cells: [
                                DataCell(Center(child: Text(nameMap))),
                                DataCell(Center(child: Text(priceMap))),
                                DataCell(
                                  Center(
                                      child: isContractMap
                                          ? StatusLabel(
                                              color: Colors.green,
                                              text: "contractor",
                                            )
                                          : Text("*****")),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      staticVar.formatDateFromTimestamp(date),
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ))),
              ),
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
      this.isLoading = true;
      setState(() {});
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
          .collection('services')
          .orderBy('addedAt', descending: true)
          .get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      List<Map<String, dynamic>> services =
          docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      this.servicesFromFirebase = services;
      // print(servicesFromFirebase);
      setState(() {});
    } catch (e) {
      print('Error fetching services: $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching services: $e');
    } finally {
      this.isLoading = false;
      setState(() {});
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
