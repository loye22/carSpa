import 'package:flutter/cupertino.dart';
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

class contractorPage extends StatefulWidget {
  const contractorPage({super.key});

  @override
  State<contractorPage> createState() => _contractorPageState();
}

class _contractorPageState extends State<contractorPage> {
  bool newB2B = false;
  bool isLoading = false;
  bool editMode = false;

  String B2BName = "";

  List<Map<String, dynamic>> B2BDataFromFirebase = [];

  Map<String,dynamic> editDataMode = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchB2BData();
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
            :(newB2B
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
                this.newB2B = false;
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
              this.newB2B = true;
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
                  initialValue: editDataMode["B2BName"] ?? "404NotFound",
                  isItNumerical: false,
                  label: "Numele contractorului",
                  hintText: "Vă rugăm să introduceți numele contractorului.",
                  onChanged: (name) {
                    editDataMode["B2BName"]  = name;
                  },
                ),

              ],
            ),
          ),
        )
            :
        // this part gonna handel the display data and add new servises
        (newB2B
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
                  label: "Numele contractorului",
                  hintText: "Vă rugăm să introduceți numele contractorului.",
                  onChanged: (data) {
                    this.B2BName = data;
                  },
                ),


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
                          staticVar.Dc("nume contractor"),
                          staticVar.Dc("adaugat la"),
                          staticVar.Dc("optiune")


                        ],
                        rows: this.B2BDataFromFirebase.map((e) {
                          String nameMap = e["B2BName"] ?? "NotFound404";
                          dynamic date =  e["addedAt"] ?? "NotFound404";

                          return DataRow(onLongPress: () {}, cells: [
                            DataCell(Center(child: Text(nameMap))),
                            DataCell(
                              Center(
                                child: Text(
                                  staticVar.formatDateFromTimestamp(date),
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

  // this function will insert new B2B  to the Database
  void sendToFirestore() async {
    try {
      isLoading = true;
      setState(() {});
      // Accessing the Firestore instance
      if (this.B2BName.trim() == "" ) {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați numele contractorului și să încercați din nou. Vă mulțumim pentru colaborare!");
        print("please enter all the data ");
        isLoading = false;
        setState(() {});
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Adding data to Firestore
      await firestore.collection('b2b').add({

        'B2BName': B2BName.trim(),
        'addedAt': DateTime.now()
      });
      print('Data added to Firestore successfully.');
      fetchB2BData();
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Date adăugate cu succes.");

      isLoading = false;
      this.newB2B = false;
      setState(() {});
    } catch (e) {
      print('Error adding data to Firestore: $e');
      MyDialog.showAlert(context, "Ok", 'Error adding data to Firestore: $e');
      isLoading = false;
      this.newB2B = false;
      setState(() {});
    }
  }

  // this function will fetch the B2B data from the firebase
  Future<void> fetchB2BData() async {
    try {
      this.B2BName = "";
      this.isLoading = true;
      setState(() {});
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
          .collection('b2b')
          .orderBy('addedAt', descending: true)
          .get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      List<Map<String, dynamic>> employee = docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
      this.B2BDataFromFirebase = employee;
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

  // This funciton gonna delete the B2B by ID
  Future<void> deleteEmployeeByDocId(
      {required String docId, required BuildContext context}) async {
    try {
      confirmationDialog.showElegantPopupWait(
          context: context,
          message: "Sunteți sigur că doriți să ștergeți acest contractor?",
          onYes: () async {
            // check id doc exsist
            final DocumentReference docRef =
            FirebaseFirestore.instance.collection('b2b').doc(docId);
            DocumentSnapshot docSnapshot = await docRef.get();
            if (!docSnapshot.exists) {
              staticVar.showSubscriptionSnackbar(
                  context: context,
                  msg: "Eroare: Acest angajat nu mai există.",
                  color: Colors.red);
              return;
            }

            await FirebaseFirestore.instance
                .collection('b2b')
                .doc(docId)
                .delete();
            print('Document with ID $docId deleted successfully');
            // refresh the table
            fetchB2BData();
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
      if (this.editDataMode["B2BName"].trim() == "") {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați numele contractorului și să încercați din nou. Vă mulțumim pentru colaborare!");
        print("please enter all the data ");

        isLoading = false;
        setState(() {});
        return;
      }

      this.isLoading = true ;
      setState(() {});
      // Get reference to the Firestore collection
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('b2b');

      // Update the document with the specified docId
      await collectionRef.doc(this.editDataMode["docId"]).update({
        'B2BName' :this.editDataMode["B2BName"],
        'lastEdit' : DateTime.now()
      });
      fetchB2BData();
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


/*








  @override
  Widget build(BuildContext context) {
    return ;
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




 */