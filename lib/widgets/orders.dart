import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/dummy_data.dart';
import 'package:car_spa/widgets/enum.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class orders extends StatefulWidget {
  const orders({super.key});

  @override
  State<orders> createState() => _ordersState();
}

class _ordersState extends State<orders> {
  String clientName = '';
  String clientEmail = '';
  String clientPhone = '';
  String carModel = '';
  DateTime issuedDate = DateTime.now();
  DateTime? entranceDate = null;

  DateTime appointmentDate = DateTime.now();
  DateTime? finishedDate = null;
  orderStatus status = orderStatus.init;
  PaymentStatus paymentStatus = PaymentStatus.init;
  PaymentMethod paymentMethod = PaymentMethod.init;
  String cui = '';

  List<Map<String, dynamic>> servicesfromFirebase = [];
  List<Map<String, dynamic>> selectedServices = [];


  List<Map<String, dynamic>> employeefromFirebase = [];




  double advancedPayment = 0.0;
  int discount = 0;

  String createdBy = '';
  String servicesPounce = '';
  String imageBefore = '';
  String imageAfter = '';
  bool lock = false;
  String empId = "";
  String empName = '';

  DateTime? empAcceptanceTimestamp = null;

  DateTime? completionTimestamp = null;

  String billUrl = '';
  String dealerName = '';
  String dealerID = '';
  bool dealerMode = false;

  ////////So here the ends for the vars that we gonna send to data base //////////////////

  bool addNewOrderMode = false;
  bool isLoading = false;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchServices();
    fetchEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Tooltip(
          message: "adauga ordine",
          child: FloatingActionButton(
            backgroundColor: Color(0xFF1ABC9C),
            onPressed: () {
              print(this.selectedServices);
              print(this.empName);
              print(this.empId);
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )),
      body:this.isLoading ? staticVar.loading() : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Nume Client *',
                        // Text pentru eticheta
                        hintText: 'Introduceți numele clientului',
                        // Text pentru sugestie
                        onChanged: (value) {
                          setState(
                            () {
                              clientName = value;
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Email Client',
                        hintText: 'client@example.com',
                        onChanged: (value) {
                          setState(() {
                            clientEmail = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Client Phone *',
                        hintText: '0 777 888 999',
                        onChanged: (value) {
                          setState(() {
                            clientPhone = value;
                          });
                        },
                        isItphoneNr: true, // Assuming phone number input
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Model mașină *',
                        // Etichetă pentru modelul mașinii
                        hintText: 'Introduceți modelul mașinii',
                        // Sugestie pentru utilizato
                        onChanged: (value) {
                          setState(() {
                            carModel = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Plată avansată *',
                        // Advanced Payment
                        hintText: 'Introduceți plata avansată în lei',
                        // Enter Advanced Payment In Lei
                        onChanged: (value) {
                          setState(() {
                            advancedPayment = double.tryParse(value) ?? 0.0;
                          });
                        },
                        isItNumerical: true,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Discount',
                        hintText: 'Enter Discount',
                        suffex: "%",
                        onChanged: (value) {
                          setState(() {
                            discount = int.tryParse(value) ?? 0;
                          });
                        },
                        isItNumerical: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'CUI',
                        hintText: 'Enter CUI',
                        onChanged: (value) {
                          setState(() {
                            cui = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: customTextFieldWidget(
                        label: 'Servicii oferite',
                        // Services Offered
                        hintText: 'Introduceți serviciile oferite',
                        // Enter Services Offered
                        onChanged: (value) {
                          setState(() {
                            servicesPounce = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // the payment method dropdown menu
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,

                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          label: Text("metoda de plată"),
                          // Add Horizontal padding using menuItemStyleData.padding so it matches
                          // the menu padding when button's width is not specified.
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          // Add more decoration..
                        ),
                        hint: const Text(
                          'Selectați metoda de plată pentru acest client.',
                          style: TextStyle(fontSize: 14),
                        ),
                        items: PaymentMethod.values.getRange(0, PaymentMethod.values.length - 1)
                            .map((item) =>
                            DropdownMenuItem<String>(
                                  value: item.toString(),
                                  child: Text(
                                    item.toString().split(".").last,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),

                        onChanged: (value) {
                          this.paymentMethod = parsePaymentMethodFromString(value ?? "") ;
                          // print(this.paymentMethod);
                          // print(this.paymentMethod.runtimeType);
                          //Do something when selected item is changed.
                        },

                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * .13),
                    Container( width: MediaQuery.of(context).size.width * 0.3,

                      child:
                      MultiSelectDropDown(
                        showChipInSingleSelectMode: true,
                        //   controller: _controller,
                        onOptionSelected: (options) {
                          this.selectedServices= options.map((e){return e.value as Map<String,dynamic>;}).toList()  ;
                          //debugPrint(options.first.value.toString());
                        },
                        options: this.servicesfromFirebase.map<ValueItem>((e) {
                          //{price: 700,
                          // addedAt: ,
                          // serviceName: Detailing the exterior - medie,
                          // isContract: true,
                          // docId: 4Kg6bRfbfnLCm21CQlRw}

                          String label = e["isContract"] ? e["serviceName"] + "--" + "B2B" : e["serviceName"] ;
                          return  ValueItem(label: label, value: e);
                        }).toList()
                        ,
                        maxItems: 5,
                        selectionType: SelectionType.multi,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap,backgroundColor: Color(0xFF1ABC9C) ),
                        dropdownHeight: 300,
                        optionTextStyle: const TextStyle(fontSize: 16),
                        selectedOptionIcon: const Icon(Icons.check_circle, color: Color(0xFF1ABC9C),),



                      ),
                    ),

                  ],
                ),
                    SizedBox(height: 25.0),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          //  height: 100,
                          child: DropdownButtonFormField2<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              label: Text("Angajatul"),
                              // Add Horizontal padding using menuItemStyleData.padding so it matches
                              // the menu padding when button's width is not specified.
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              // Add more decoration..
                            ),
                            hint: const Text(
                              "Vă rugăm să selectați angajatul care va fi responsabil pentru această comandă.",
                              style: TextStyle(fontSize: 14),
                            ),
                            items: this.employeefromFirebase
                                .map((item) =>
                                DropdownMenuItem<String>(
                                  value: item["docId"],
                                  child: Text(
                                    item["empName"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                                .toList(),

                            onChanged: (value) {
                              if(value ==null){
                                MyDialog.showAlert(context, "Ok", "Error when we try to get the employee ID while the user selecting the emp");
                                throw Exception("Error when we try to get the employee ID while the user selecting the emp");
                              }
                              this.empId = value;
                              this.empName =  this.employeefromFirebase.where((element) => element["docId"] == value).first["empName"];


                            },

                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.only(right: 8),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 24,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),

                      ],
                    ),


              ])),
        ),
      ),
    );
  }



  Future<void> _selectAppointmentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: appointmentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != appointmentDate) {
      setState(() {
        appointmentDate = picked;
      });
    }
  }


  // this fucniotn gonna parse the selected string item back to Emum
  PaymentMethod parsePaymentMethodFromString(String value) {
    // Split the string to get the enum member name
    String enumMember = value.split('.')[1]; // This assumes 'PaymentMethod.pos' format

    // Find the corresponding enum value
    return PaymentMethod.values.firstWhere(
          (e) => e.toString().split('.').last == enumMember,
      orElse: () => PaymentMethod.init,
    );
  }

  // this funciotn gonna fetch the servise data
  Future<void> fetchServices() async {
    this.isLoading = true ;
    setState(() {});
    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define a list to store the fetched data
    List<Map<String, dynamic>> servicesList = [];

    try {
      // Get all documents from the 'services' collection
      QuerySnapshot querySnapshot = await firestore.collection('services').get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add document ID to the data map
        data['docId'] = doc.id;

        // Add data map to the list
        servicesList.add(data);
      });

      this.servicesfromFirebase = servicesList ;
      // print(this.services);

    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching services: $e');
      MyDialog.showAlert(context,"Ok", 'Error fetching services: $e') ;

    }
  }

  // this funciotn gonna fetch the employee data
  Future<void> fetchEmployee() async {

    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define a list to store the fetched data
    List<Map<String, dynamic>> employeeList = [];

    try {
      // Get all documents from the 'services' collection
      QuerySnapshot querySnapshot = await firestore.collection('employee').get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add document ID to the data map
        data['docId'] = doc.id;

        // Add data map to the list
        employeeList.add(data);
      });

      this.employeefromFirebase = employeeList ;
      // print(this.services);
      this.isLoading = false;
      setState(() {});
      //print(this.employeefromFirebase);
    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching : $e');
      MyDialog.showAlert(context,"Ok", 'Error fetching employee: $e') ;

    }
  }

}
