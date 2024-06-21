import 'dart:async';
import 'package:car_spa/widgets/CustomDateTimePicker.dart';
import 'package:car_spa/widgets/PriceSummaryCard.dart';
import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dateCalnderPickUp.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/enum.dart';
import 'package:car_spa/widgets/filterFeedBackWidget.dart';
import 'package:car_spa/widgets/orderDetails.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'dart:convert' as json;

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
  String filteredEmp = '';

  // DateTime issuedDate = DateTime.now();
  DateTime? entranceDate = null;

  DateTime appointmentDate = DateTime.now().add(Duration(days: 1));
  DateTime? finishedDate = null;
  orderStatus status = orderStatus.pending;
  PaymentStatus paymentStatus = PaymentStatus.init;
  PaymentMethod paymentMethod = PaymentMethod.init;
  String cui = '';

  List<Map<String, dynamic>> servicesfromFirebase = [];
  List<Map<String, dynamic>> selectedServices = [];
  List<Map<String, dynamic>> ordersfromFirebase = [];
  List<Map<String, dynamic>> filterdOrders = [];

  List<Map<String, dynamic>> employeefromFirebase = [];
  List<Map<String, dynamic>> b2bfromFirebase = [];

  Map<String, dynamic> priceSummryDetails = {};
  Map<String, dynamic> orderDataToDisplay = {};

  double advancedPayment = 0.0;
  int discount = 0;

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

  /// when this mode is ON only the assiened employee will be able to accept the order
  bool specifecEmployeeMode = false;

  ////////So here the ends for the vars that we gonna send to data base //////////////////

  bool addNewOrderMode = false;
  bool isLoading = false;
  bool showOrderDetailsMode = false;
  bool filterMode = false;

  DateTime? startDateRangeFilter = null;

  DateTime? endDateRangeFilter = null;

  bool dateFilterMode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchServices();
    ordersFromFirrbase();
    fetchB2BData();
    fetchEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: this.isLoading
            ? SizedBox.shrink()

            /// this is the payment,cancel, return buttons in the order details screen
            : (this.showOrderDetailsMode
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if((this.orderDataToDisplay["paymentStatus"] ?? false )== PaymentStatus.paid.toString()
                          &&
                          (this.orderDataToDisplay["status"]  ?? false )!= orderStatus.canceled.toString()
                          &&
                          (this.orderDataToDisplay["status"]  ?? false )!= orderStatus.completed.toString()

                      )
                        /// This button gonna update the order status to completed
                        /// this button will be shown only if the order is apied fully and the order is not on cancel state
                      Tooltip(
                        message: 'Acest buton este pentru a completa comanda',
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFF1ABC9C),
                          onPressed: _completeOrder,
                          child: Icon(Icons.assignment_turned_in ,color: Colors.white,),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Tooltip(
                        message: 'Plătește comanda',
                        child: FloatingActionButton(
                          backgroundColor: Colors.green,
                          onPressed: upadtePaymentStatus,
                          child: Icon(
                            Icons.payment,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Tooltip(
                        message: 'Anulează comanda',
                        child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          onPressed: cancelOrder,
                          child: Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Tooltip(
                        message: 'Reveniți la ecranul de start',
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue,
                          onPressed: goBackToHomeScreen,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : (this.addNewOrderMode

                    /// this is the upload the order , back buttons in the adding screen
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: 'trimite',
                            child: FloatingActionButton(
                              backgroundColor: Color(0xFF1ABC9C),
                              onPressed: addNewOrder,
                              child: Icon(
                                Icons.upload,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Tooltip(
                            message: 'anula',
                            child: FloatingActionButton(
                              backgroundColor: Colors.red,
                              onPressed: () {
                                this.addNewOrderMode = false;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.cancel_outlined,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )

                    /// this is the add button in the inil screen
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (this.filterMode || this.dateFilterMode)
                            Animate(
                              effects: [SlideEffect(begin: Offset(5, 0))],
                              child: Tooltip(
                                message: 'Restabiliți filtrele',
                                child: FloatingActionButton(
                                  backgroundColor: Colors.grey,
                                  onPressed: () {
                                    this.filterMode = false;
                                    this.dateFilterMode = false;
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                          FloatingActionButton(
                            backgroundColor: Color(0xFF1ABC9C),
                            onPressed: () async {
                              this.addNewOrderMode = true;
                              setState(() {});
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ))),
        body: this.isLoading
            ? staticVar.loading()
            :

            // after loading show the orders
            (this.addNewOrderMode
                ?
                // this part will handel adding new orders to the database
                Animate(
                    effects: [
                      FadeEffect(duration: Duration(milliseconds: 900))
                    ],
                    child: (this.isLoading
                        ? staticVar.loading()
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Detalii noi ale comenzii",
                                          style: TextStyle(
                                            fontSize: 36.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1ABC9C),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Mod dealer',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            Switch(
                                              value: this.dealerMode,
                                              onChanged: (bool value) {
                                                this.dealerID = "";
                                                this.dealerName = "";
                                                this.clientName = "";
                                                this.clientEmail = "";
                                                this.clientPhone = "";
                                                this.cui = "";

                                                setState(() {
                                                  this.dealerMode = value;
                                                });
                                              },
                                              activeColor: Color(
                                                  0xFF1ABC9C), // color when switch is on
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Pentru a crea o comandă B2B, porniți acest comutator.",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'modul angajat',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            Switch(
                                              value: this.specifecEmployeeMode,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  this.specifecEmployeeMode =
                                                      value;
                                                });
                                              },
                                              activeColor: Color(
                                                  0xFF1ABC9C), // color when switch is on
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Când vei activa acest comutator, doar angajatul pe care l-ai semnat va accepta comanda.",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 26,
                                    ),
                                    Row(
                                      children: [
                                        this.dealerMode
                                            ? Container(
                                                width: staticVar
                                                        .golobalWidth(context) *
                                                    .32,
                                                child: DropdownButtonFormField2<
                                                    String>(
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 16),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    // Add more decoration..
                                                  ),
                                                  hint: const Text(
                                                    "Vă rog să selectați clientul.",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  items: this
                                                      .b2bfromFirebase
                                                      .map((item) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: json
                                                                .jsonEncode(
                                                                    item)
                                                                .toString(),
                                                            child: Text(
                                                              item["B2BName"],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    Map<String, dynamic>
                                                        valueMap =
                                                        json.jsonDecode(
                                                            value ?? "");
                                                    this.dealerID =
                                                        valueMap["docId"];
                                                    this.dealerName =
                                                        valueMap["B2BName"];
                                                    this.clientName =
                                                        valueMap["B2BName"];
                                                    this.clientEmail =
                                                        valueMap["email"];
                                                    this.clientPhone =
                                                        valueMap["phoneNr"];
                                                    this.cui = valueMap['cui'];
                                                    setState(() {});
                                                  },
                                                  buttonStyleData:
                                                      const ButtonStyleData(
                                                    padding: EdgeInsets.only(
                                                        right: 8),
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black45,
                                                    ),
                                                    iconSize: 24,
                                                  ),
                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16),
                                                  ),
                                                ),
                                              )
                                            : Expanded(
                                                child: customTextFieldWidget(
                                                  label: 'Nume Client *',
                                                  // Text pentru eticheta
                                                  hintText:
                                                      'Introduceți numele clientului',
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
                                        SizedBox(
                                            width: this.dealerMode
                                                ? staticVar
                                                        .golobalWidth(context) *
                                                    .13
                                                : 16.0),
                                        Expanded(
                                          child: customTextFieldWidget(
                                            dealerMode: this.dealerMode,
                                            dealerData: this.clientEmail,
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
                                            isItNumerical: true,
                                            dealerMode: this.dealerMode,
                                            dealerData: this.clientPhone,
                                            label: 'Client Phone *',
                                            hintText: '0 777 888 999',
                                            onChanged: (value) {
                                              setState(() {
                                                clientPhone = value;
                                              });
                                            },
                                            isItphoneNr:
                                                true, // Assuming phone number input
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        Expanded(
                                          child: customTextFieldWidget(
                                            label: 'Model mașină *',
                                            // Etichetă pentru modelul mașinii
                                            hintText:
                                                'Introduceți modelul mașinii',
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
                                    Row(
                                      children: [
                                        this.dealerMode
                                            ? Expanded(
                                                child: customTextFieldWidget(
                                                  dealerMode: this.dealerMode,
                                                  dealerData: this.cui,
                                                  label: 'CUI',
                                                  hintText:
                                                      'client@example.com',
                                                  onChanged: (value) {},
                                                ),
                                              )
                                            : Expanded(
                                                child: customTextFieldWidget(
                                                  limit: 10,
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
                                            isItNumerical: true,
                                            isItDiscount: true,
                                            label: 'Discount',
                                            hintText: 'Enter Discount',
                                            suffex: "%",
                                            onChanged: (value) {
                                              setState(() {
                                                discount =
                                                    int.tryParse(value) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomDateTimePicker(
                                            label: "program pentru.",
                                            hintText: 'select the appotimeint ',
                                            onChanged: (d) {
                                              this.appointmentDate = d;
                                            }),
                                        SizedBox(
                                            width: staticVar
                                                    .golobalWidth(context) *
                                                .13),
                                        Expanded(
                                          child: customTextFieldWidget(
                                            label: 'Servicii oferite',
                                            // Services Offered
                                            hintText:
                                                'Introduceți serviciile oferite',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            // payment method
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              child: DropdownButtonFormField2<
                                                  String>(
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  label:
                                                      Text("metoda de plată"),
                                                  // Add Horizontal padding using menuItemStyleData.padding so it matches
                                                  // the menu padding when button's width is not specified.
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  // Add more decoration..
                                                ),
                                                hint: const Text(
                                                  'Selectați metoda de plată pentru acest client.',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                items: PaymentMethod.values
                                                    .getRange(
                                                        0,
                                                        PaymentMethod
                                                                .values.length -
                                                            1)
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value:
                                                              item.toString(),
                                                          child: Text(
                                                            item
                                                                .toString()
                                                                .split(".")
                                                                .last,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  this.paymentMethod =
                                                      parsePaymentMethodFromString(
                                                          value ?? "");
                                                  // print(this.paymentMethod);
                                                  // print(this.paymentMethod.runtimeType);
                                                  //Do something when selected item is changed.
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.black45,
                                                  ),
                                                  iconSize: 24,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                ),
                                              ),
                                            ),
                                            //employee selection
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              //  height: 100,
                                              child: DropdownButtonFormField2<
                                                  String>(
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  label: Text("Angajatul"),
                                                  // Add Horizontal padding using menuItemStyleData.padding so it matches
                                                  // the menu padding when button's width is not specified.
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  // Add more decoration..
                                                ),
                                                hint: const Text(
                                                  "Vă rugăm să selectați angajatul care va fi responsabil pentru această comandă.",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                items: this
                                                    .employeefromFirebase
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item["docId"],
                                                          child: Text(
                                                            item["empName"],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value == null) {
                                                    MyDialog.showAlert(
                                                        context,
                                                        "Ok",
                                                        "Error when we try to get the employee ID while the user selecting the emp");
                                                    throw Exception(
                                                        "Error when we try to get the employee ID while the user selecting the emp");
                                                  }
                                                  this.empId = value;
                                                  this.empName = this
                                                      .employeefromFirebase
                                                      .where((element) =>
                                                          element["docId"] ==
                                                          value)
                                                      .first["empName"];
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.black45,
                                                  ),
                                                  iconSize: 24,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                ),
                                              ),
                                            ),
                                            // payment status
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              //  height: 100,
                                              child: DropdownButtonFormField2<
                                                  String>(
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  label:
                                                      Text("statutul plății"),
                                                  // Add Horizontal padding using menuItemStyleData.padding so it matches
                                                  // the menu padding when button's width is not specified.
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  // Add more decoration..
                                                ),
                                                hint: const Text(
                                                  "vă rugăm să selectați statutul plății pentru această comandă",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                items: PaymentStatus.values
                                                    .getRange(
                                                        0,
                                                        PaymentStatus
                                                                .values.length -
                                                            1)
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value:
                                                              item.toString(),
                                                          child: Text(
                                                            item
                                                                .toString()
                                                                .split(".")
                                                                .last,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  this.paymentStatus =
                                                      parsePaymentStatusFromString(
                                                          value ?? "");
                                                  if (this.paymentStatus !=
                                                      PaymentStatus
                                                          .partiallyPaid)
                                                    this.advancedPayment = 0.0;
                                                  setState(() {});
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.black45,
                                                  ),
                                                  iconSize: 24,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                ),
                                              ),
                                            ),
                                            // this txt filed will handel the partially paid status
                                            SizedBox(
                                              height: 16,
                                            ),
                                            this.paymentStatus ==
                                                    PaymentStatus.partiallyPaid
                                                ? customTextFieldWidget(
                                                    limit: 4,
                                                    isItNumerical: true,
                                                    label: "plată în avans",
                                                    hintText: "... Ron",
                                                    onChanged: (value) {
                                                      double advancePayment =
                                                          double.tryParse(
                                                                  value) ??
                                                              0.0;
                                                      double totalPriceSummry =
                                                          double.tryParse(
                                                                  this.priceSummryDetails[
                                                                          "totalWithVat"] ??
                                                                      "0.0") ??
                                                              0.0;
                                                      if (advancePayment >=
                                                          totalPriceSummry) {
                                                        MyDialog.showAlert(
                                                            context,
                                                            "Ok",
                                                            "Plata în avans pe care ați introdus-o este egală sau mai mare decât factura totală. Vă rugăm să vă asigurați că introduceți o plată în avans validă");
                                                        advancePayment = 0.0;
                                                      }
                                                      this.advancedPayment =
                                                          advancePayment;
                                                      setState(() {});
                                                    })
                                                : SizedBox.shrink(),
                                            // servises
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              child: MultiSelectDropDown(
                                                showChipInSingleSelectMode:
                                                    true,
                                                //   controller: _controller,
                                                onOptionSelected: (options) {
                                                  this.selectedServices =
                                                      options.map((e) {
                                                    return e.value
                                                        as Map<String, dynamic>;
                                                  }).toList();
                                                  setState(() {});
                                                  //debugPrint(options.first.value.toString());
                                                },
                                                options: this
                                                    .servicesfromFirebase
                                                    .map<ValueItem>((e) {
                                                  //{price: 700,
                                                  // addedAt: ,
                                                  // serviceName: Detailing the exterior - medie,
                                                  // isContract: true,
                                                  // docId: 4Kg6bRfbfnLCm21CQlRw}

                                                  String label = e["isContract"]
                                                      ? e["serviceName"] +
                                                          "--" +
                                                          "B2B"
                                                      : e["serviceName"];
                                                  return ValueItem(
                                                      label: label, value: e);
                                                }).toList(),
                                                maxItems: 5,
                                                selectionType:
                                                    SelectionType.multi,
                                                chipConfig: const ChipConfig(
                                                    wrapType: WrapType.wrap,
                                                    backgroundColor:
                                                        Color(0xFF1ABC9C)),
                                                dropdownHeight: 300,
                                                optionTextStyle:
                                                    const TextStyle(
                                                        fontSize: 16),
                                                selectedOptionIcon: const Icon(
                                                  Icons.check_circle,
                                                  color: Color(0xFF1ABC9C),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width:
                                              staticVar.golobalWidth(context) *
                                                  .12,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: staticVar
                                                      .golobalHigth(context) *
                                                  0.5 +
                                              (this.selectedServices.length *
                                                  15),
                                          child: PriceSummaryCard(
                                            advancePayment:
                                                this.advancedPayment,
                                            serviceList: this.selectedServices,
                                            discount: this.discount.toDouble(),
                                            dataSummary: (data) {
                                              // Handle data from PriceSummaryCard here
                                              this.priceSummryDetails = data;
                                              // print('Price Summary Data:');
                                              // print(data.runtimeType);
                                              // print(data);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 500,
                                    )
                                  ])),
                            ),
                          )),
                  )
                :
                // this part will show all the oders
                Animate(
                    effects: [
                      FadeEffect(duration: Duration(milliseconds: 1200))
                    ],
                    child: this.showOrderDetailsMode
                        ? orderDetails(data: orderDataToDisplay)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /// this row gonna handel the filters

                              Row(
                                children: [
                                  /// disable this of its on employee filter mode
                                  this.filterMode
                                      ? SizedBox.shrink()
                                      : dateCalnderPickUp(onDateRangeChanged:(dateRange, filterdList) {
                                    this.filterdOrders =filterdList;
                                    this.dateFilterMode = true;
                                    this.startDateRangeFilter = dateRange?.start;
                                    this.endDateRangeFilter = dateRange?.end;

                                    setState(() {});

                                  }, ordersfromFirebase: this.ordersfromFirebase,),
                                  // Tooltip(
                                  //         message:
                                  //             "Filtrează după interval de date",
                                  //         child: IconButton(
                                  //           onPressed: showCalender,
                                  //           icon: Icon(
                                  //             Icons.calendar_month_sharp,
                                  //             size: 40,
                                  //           ),
                                  //           color: Color(0xFF1abc9c),
                                  //         )),
                                  SizedBox(
                                    width: 25,
                                  ),

                                  this.dateFilterMode
                                      ? SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            //  height: 100,
                                            child: DropdownButtonFormField2<
                                                String>(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                label: Text("Angajatul"),
                                                // Add Horizontal padding using menuItemStyleData.padding so it matches
                                                // the menu padding when button's width is not specified.
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                // Add more decoration..
                                              ),
                                              hint: const Text(
                                                "Filtrează comenzile în funcție de angajat.",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              items: this
                                                  .employeefromFirebase
                                                  .map((item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item["docId"],
                                                        child: Text(
                                                          item["empName"],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                this.filterdOrders =
                                                    filterByEmployeeID(
                                                        orders: this
                                                            .ordersfromFirebase,
                                                        empId: value ?? "");
                                                this.filterMode = true;
                                                this.filteredEmp = this
                                                        .employeefromFirebase
                                                        .where((e) =>
                                                            e["docId"] == value)
                                                        .first["empName"] ??
                                                    "404NotFound";
                                                setState(() {});
                                              },
                                              buttonStyleData:
                                                  const ButtonStyleData(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                              ),
                                              iconStyleData:
                                                  const IconStyleData(
                                                icon: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.black45,
                                                ),
                                                iconSize: 24,
                                              ),
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                              menuItemStyleData:
                                                  const MenuItemStyleData(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  if (this.filterMode)
                                    Animate(
                                        effects: [SlideEffect()],
                                        child: filterFeedBack(
                                            filterName: this.filteredEmp)),
                                  if (this.dateFilterMode)
                                    Animate(
                                      effects: [SlideEffect()],
                                      child: filterFeedBack(
                                          filterName:
                                              " ${staticVar.formatDateFromTimestamp(this.startDateRangeFilter)}   >>>  ${staticVar.formatDateFromTimestamp(this.endDateRangeFilter)} "),
                                    )
                                ],
                              ),
                              Container(
                                  width: staticVar.golobalWidth(context),
                                  height: staticVar.fullhigth(context) * .9,
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
                                              staticVar.Dc("Model de mașină"),
                                              staticVar.Dc("statusul plății"),
                                              staticVar.Dc("statusul comenzii"),
                                              staticVar.Dc("data adăugată"),
                                              staticVar.Dc("programare")
                                            ],
                                            rows: (this.filterMode ||
                                                        this.dateFilterMode
                                                    ? this.filterdOrders
                                                    : this.ordersfromFirebase)
                                                .map((e) {
                                              String carModeMap =
                                                  e["carModel"] ??
                                                      "404Notfound";
                                              String paymentStatusMap =
                                                  e["paymentStatus"] ??
                                                      "404Notfound";
                                              String orderStatusMap =
                                                  e["status"] ?? "404Notfound";
                                              String addedDate = staticVar
                                                      .formatDateFromTimestamp(
                                                          e["issuedDate"]) ??
                                                  "404Notfound";
                                              String appotimentMap = staticVar
                                                      .formatDateFromTimestamp(e[
                                                          "appointmentDate"]) ??
                                                  "404Notfound";

                                              return DataRow2(
                                                  onTap: () {
                                                    this.orderDataToDisplay =
                                                        e ?? {};
                                                    this.showOrderDetailsMode =
                                                        true;
                                                    setState(() {});
                                                  },
                                                  cells: [
                                                    DataCell(Center(
                                                        child:
                                                            Text(carModeMap))),
                                                    DataCell(Center(
                                                        child: staticVar
                                                             .getPaymentStatusWidget(
                                                                status2:
                                                                    paymentStatusMap))),
                                                    DataCell(Center(
                                                        child: staticVar
                                                            .getOrderStatusWidget(
                                                                status2:
                                                                    orderStatusMap))),
                                                    DataCell(Center(
                                                        child:
                                                            Text(addedDate))),
                                                    DataCell(Center(
                                                        child: Text(
                                                            appotimentMap))),
                                                  ]);
                                            }).toList()),
                                      ))),
                            ],
                          ),
                  )));
  }

  /// these has been replaced by dateCalnderPickUp() widget the i have created
  /// I'll leve it here just in case ^^
  // /// this function gonna handel filter by date range event
  // ///
  // void showCalender() async {
  //   await showDateRangePickerDialog(
  //       offset: Offset(staticVar.fullWidth(context) * .35,
  //           staticVar.fullhigth(context) * .12),
  //       context: context,
  //       builder: datePickerBuilder);
  // }
  //
  // Widget datePickerBuilder(BuildContext context,
  //         dynamic Function(DateRange) onDateRangeChanged) =>
  //     Animate(
  //       effects: [FadeEffect()],
  //       child: DateRangePickerWidget(
  //         theme: CalendarTheme(
  //           selectedColor: Color(0xFF1abc9c),
  //           // Color for selected dates
  //           inRangeColor: Color(0xFF2c3e50),
  //           // Color for dates within range
  //           inRangeTextStyle: TextStyle(color: Colors.white),
  //           // Text style for dates within range
  //           selectedTextStyle: TextStyle(color: Colors.white),
  //           // Text style for selected dates
  //           todayTextStyle: TextStyle(color: Colors.black),
  //           // Text style for today's date
  //           defaultTextStyle: TextStyle(color: Colors.black),
  //           // Default text style for other dates
  //           disabledTextStyle: TextStyle(color: Colors.grey),
  //           // Text style for disabled dates
  //           radius: 50,
  //           // Radius of each calendar tile
  //           tileSize: 50, // Size of each calendar tile
  //         ),
  //         doubleMonth: true,
  //         initialDateRange: DateRange(DateTime.now(), DateTime(2030)),
  //         onDateRangeChanged: (selctedDateRange) {
  //           this.startDateRangeFilter = selctedDateRange?.start;
  //           this.endDateRangeFilter = selctedDateRange?.end;
  //           if (this.startDateRangeFilter == null ||
  //               this.endDateRangeFilter == null)
  //             throw Exception("Error while selecting the date range");
  //           this.dateFilterMode = true;
  //
  //           ///
  //           this.filterdOrders = filterByDateRange(
  //               orders: this.ordersfromFirebase,
  //               startDate: this.startDateRangeFilter ?? DateTime(3000),
  //               endDate: this.endDateRangeFilter ?? DateTime(3000));
  //           this.dateFilterMode = true;
  //
  //           setState(() {});
  //         },
  //         height: staticVar.fullhigth(context) * .45,
  //       ),
  //     );
  //
  // /// this function gonna handel the filter by date range
  // List<Map<String, dynamic>> filterByDateRange(
  //     {required List<Map<String, dynamic>> orders,
  //     required DateTime startDate,
  //     required DateTime endDate}) {
  //   return orders.where((order) {
  //     DateTime appointmentDate = order['issuedDate'].toDate();
  //     bool isWithinDateRange = appointmentDate.isAfter(startDate) &&
  //         appointmentDate.isBefore(endDate.add(Duration(days: 1)));
  //
  //     return isWithinDateRange;
  //   }).toList();
  // }




  /// this function gonna handel the filter by employee name
  List<Map<String, dynamic>> filterByEmployeeID(
      {required List<Map<String, dynamic>> orders, required String empId}) {
    return orders.where((order) {
      String employeeName = order['empId'];
      bool isMatchingEmployee = employeeName == empId;
      return isMatchingEmployee;
    }).toList();
  }

  /// this function will update the order status to completed
  Future<void> _completeOrder() async{
    try {

      this.isLoading = true;
      setState(() {});
      // Get reference to the document
      DocumentReference orderRef =
      FirebaseFirestore.instance.collection('orders').doc(this.orderDataToDisplay["docId"]);
      await orderRef.update({'status': orderStatus.completed.toString()});
      staticVar.showSubscriptionSnackbar(
          context: context, msg:"Comenzile au fost actualizate cu succes.");
      this.isLoading = false ;
      this.showOrderDetailsMode = false ;
      ordersFromFirrbase();
      setState(() {});
    }
    catch(e){
      this.isLoading = false ;
      setState(() {});
      print('error $e') ;
      MyDialog.showAlert(context, "Ok", "Error $e");
    }

}

  /// this funciton will handel the payment status .... it will flip it to paid in case all the condtions are met
  Future<void> upadtePaymentStatus() async {
    /// this funciton will change the payment status to paid if these 2 cases are met
    /// 1. the orders is on pending or inProgress status
    /// 2. the paymetn status is unpaid or partchlly paid
    /// otherwise it will return
    String orderStatusVar = this.orderDataToDisplay['status'];
    String paymentStatus = orderDataToDisplay['paymentStatus'];
    String docId = orderDataToDisplay["docId"] ?? "";
    double advancePayment = orderDataToDisplay['advancedPayment'].toDouble();
    double totalPrice = double.tryParse(orderDataToDisplay['priceSummryDetails']
                ['totalWithVat'] ??
            "0.0") ??
        0.0;

    /// check that the order is not completed NOR canceled
    if (orderStatusVar == orderStatus.pending.toString() ||
        orderStatusVar == orderStatus.inProgress.toString()) {
      // handel the unpaid senario
      if (paymentStatus == PaymentStatus.unpaid.toString()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title:
                  Text('Payment Status', style: TextStyle(color: Colors.white)),
              content: Text(
                  "You are now about to change the payment status of this order. Please make sure to receive $totalPrice RON from the client.",
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    print('update from unpaid ');
                    // Add logic to proceed with cancellation here
                    Navigator.of(context).pop();
                    await updatepaymentStatusToPaid(orderId: docId);
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      // handel the advanced paid senario
      if (paymentStatus == PaymentStatus.partiallyPaid.toString()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title:
                  Text('Payment Status', style: TextStyle(color: Colors.white)),
              content: Text(
                  "You are now about to change the payment status of this order. Please make sure to receive ${totalPrice - advancePayment} RON from the client.",
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    print("updatd from adfavace paymetn ");
                    // Add logic to proceed with cancellation here
                    Navigator.of(context).pop();
                    await updatepaymentStatusToPaid(orderId: docId);
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text('Can\'t change the payment status',
              style: TextStyle(color: Colors.white)),
          content: Text(
              "The order you chose is either already paid, canceled, or completed.",
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('Ok', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// to avoid the complexity i split the code , this function will flip the payment status  to paid
  Future<void> updatepaymentStatusToPaid({required String orderId}) async {
    try {
      this.isLoading = true;
      setState(() {});
      // Get reference to the document
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Update the status field of the document to 'canceled'
      await orderRef.update({'paymentStatus': PaymentStatus.paid.toString()});
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Starea plății a fost actualizată cu succes.");
      this.ordersFromFirrbase();
      this.showOrderDetailsMode = false;
      this.isLoading = false;
      setState(() {});
    } catch (e) {
      print('Error updating order status: $e');
      MyDialog.showAlert(context, "Ok", 'Error updating order status: $e');
      // Handle error as needed
    }
  }

  /// simple funciton the cancel the current order
  Future<void> cancelOrder() async {
    try {
      /// This function will return these cases
      /// 1. the order is already canceled or completed
      /// In case the client what was paid or half paid it will shows the proper msg
      String status = this.orderDataToDisplay['status'];
      String paymentStatus = orderDataToDisplay['paymentStatus'];
      double totalPrice = double.tryParse(
              orderDataToDisplay['priceSummryDetails']['totalWithVat'] ??
                  "0.0") ??
          0.0;
      int advancePayment =
          int.tryParse(orderDataToDisplay['advancedPayment'].toString()) ?? 0;
      String docId = orderDataToDisplay["docId"] ?? "";

      /// 1. if the order is canceld or completed return
      if (status == orderStatus.canceled.toString() ||
          status == orderStatus.completed.toString()) {
        String message = status == orderStatus.canceled
            ? 'You can\'t cancel this order becuase its already been canceled.'
            : 'You can\'t cancel this order becuase its its already completed.';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title: Text(
                'Cancellation Warning',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      /// if the client paid notify the user about it before cancelling
      if (paymentStatus == PaymentStatus.paid.toString()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title:
                  Text('Payment Status', style: TextStyle(color: Colors.white)),
              content: Text(
                  'The client has paid ${totalPrice.toStringAsFixed(2)} RON. Are you sure you want to proceed?',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    // Add logic to proceed with cancellation here
                    Navigator.of(context).pop();
                    await updateOrderStatusToCancel(orderId: docId);
                    // Navigator.of(context).pop(); // Close the dialog
                    // Perform cancellation logic
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      /// if the clint made advance payment make sure to notify the user about it
      if (paymentStatus == PaymentStatus.partiallyPaid.toString()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title:
                  Text('Payment Status', style: TextStyle(color: Colors.white)),
              content: Text(
                  'The client gave you and advance payment  ${advancePayment} RON. Are you sure you want to proceed?',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    // Add logic to proceed with cancellation here
                    Navigator.of(context).pop();
                    await updateOrderStatusToCancel(orderId: docId);
                    //   Navigator.of(context).pop(); // Close the dialog
                    // Perform cancellation logic
                  },
                ),
              ],
            );
          },
        );
        return;
      } else {
        // Handle other cases as needed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Cancellation Warning'),
              content: Text('Are you sure you want to cancel this order ? '),
              actions: <Widget>[
                TextButton(
                  child: Text('Go back'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('yes '),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await updateOrderStatusToCancel(orderId: docId);
                    //   Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      return;
    } catch (e) {
      MyDialog.showAlert(context, "Ok", "error $e");
      this.isLoading = false;
      setState(() {});
    }
  }

  /// to avoid the complexity i split the code , this funciton will flip the status to canceld
  Future<void> updateOrderStatusToCancel({required String orderId}) async {
    try {
      this.isLoading = true;
      setState(() {});
      // Get reference to the document
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Update the status field of the document to 'canceled'
      await orderRef.update({'status': orderStatus.canceled.toString()});
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Comanda a fost anulată cu succes.");
      this.ordersFromFirrbase();
      this.showOrderDetailsMode = false;
      this.isLoading = false;
      setState(() {});
    } catch (e) {
      print('Error updating order status: $e');
      MyDialog.showAlert(context, "Ok", 'Error updating order status: $e');
      // Handle error as needed
    }
  }

  /// simple function to go back from order details to home order page
  void goBackToHomeScreen() {
    this.showOrderDetailsMode = false;
    setState(() {});
  }

  /// this function is going to insert new order in the Database
  Future<void> addNewOrder() async {
    try {
      this.isLoading = true;
      setState(() {});

      /// check the mandetory inputs

      /// Check the name validity
      if (this.clientName.trim() == "" || this.clientName.trim().length < 4) {
        String msg =
            "Vă rugăm să vă asigurați că introduceți un nume de client valid și că acesta are mai mult de 3 caractere.";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      /// the email is not mandetory

      /// check the phone validity
      if (this.clientPhone.trim() == "" ||
          this.clientPhone.trim().length < 10) {
        String msg =
            "Vă rugăm să introduceți un număr de telefon valid, care să aibă 10 caractere.";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      /// check the car model validity
      if (this.carModel.trim() == "" || this.carModel.trim().length < 9) {
        String msg =
            "Vă rugăm să introduceți modelul mașinii și să vă asigurați că are mai mult de 10 caractere.";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      // the CUI validation ****************************************

      ///////////////////////////////////////////////////////////////

      /// check if if the user choose payment method
      if (this.paymentMethod == PaymentMethod.init) {
        String msg =
            "Vă rugăm să selectați metoda de plată și încercați din nou";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      /// check the payment status
      if (this.paymentStatus == PaymentStatus.init) {
        String msg =
            "Vă rugăm să verificați starea plății și să încercați din nou.";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      /// check if the advance payment is less than the total bill

      double totalPriceSummry =
          double.tryParse(this.priceSummryDetails["totalWithVat"] ?? "0.0") ??
              0.0;
      if (this.paymentStatus == PaymentStatus.partiallyPaid &&
          this.advancedPayment >= totalPriceSummry) {
        MyDialog.showAlert(context, "Ok",
            "Plata în avans pe care ați introdus-o este egală sau mai mare decât factura totală. Vă rugăm să vă asigurați că introduceți o plată în avans validă");
        this.advancedPayment = 0.0;
        setState(() {});
        return;
      }

      /// check if the advance payment status is valid by making sure that the advance payment is > 0 and
      if (this.paymentStatus == PaymentStatus.partiallyPaid &&
          this.advancedPayment <= 0) {
        MyDialog.showAlert(context, "Ok",
            "Ți-ai selectat plata anticipată ca statut de plată. Te rog asigură-te că plata anticipată este mai mare decât 0.");

        setState(() {});
        return;
      }

      /// check if the employee is selected
      if (this.empName.trim() == "") {
        String msg =
            "Vă rugăm să selectați angajatul responsabil pentru această comandă.";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      /// Check that the user has been added some servises
      if (this.selectedServices.length == 0) {
        String msg =
            "Te rog adaugă serviciile pentru această comandă și încearcă din nou.";
        MyDialog.showAlert(context, "Ok ", msg);
        return;
      }

      /// get the current user email
      User? user = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> orderData = {
        'clientName': this.clientName,
        'clientEmail': this.clientEmail,
        'clientPhone': this.clientPhone,
        'carModel': this.carModel,
        'issuedDate': DateTime.now(),
        'entranceDate': null,
        'appointmentDate': this.appointmentDate,
        'finishedDate': null,
        'expectedFinishingDate': this.appointmentDate.add(Duration(days: 5)),
        'status': status.toString(),
        'paymentStatus': this.paymentStatus.toString(),
        'paymentMethod': this.paymentMethod.toString(),
        'cui': this.cui,
        'selectedServices': this.selectedServices,
        'priceSummryDetails': this.priceSummryDetails,
        'advancedPayment': this.advancedPayment,
        'discount': this.discount,
        'createdBy': user?.email,
        'servicesPounce': this.servicesPounce,
        'imageBefore': "",
        'imageAfter': "",
        'lock': lock,
        'empId': this.empId,
        'empName': this.empName,
        'empAcceptanceTimestamp': null,
        'completionTimestamp': null,
        'billUrl': "",
        'dealerName': this.dealerName,
        'dealerID': this.dealerID,
        'dealerMode': this.dealerMode,
        'specifecEmployeeMode': this.specifecEmployeeMode
      };

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').add(orderData);
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Comanda a fost adăugată cu succes.");
      ordersFromFirrbase();
      this.isLoading = false;
      this.addNewOrderMode = false;
      setState(() {});

      /// test the data before send
      // for (var i in orderData.keys ){
      //   print(i.toString() + " " + orderData[i].toString());
      //
      // }
    } catch (e) {
      MyDialog.showAlert(context, "Ok", "Error adding order: $e");
      this.isLoading = false;
      setState(() {});
    } finally {
      this.isLoading = false;
      setState(() {});
    }
  }

  // this fucniotn gonna parse the selected string item back to Emum
  PaymentMethod parsePaymentMethodFromString(String value) {
    // Split the string to get the enum member name
    String enumMember =
        value.split('.')[1]; // This assumes 'PaymentMethod.pos' format

    // Find the corresponding enum value
    return PaymentMethod.values.firstWhere(
      (e) => e.toString().split('.').last == enumMember,
      orElse: () => PaymentMethod.init,
    );
  }

  // this fucniotn gonna parse the selected string item back to payment status ** Emum
  PaymentStatus parsePaymentStatusFromString(String value) {
    // Split the string to get the enum member name
    String enumMember =
        value.split('.')[1]; // This assumes 'PaymentMethod.pos' format

    // Find the corresponding enum value
    return PaymentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == enumMember,
      orElse: () => PaymentStatus.init,
    );
  }

  // this funciotn gonna fetch the servise data
  Future<void> fetchServices() async {
    this.isLoading = true;
    setState(() {});
    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define a list to store the fetched data
    List<Map<String, dynamic>> servicesList = [];

    try {
      // Get all documents from the 'services' collection
      QuerySnapshot querySnapshot = await firestore
          .collection('services')
          .orderBy('addedAt', descending: true)
          .get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add document ID to the data map
        data['docId'] = doc.id;

        // Add data map to the list
        servicesList.add(data);
      });

      this.servicesfromFirebase = servicesList;
      // print(this.services);
    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching services: $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching services: $e');
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
      QuerySnapshot querySnapshot =
          await firestore.collection('employee').get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add document ID to the data map
        data['docId'] = doc.id;

        // Add data map to the list
        employeeList.add(data);
      });

      this.employeefromFirebase = employeeList;
      // print(this.services);
      this.isLoading = false;
      setState(() {});
      //print(this.employeefromFirebase);
    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching : $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching employee: $e');
    }
  }

  // this funciotn gonna fetch the B2B data
  Future<void> fetchB2BData() async {
    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define a list to store the fetched data
    List<Map<String, dynamic>> b2bList = [];

    try {
      // Get all documents from the 'services' collection
      QuerySnapshot querySnapshot = await firestore.collection('b2b').get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // the reason for making data2 is to get red of the time stamp , since its making error in the dropdown b2b list
        // to explan more , in the dealer Mode the we have dropdown menu with B2B names on it ok ? and when when u select any dealer
        // all there data will be decode to json and decode onChange() so we can extract the data from it prober way
        // and if there is timestamp its gonna throw an error
        // thats why we did it this way

        Map<String, dynamic> data2 = {};

        // Add document ID to the data map
        data2['docId'] = doc.id;
        data2['phoneNr'] = data["phoneNr"];
        data2['email'] = data["email"];
        data2['B2BName'] = data["B2BName"];
        data2['cui'] = data['cui'];

        // Add data map to the list
        b2bList.add(data2);
      });

      this.b2bfromFirebase = b2bList;

      //print(this.b2bfromFirebase);
    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching : $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching employee: $e');
    }
  }

  // this function gonna fetch all the orders
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

        // Add data map to the list
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
}
