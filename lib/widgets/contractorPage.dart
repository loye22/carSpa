import 'package:car_spa/widgets/EmployeeNameCard.dart';
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
  bool showAllContractorCarsMode = false ;

  String B2BName = "";
  String email = "";
  String phoneNr = "";
  String cui = "" ;

  List<Map<String, dynamic>> B2BDataFromFirebase = [];
  List<Map<String, dynamic>>  ordersfromFirebase = [] ;

  Map<String,dynamic> editDataMode = {};
  Map<String,dynamic> dealerDetails = {};


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ordersFromFirrbase();
    fetchB2BData();
  }

  @override
  Widget build(BuildContext context) {
    return
    this.showAllContractorCarsMode ?
    Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 900))],
        child: Scaffold(
          floatingActionButton:   Tooltip(
            message: 'Reveniți la ecranul de start',
            child: Animate(
              effects: [SlideEffect(begin: Offset(5, 0))],
              child: FloatingActionButton(
                backgroundColor: Color(0xFF1ABC9C),
                onPressed: goBackToHomeScreen,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          body:Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  cardName(name:this.dealerDetails["B2BName"] ?? "404NotFound"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: staticVar.golobalWidth(context) ,
                    height: staticVar.golobalHigth(context) * .9,
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
                              staticVar.Dc("Modelul mașinii"),
                              staticVar.Dc("Data programării"),
                              staticVar.Dc("payment status"),
                              staticVar.Dc("Preț total cu TVA"),
                              staticVar.Dc("Servicii"),



                            ],
                            rows: this.ordersfromFirebase.where((ele) => ele["dealerID"] == this.dealerDetails["docId"] ).toList()
                                .map((e) {
                              String carModelMap = e["carModel"] ?? "404NotFound" ;
                              String appointmentDateMap =staticVar.formatDateFromTimestampWithTime(e["appointmentDate"] ?? "") ?? "404NotFound" ;
                              String paymentStatusMap = e["paymentStatus"];
                              String totalPriceWIthTVA = e["priceSummryDetails"]?["totalWithVat"] ?? "404NotFound";
                              String servisesMap =e["selectedServices"]?.map((e)=> e["serviceName"] ?? "404Notfound")?.toList()?.toString() ?? "404NotFound";


                              return DataRow2(
                                  onTap: (){
                                    print(e);
                                    MyDialog.showOrderDetailsPopup(context: context, orderData: e );

                                  },
                                  cells: [

                                    DataCell(Center(child: Text(carModelMap))),
                                    DataCell(Center(child: Text(appointmentDateMap))),
                                    DataCell(Center(child:   staticVar.getPaymentStatusWidget(status2: paymentStatusMap ?? ""))),
                                    DataCell(Center(child: Text(totalPriceWIthTVA + " Lie" ))),
                                    DataCell(Center(child: Text(servisesMap))),

                                  ]);
                            }).toList(),
                          ),
                        ))),
              ),
            ],
          ),
        )

    )




    /// This is the init page
      :(this.isLoading ? staticVar.loading() : Animate(
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
                fetchB2BData();
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
                customTextFieldWidget(
                  editMode: true,
                  initialValue: editDataMode["email"] ?? "404NotFound",
                  isItNumerical: false,
                  label: "Email contractorului",
                  hintText: "Vă rugăm să introduceți Email contractorului.",
                  onChanged: (name) {
                    editDataMode["email"]  = name;
                  },
                ),

                customTextFieldWidget(
                  editMode: true,
                  initialValue: editDataMode["phoneNr"] ?? "404NotFound",
                  isItNumerical: true,
                  isItphoneNr: true,
                  label: "Telephone contractorului",
                  hintText: "Vă rugăm să introduceți Telephone contractorului.",
                  onChanged: (name) {
                    editDataMode["phoneNr"]  = name;
                  },
                ),

                customTextFieldWidget(
                  editMode: true,
                  initialValue: editDataMode["cui"] ?? "404NotFound",
                  limit: 10,
                  label: "CUI",
                  hintText: "RO13655452",
                  onChanged: (data) {
                    editDataMode["cui"]  = data;
                  },
                )

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
                // new b2b  name
                customTextFieldWidget(
                  isItNumerical: false,
                  label: "Numele contractorului",
                  hintText: "Vă rugăm să introduceți numele contractorului.",
                  onChanged: (data) {
                    this.B2BName = data;
                  },
                ),
                // the email for new b2b daler
                customTextFieldWidget(
                  isItNumerical: false,
                  label: "Email contractor",
                  hintText: "example@email.com",
                  onChanged: (data) {
                    this.email = data;
                  },
                ),
                // contractor phone nr
                customTextFieldWidget(
                  isItphoneNr: true ,
                  isItNumerical: true,
                  label: "Telefon contractor",
                  hintText: "0 777 888 999",
                  onChanged: (data) {
                    this.phoneNr = data;
                  },
                ),

                customTextFieldWidget(
                  limit: 10,
                  label: "CUI",
                  hintText: "RO13655452",
                  onChanged: (data) {
                    this.cui = data;
                  },
                ),


              ],
            ),
          ),
        )

        /// This is the init page
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
                          staticVar.Dc("CUI"),
                          staticVar.Dc("adaugat la"),
                          staticVar.Dc("email"),
                          staticVar.Dc("Telefone"),
                          staticVar.Dc("optiune")


                        ],
                        rows: this.B2BDataFromFirebase.map((e) {
                          String nameMap = e["B2BName"] ?? "NotFound404";
                          dynamic date =  e["addedAt"] ?? "NotFound404";
                          String emailMap = e["email"] ?? "NotFound404";
                          String phoneNrMap = e["phoneNr"] ?? "NotFound404" ;
                          String cuiMap = e["cui"] ?? "NotFound404" ;


                          return DataRow2(
                              onTap: (){
                                print(e);
                                this.showAllContractorCarsMode = true ;
                                this.dealerDetails = e ;
                                setState(() {});
                              },
                              onLongPress: () {}, cells: [
                            DataCell(Center(child: Text(nameMap))),
                            DataCell(
                              Center(
                                child: Text(
                                    cuiMap
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  staticVar.formatDateFromTimestamp(date),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  emailMap,
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                    phoneNrMap
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
    )) ;
  }


  // this function gonna fetch all the dealer orders
  Future<void> ordersFromFirrbase() async {
    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define a list to store the fetched data
    List<Map<String, dynamic>> ordersList = [];

    try {
      // Get all documents from the 'services' collection
      QuerySnapshot querySnapshot = await firestore
          .collection('orders')
          .orderBy('issuedDate', descending: true)
          .get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add document ID to the data map
        data['docId'] = doc.id;

        // Add data map to the list if the orders is on dealer mode
        if(data["dealerMode"])
        ordersList.add(data);
      });

      this.ordersfromFirebase = ordersList;
      // print(this.ordersfromFirebase);
      this.isLoading = false;
      setState(() {});
      //print(this.employeefromFirebase);
    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching : $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching orders: $e');
    }
  }

  /// This function will go back to inil page from the show b2b cars mode
  void goBackToHomeScreen() {
    this.showAllContractorCarsMode = false ;
    setState(() {});
  }

  // this function will insert new B2B  to the Database
  void sendToFirestore() async {
    try {
      isLoading = true;
      setState(() {});
      // Accessing the Firestore instance
      if (this.B2BName.trim() == "" || this.phoneNr.trim().length !=10 || this.email.trim() == ""  || this.cui.trim().length != 10 ) {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați numele, cui, adresa de email și numărul de telefon al contractorului și să încercați din nou. Vă mulțumim pentru colaborare!");
        print("please enter all the data ");
        isLoading = false;
        setState(() {});
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Adding data to Firestore
      await firestore.collection('b2b').add({

        'B2BName': B2BName.trim(),
        'addedAt': DateTime.now(),
        'phoneNr' : phoneNr.trim() ,
        'email' : email.trim(),
        'cui' : this.cui.trim()

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
      this.email = "" ;
      this.phoneNr = "" ;
      this.isLoading = true;
      this.cui = "" ;
     // this.editDataMode = {}  ;
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
      if (this.editDataMode["B2BName"].trim() == "" || this.editDataMode["phoneNr"].trim().length !=10 || this.editDataMode["email"].trim() == ""|| this.editDataMode["cui"].toString().trim().length!= 10 ) {
        MyDialog.showAlert(context, "Da",
            "Vă rugăm să completați numele, adresa de email și numărul de telefon al contractorului și să încercați din nou. Vă mulțumim pentru colaborare!");
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
        'lastEdit' : DateTime.now(),
        'phoneNr' : this.editDataMode["phoneNr"] ,
        'email' :this.editDataMode["email"] ,
        'cui' : this.editDataMode["cui"] ,

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