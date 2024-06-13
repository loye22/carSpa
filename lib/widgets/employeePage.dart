import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/confirmationDialog.dart';
import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class employeePage extends StatefulWidget {
  const employeePage({super.key});

  @override
  State<employeePage> createState() => _employeePageState();
}

class _employeePageState extends State<employeePage> {
  bool addNewEmpMode = false;
  bool isLoading = false;
  bool editMode = false;

  String employeeName = "";
  String percentage = "";
  String phoneNr = "" ;

  List<Map<String, dynamic>> emplyeeDataFromFirebase = [];

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
            :(addNewEmpMode
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
                this.addNewEmpMode = false;
                setState(() {});
              },
              text: "Back",
              color: Colors.red,
            ),
          ],
        ))
            : Tooltip(
          message: "Adăugați un nou angajat",
          child: FloatingActionButton(
            onPressed: () {
              this.addNewEmpMode = true;
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
                  initialValue: editDataMode["empName"] ?? "404NotFound",
                  isItNumerical: false,
                  label: 'Numele angajatului',
                  hintText: 'Vă rugăm să introduceți numele angajatului',
                  onChanged: (servise) {
                    editDataMode["empName"]  = servise;
                  },
                ),
                SizedBox(height: 16.0),
                customTextFieldWidget(
                  suffex: "%",
                  editMode: true,
                  initialValue:editDataMode["empPercentage"].toString() ?? "404NotFound" ,
                  label: 'Preț Serviciu',
                  hintText: '0 785 458 684',
                  isItNumerical: true,
                  onChanged: (data) {
                    editDataMode["empPercentage"]  = data;
                  },
                ),
                SizedBox(height: 16.0),
                customTextFieldWidget(
                  editMode: true,
                  initialValue:editDataMode["phoneNr"].toString() ?? "404NotFound" ,
                  isItphoneNr:  true ,
                  label: 'Număr de telefon',
                  hintText: '0 777 888 999',
                  isItNumerical: true,
                  onChanged: (Nr) {
                    editDataMode["phoneNr"]  = Nr;
                  },
                )
                            ],
            ),
          ),
        )
            :
        // this part gonna handel the display data and add new servises
        (addNewEmpMode
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
                  label: 'Numele angajatului',
                  hintText: 'Vă rugăm să introduceți numele angajatului',
                  onChanged: (data) {
                    this.employeeName = data;
                  },
                ),
                SizedBox(height: 16.0),
                customTextFieldWidget(
                  suffex: "%",
                  label: 'Preț Serviciu',
                  hintText: 'Introduceți prețul serviciului',
                  isItNumerical: true,
                  onChanged: (price2) {
                    this.percentage = price2;
                  },
                ),

                customTextFieldWidget(

                  isItphoneNr:  true ,
                  label: 'Număr de telefon',
                  hintText: '0 785 458 684',
                  isItNumerical: true,
                  onChanged: (Nr) {
                    this.phoneNr = Nr ;
                  },
                ),
                SizedBox(height: 16.0),

              ],
            ),
          ),
        )
        // display the data as table
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
                          staticVar.Dc("nume angajat"),
                          staticVar.Dc("comisionat"),
                          staticVar.Dc("adăugat la"),
                          staticVar.Dc("telefon"),
                          staticVar.Dc("opțiuni"),



                        ],
                        rows: this.emplyeeDataFromFirebase.map((e) {
                          String nameMap =
                              e["empName"] ?? "NotFound404";
                          String commissioned =
                              e["empPercentage"]?.toString() ?? "NotFound404";

                          dynamic date =
                              e["addedAt"] ?? "NotFound404";
                          String phoneNr = e["phoneNr"] ?? "NotFound404";

                          return DataRow(onLongPress: () {}, cells: [
                            DataCell(Center(child: Text(nameMap))),
                            DataCell(Center(child: Text(commissioned))),
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
                                child: Text(
                                  phoneNr
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
                                        await deleteEmployeeByDocId(
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

  // this function will insert new employee  to the Database
  void sendToFirestore() async {
    try {
      isLoading = true;
      setState(() {});
      int percent = int.tryParse(this.percentage) ?? 0;
      if (percent > 100 || percent < 1){
        MyDialog.showAlert(context, "Da", "Vă rugăm să introduceți comisionul procentual între 1 și 100");
        this.isLoading = false ;
        setState(() {});
        return ;
      }
      // Accessing the Firestore instance
      if (this.employeeName.trim() == "" ||
          this.percentage.trim() == "" || this.phoneNr == "" ) {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați toate câmpurile din formular, inclusiv numele angajatului și procentul de comision. Vă mulțumim pentru colaborare!");
        print("please enter all the data ");

        isLoading = false;
        setState(() {});
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Adding data to Firestore
      await firestore.collection('employee').add({

        'empName': employeeName.trim(),
        'empPercentage': percentage.trim(),
        'addedAt': DateTime.now() ,
        'phoneNr' : this.phoneNr
      });
      print('Data added to Firestore successfully.');
      fetchServices();
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Date adăugate cu succes.");

      isLoading = false;
      this.addNewEmpMode = false;

      setState(() {});
    } catch (e) {
      print('Error adding data to Firestore: $e');
      MyDialog.showAlert(context, "Ok", 'Error adding data to Firestore: $e');
      isLoading = false;
      this.addNewEmpMode = false;
      setState(() {});
    }
  }

  // this function will fetch the services from the firebase
  Future<void> fetchServices() async {
    try {
      this.percentage = "";
      this.employeeName = "";
      this.phoneNr = "";


      this.isLoading = true;
      setState(() {});
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
          .collection('employee')
          .orderBy('addedAt', descending: true)
          .get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      List<Map<String, dynamic>> employee = docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
      this.emplyeeDataFromFirebase = employee;
      // print(services.first);
      setState(() {});
    } catch (e) {
      print('Error fetching emplyee: $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching employee : $e');
    } finally {
      this.isLoading = false;
      setState(() {});
    }
  }

  // This funciton gonna delete the serices by ID
  Future<void> deleteEmployeeByDocId(
      {required String docId, required BuildContext context}) async {
    try {
      confirmationDialog.showElegantPopupWait(
          context: context,
          message: "Sunteți sigur că doriți să ștergeți acest angajat?",
          onYes: () async {
            // check id doc exsist
            final DocumentReference docRef =
            FirebaseFirestore.instance.collection('employee').doc(docId);
            DocumentSnapshot docSnapshot = await docRef.get();
            if (!docSnapshot.exists) {
              staticVar.showSubscriptionSnackbar(
                  context: context,
                  msg: "Eroare: Acest angajat nu mai există.",
                  color: Colors.red);
              return;
            }

            await FirebaseFirestore.instance
                .collection('employee')
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
      if (this.editDataMode["empName"].trim() == "" ||
          this.editDataMode["empPercentage"].toString().trim() == "" ||
          this.editDataMode["phoneNr"].toString().trim() == ""   ) {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați toate câmpurile din formular, inclusiv numele angajatului și procentul de comision. Vă mulțumim pentru colaborare!");
        print("please enter all the data ");

        isLoading = false;
        setState(() {});
        return;
      }

      this.isLoading = true ;
      setState(() {});
      // Get reference to the Firestore collection
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('employee');
      double emplyeePercentage = double.tryParse(this.editDataMode["empPercentage"].toString() ?? "0.0") ?? 0.0 ;
      if(emplyeePercentage == 0){
        MyDialog.showAlert(context, "Ok", "error while parsing the double");
        return;
      }
      // Update the document with the specified docId
      await collectionRef.doc(this.editDataMode["docId"]).update({
        'empName' :this.editDataMode["empName"].toString().trim(),
        'empPercentage' :  emplyeePercentage ,
        'lastEdit' : DateTime.now() ,
        'phoneNr' : this.editDataMode["phoneNr"].toString().trim()
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
