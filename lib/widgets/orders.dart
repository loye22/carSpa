import 'dart:async';
import 'package:car_spa/models/orderModels.dart';
import 'package:car_spa/widgets/CustomDateTimePicker.dart';
import 'package:car_spa/widgets/EmployeeNameCard.dart';
import 'package:car_spa/widgets/PriceSummaryCard.dart';
import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/enum.dart';
import 'package:car_spa/widgets/orderDetails.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'dart:convert' as json;

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  String? _errorMessage;

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
  bool payingEmpMOde = false;

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

  List<orderModel> ordersListTodisplay = [];
  late ordersDataSource ordersDataSources;
  List<Map<String, dynamic>> ordersHelperListTOShowDetails = [];
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchServices();
    ordersFromFirrbase();
    fetchB2BData();
    fetchEmployee();
    ordersDataSources = ordersDataSource(orders: ordersListTodisplay);
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
                      if (this.orderDataToDisplay["status"] ==
                              orderStatus.pending.toString() &&
                          this.orderDataToDisplay["entranceDate"] == null)
                        Tooltip(
                          message: 'Înregistrează intrarea mașinii',
                          child: FloatingActionButton(
                            backgroundColor: Colors.lightBlueAccent,
                            onPressed: _updateCarEnternceDate,
                            child: Icon(
                              Icons.car_crash,
                              color: Colors.white,
                            ), // Icon inside the FAB
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if ((this.orderDataToDisplay["paymentStatus"] ?? false) ==
                              PaymentStatus.paid.toString() &&
                          (this.orderDataToDisplay["status"] ?? false) !=
                              orderStatus.canceled.toString() &&
                          (this.orderDataToDisplay["status"] ?? false) !=
                              orderStatus.completed.toString())

                        /// This button gonna update the order status to completed
                        /// this button will be shown only if the order is apied fully and the order is not on cancel state
                        Tooltip(
                          message: 'Acest buton este pentru a completa comanda',
                          child: FloatingActionButton(
                            backgroundColor: Color(0xFF1ABC9C),
                            onPressed: _completeOrder,
                            child: Icon(
                              Icons.assignment_turned_in,
                              color: Colors.white,
                            ),
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
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.start,
                                        //   children: [
                                        //     Text(
                                        //       'modul angajat',
                                        //       style: TextStyle(
                                        //         fontSize: 18.0,
                                        //       ),
                                        //     ),
                                        //     Switch(
                                        //       value: this.specifecEmployeeMode,
                                        //       onChanged: (bool value) {
                                        //         setState(() {
                                        //           this.specifecEmployeeMode =
                                        //               value;
                                        //         });
                                        //       },
                                        //       activeColor: Color(
                                        //           0xFF1ABC9C), // color when switch is on
                                        //     ),
                                        //   ],
                                        // ),
                                        // Text(
                                        //   "Când vei activa acest comutator, doar angajatul pe care l-ai semnat va accepta comanda.",
                                        //   style: TextStyle(
                                        //       fontSize: 14.0,
                                        //       color: Colors.grey),
                                        // ),
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
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Servicii",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(
                                                        0xFF2c3e50), // Text color
                                                  ),
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
                                                    onOptionSelected:
                                                        (options) {
                                                      this.selectedServices =
                                                          options.map((e) {
                                                        return e.value as Map<
                                                            String, dynamic>;
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

                                                      String label = e[
                                                              "isContract"]
                                                          ? e["serviceName"] +
                                                              "--" +
                                                              "B2B"
                                                          : e["serviceName"];
                                                      return ValueItem(
                                                          label: label,
                                                          value: e);
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
                                                    selectedOptionIcon:
                                                        const Icon(
                                                      Icons.check_circle,
                                                      color: Color(0xFF1ABC9C),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                (showOrderDetailsMode
                    ? orderDetails(data: orderDataToDisplay)
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                cardName(name: "Tabelul comenzilor"),
                                Button(onTap: () {
                                  _dataGridController.selectedIndex = -1;
                                }, text: "text"),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: FilledButton.icon(
                                        onPressed: customFilter1,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(Color(
                                                  0xFF3498DB)), // Blue color for example
                                        ),
                                        icon: const Icon(Icons.filter_1,
                                            color: Colors.white),
                                        // Icon representing 1-15 range
                                        label: const Text(
                                            '         1 - 15          ',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),

                                    // Button for filtering from 16th to end of month
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: FilledButton.icon(
                                        onPressed: customFilter2,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(Color(
                                                  0xFFE74C3C)), // Red color for example
                                        ),
                                        icon: const Icon(
                                            Icons.filter_2_outlined,
                                            color: Colors.white),
                                        // Icon representing 16-end range
                                        label: const Text(
                                            '         16 - END      ',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    payingEmpMOde
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Animate(
                                              effects: [
                                                SlideEffect(
                                                    begin: Offset(1, 0),
                                                    duration: Duration(
                                                        milliseconds: 250))
                                              ],
                                              child: FilledButton.icon(
                                                onPressed: employeePayment,
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color(
                                                              0xFF2ECC71)), // Green color for payment
                                                ),
                                                icon: const Icon(Icons.payment,
                                                    color: Colors.white),
                                                // Payment icon
                                                label: const Text(
                                                    'Handle Payment',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: SizedBox.shrink(),
                                          )

                                    /// handel the employee payment featcher
                                    /// this button gonna pay the selected orders for the assiended employee
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: staticVar.fullhigth(context) * .85,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: Colors.grey, width: 1)),
                                clipBehavior: Clip.hardEdge,
                                child: SfDataGrid(
                                  onSelectionChanged:
                                      (List<DataGridRow> addedRows,
                                          List<DataGridRow> removedRows) {
                                    var _selectedRows =
                                        _dataGridController.selectedRows.length;
                                    if (_selectedRows != 0) {
                                      this.payingEmpMOde = true;
                                      setState(() {});
                                    } else {
                                      this.payingEmpMOde = false;
                                      setState(() {});
                                    }
                                  },
                                  controller: _dataGridController,
                                  checkboxColumnSettings:
                                      DataGridCheckboxColumnSettings(),
                                  showCheckboxColumn: true,
                                  selectionMode: SelectionMode.multiple,
                                  // showColumnHeaderIconOnHover: true,
                                  onCellTap: (details) {
                                    int selectedRowIndex =
                                        details.rowColumnIndex.rowIndex - 1;

                                    /// now we want to extract the the row docID,after that we will use it to extract the whole document data from the list
                                    var row = ordersDataSources.effectiveRows
                                        .elementAt(selectedRowIndex);

                                    /// The doc id extraction
                                    String docID =
                                        row.getCells()[7].value.toString();
                                    // print(docID);
                                    /// fetch the order with exact doc id
                                    Map<String, dynamic> e = this
                                        .ordersHelperListTOShowDetails
                                        .firstWhere((e) => e["docId"] == docID);
                                    this.orderDataToDisplay = e ?? {};
                                    this.showOrderDetailsMode = true;
                                    setState(() {});

                                    //  print(row.getCells()[9].value);

                                    // showInvoiceDetails(
                                    //     context, row.getCells()[9].value);
                                  },
                                  columnWidthMode: ColumnWidthMode.fill,
                                  // headerRowHeight: ,
                                  allowSorting: true,
                                  allowFiltering: true,
                                  source: ordersDataSources,
                                  columns: <GridColumn>[
                                    GridColumn(
                                        columnName: 'carModel',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'Model de mașină',
                                            ))),
                                    GridColumn(
                                        columnName: 'paymentStatus',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text('Stare plată'))),
                                    GridColumn(
                                        columnName: 'orderStatus',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text('Stare comandă'))),
                                    GridColumn(
                                        columnName: 'orderSchedule',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text('Programare comandă'))),
                                    GridColumn(
                                        columnName: 'orderIssueDate',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                'Data emiterii comenzii'))),
                                    GridColumn(
                                        columnName: 'employeeWhoWashIt',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text('Atribuit lui'))),
                                    GridColumn(
                                        columnName: 'employeePaymentStatus',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child:
                                                Text('Stare plată angajat'))),
                                    GridColumn(
                                        columnName: 'DBID',
                                        label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text('DBID'))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))));
  }

  /// This function gonna change the employee payment status for certain orders
  void employeePayment() {
    /// The algo will be like this
    /// 1. Get all the selected orders
    /// 2. check if all the orders are for the same employee if not show proper msg and return.
    /// 3.
    try {
      List<Map<String, dynamic>> ordersToPay = [];
      // Get the empId of the first order
      if (_dataGridController.selectedRows.length == 0) return;

      for (int i = 0; i < _dataGridController.selectedRows.length; i++) {
        String _selectedRowID =
            _dataGridController.selectedRows[i].getCells()[7].value;

        Map<String, dynamic> order = ordersHelperListTOShowDetails
            .firstWhere((e) => e["docId"] == _selectedRowID);
        ordersToPay.add(order);



        // print(_selectedRowID.length);
        // print(_selectedRowID);
        // print(ordersHelperListTOShowDetails.first);
      }

      List<String> ordersToPayID =
          ordersToPay.map((e) => e["docId"]?.toString() ?? "").toList();
      print(ordersToPayID);

      /// Get the empId of the first order
      String firstEmpId = ordersToPay?[0]?['empId'] ?? "NotFOund";
      String empName = ordersToPay?[0]?["empName"] ?? "Notfound";

      /// If the filtered list is empty, all orders are for the same employee
      bool differentEmpOrders =
          ordersToPay.where((order) => order['empId'] != firstEmpId).isEmpty;

      /// in case the user selected orders are not for the same emplyee in this case we cant proceed the payment
      if (!differentEmpOrders) {
        MyDialog.showAlert(context, "Ok",
            "Pentru a efectua plata, toate comenzile trebuie să aibă același angajat. Vă rugăm să vă asigurați că toate comenzile au același angajat și să încercați din nou ");
        return;
      }

      showEmployeeProfitDialog(context, empName, ordersToPay, ordersToPayID);


    } catch (e) {
      print(e);
      MyDialog.showAlert(context, "OK", "Error: $e");
    }
    finally{
      _dataGridController.selectedIndex = -1;
      payingEmpMOde = false  ;
      setState(() {});
    }
  }

  /// This function gonna show all the orders for certain employee  and calculate there percentage
  void showEmployeeProfitDialog(BuildContext context, String employeeName,
      List<Map<String, dynamic>> orders, List<String> ordersToPayID) {
    try {
      double totalProfit = 0.0;
      double earnings = 0.0;

      // Calculate total profit
      for (var order in orders) {
        var priceSummary = order['priceSummryDetails'];
        if (priceSummary != null && priceSummary['totalPrice'] != null) {
          totalProfit +=
              double.tryParse(priceSummary['totalPrice'].toString()) ?? 0.0;
        }
      }

      TextEditingController percentageController = TextEditingController();

      /// Extraction the curret date filter
      String From = "";
      String To = "";
      var filteredEntries = ordersDataSources.filterConditions.entries
          .where((entry) => entry.key == "orderIssueDate");
      for (var i in filteredEntries) {
        From = DateFormat('dd-MM-yyyy').format(i.value[0].value as DateTime);
        To = DateFormat('dd-MM-yyyy').format(i.value[1].value as DateTime);
      }
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {

              return AlertDialog(
                title: Text(employeeName,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: staticVar.fullWidth(context) * .5,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var order in orders) ...[
                          Text("${order['carModel'] ?? 'Unknown Car'}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          for (var service in order['selectedServices'] ?? [])
                            ListTile(
                              title: Text(
                                  service['serviceName'] ?? 'Unknown Service'),
                              subtitle: Text(
                                  "Price: ${service['price'] ?? '0.00'} RON"),
                            ),
                          Divider(),
                        ],
                        Text("De la: $From"),
                        Text("La: $To"),
                        Text("Total Mașini Servite: ${orders.length}"),
                        Text(
                            "Total Profituri: ${totalProfit.toStringAsFixed(2)} RON"),
                        SizedBox(height: 20),
                        TextField(
                          controller: percentageController,
                          decoration: InputDecoration(
                            errorText: _errorMessage,
                            labelText: "Enter Percentage",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            print(percentageController.text);
                            _validateInput(value);
                            // Update earnings whenever the percentage changes
                            double percentage = double.tryParse(value) ?? 0.0;
                            earnings = (percentage / 100) * totalProfit;
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 20),
                        Text("$employeeName va lua: RON ${earnings.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ),
                ),
                actions: _errorMessage != null
                    ? []
                    : [
                  TextButton(
                    onPressed: () async{
                      try  {
                        // Handle proceed logic
                        /// 1. On proceed the function will update the employeePaymentStatus for all of the selected orders
                        /// according to the docs ID
                        /// 2. After we gonna insert the payment details in payments table as this
                        /// payment date : ......
                        /// payment amount : ......
                        /// payment percentage : ......
                        /// to whom : .......
                        /// paidBy: ........

                        /// if emplyee cut is 0.0 return
                        if (earnings == 0.0) {
                          MyDialog.showAlert(context, "Ok",
                              "Vă rugăm să vă asigurați că veniturile angajatului sunt mai mari de 0 RON");
                          return;
                        }


                        _errorMessage = "";
                        setState((){});
                        // Updating the employeePaymentStatus for these orders
                        final firestore = FirebaseFirestore.instance;
                        // Iterate through the order IDs
                        for (String orderId in ordersToPayID) {
                          print(orderId);
                        //  Reference to the specific order document
                          DocumentReference orderRef =
                          firestore.collection('orders').doc(orderId);
                          // Update the employeePaymentStatus and add the payment details
                          await orderRef.update({
                            'employeePaymentStatus': true,
                          });
                          print('Order $orderId updated successfully.');
                        }

                        // User? user =
                        // await FirebaseAuth.instance.currentUser;
                        //
                        // // Log the payment details into the 'payments' collection
                        // await firestore.collection('payments').add({
                        //   'allOrdersDetails': orders,
                        //   'ordersID':
                        //   ordersToPayID, // Reference to the order
                        //   'paidBy': user?.email ?? "notfounf",
                        //   'toWhom': employeeName,
                        //   'paymentPercentage': percentageController?.text ?? "notfound",
                        //   'paymentDate': DateTime.now(),
                        //   'paymentAmountToEmployee': earnings,
                        //   'TotalPro': totalProfit,
                        //   'ordersDateFrom': From,
                        //   'ordersDateTo': To
                        // });






                        Navigator.of(context).pop();
                      }
                      catch(e){}

                    },
                    child: Text("Proceed"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"),
                  ),
                ],
              );


            },
          );
        },
      );
    } catch (e) {
      print(e);
      MyDialog.showAlert(context, "Ok", "Error: $e ");
    }
  }

  void _validateInput(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 1 || intValue > 100) {
      setState(() {
        _errorMessage = "Te rog să introduci un număr între 1 și 100.";
      });
    } else {
      setState(() {
        _errorMessage = null; // Clear the error message if valid
      });
    }
  }

  /// helper function for showEmployeeProfitDialog()
  double _calculateEarnings(String total, String percentage) {
    if (percentage.isEmpty) return 0.0;
    double totalValue = double.tryParse(total) ?? 0.0;
    double perc = double.tryParse(percentage) ?? 0.0;
    return totalValue * (perc / 100);
  }

  /// This function gonna filter the orders from 1st of current month unilt the 15th
  void customFilter1() {
    try {
      // Handle logic for filtering from 1 to 15
      /// SO this gonna filter gonna filter all the orders from the 1st of current month
      /// and current year unilt the 15th of current month current year
      /// /*  every thing between these /**/ are the current month so in production mode uncomment them the remove 09  */
      DateTime now = DateTime.now();
      ordersDataSources.clearFilters();
      ordersDataSources.addFilter(
          'orderIssueDate',
          FilterCondition(
            value: DateTime(now.year, /*now.month*/ 09, 1),
            filterOperator: FilterOperator.and,
            type: FilterType.greaterThanOrEqual,
          ));
      ordersDataSources.addFilter(
          'orderIssueDate',
          FilterCondition(
            value: DateTime(now.year, /*now.month*/ 09, 15),
            filterOperator: FilterOperator.and,
            type: FilterType.lessThanOrEqual,
          ));

      ordersDataSources.addFilter(
          'employeePaymentStatus',
          FilterCondition(
            value: false,
            filterOperator: FilterOperator.and,
            filterBehavior: FilterBehavior.stringDataType,
            type: FilterType.equals,
          ));
    } catch (e) {
      print(e);
      MyDialog.showAlert(context, "Ok", "Error: $e");
    }
  }

  /// This function gonna filter the orders from 16st of current month until the end of current month
  void customFilter2() {
    try {
      // Handle logic for filtering from 16 to end
      /// SO this gonna filter gonna filter all the orders from the 16th of current month
      /// and current year unilt the END of current month current year
      /// /*  every thing between these /**/ are the current month so in production mode uncomment them the remove 09  */
      DateTime now = DateTime.now();
      DateTime firstDayNextMonth = DateTime(now.year, /*now.month + 1*/ 10, 1);
      DateTime lastDayOfMonth = firstDayNextMonth.subtract(Duration(days: 1));

      ordersDataSources.clearFilters();
      ordersDataSources.addFilter(
          'orderIssueDate',
          FilterCondition(
            value: DateTime(now.year, /*now.month*/ 09, 16),
            filterOperator: FilterOperator.and,
            type: FilterType.greaterThanOrEqual,
          ));
      ordersDataSources.addFilter(
          'orderIssueDate',
          FilterCondition(
            value: lastDayOfMonth,
            filterOperator: FilterOperator.and,
            type: FilterType.lessThanOrEqual,
          ));

      ordersDataSources.addFilter(
          'employeePaymentStatus',
          FilterCondition(
            value: false,
            filterOperator: FilterOperator.and,
            filterBehavior: FilterBehavior.stringDataType,
            type: FilterType.equals,
          ));
    } catch (e) {
      print(e);
      MyDialog.showAlert(context, "Ok", "Error: $e");
    }
  }

  /// this function gonna handel the filter by employee name
  List<Map<String, dynamic>> filterByEmployeeID(
      {required List<Map<String, dynamic>> orders, required String empId}) {
    return orders.where((order) {
      String employeeName = order['empId'];
      bool isMatchingEmployee = employeeName == empId;
      return isMatchingEmployee;
    }).toList();
  }

  /// THis function gonna register the car entrence date in the car spa
  /// PLease note to update the status the status of the order must be pendding
  /// and the current date must be after the appotment
  Future<void> _updateCarEnternceDate() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String docId = orderDataToDisplay["docId"] ?? "";
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text('Înregistrare intrare mașină',
              style: TextStyle(color: Colors.white)),
          content: Text(
              "Asigurați-vă că mașina este introdusă corect în facilitatea de îngrijire auto. Vă rugăm să nu continuați dacă mașina nu este prezentă!",
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
                if (DateTime.now().isBefore(
                    this.orderDataToDisplay["appointmentDate"].toDate())) {
                  MyDialog.showAlert(context, "Ok",
                      "Această comandă este programată pentru ${staticVar.formatDateFromTimestampWithTime(this.orderDataToDisplay["appointmentDate"])}. Nu poate fi finalizată acum.");
                  return;
                }
                await _updateCarEnternceOnDataBase(docId: docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCarEnternceOnDataBase({required String docId}) async {
    try {
      /// Check if the current date and time (Datetime.now()) is before the appointment.
      /// If so, return because it doesn't make sense to finish the car before its appointment.

      this.isLoading = true;
      setState(() {});
      // Get reference to the document
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc(docId);

      // Update the status field of the document to 'canceled'
      await orderRef.update({'entranceDate': DateTime.now()});
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Starea plății a fost actualizată cu succes.");
      this.ordersFromFirrbase();
      this.showOrderDetailsMode = false;
      this.isLoading = false;
      setState(() {});
    } catch (e) {
      MyDialog.showAlert(context, "Ok", "Error $e");
    }
  }

  /// this function will update the order status to completed
  Future<void> _completeOrder() async {
    try {
      /// Check if the current date and time (Datetime.now()) is before the appointment.
      /// If so, return because it doesn't make sense to finish the car before its appointment.
      if (DateTime.now()
          .isBefore(this.orderDataToDisplay["appointmentDate"].toDate())) {
        MyDialog.showAlert(context, "Ok",
            "Această comandă este programată pentru ${staticVar.formatDateFromTimestampWithTime(this.orderDataToDisplay["appointmentDate"])}. Nu poate fi finalizată acum.");
        return;
      }

      this.isLoading = true;
      setState(() {});
      // Get reference to the document
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(this.orderDataToDisplay["docId"]);
      await orderRef.update({
        'status': orderStatus.completed.toString(),
        'finishedDate': DateTime.now()
      });
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Comenzile au fost actualizate cu succes.");
      this.isLoading = false;
      this.showOrderDetailsMode = false;
      ordersFromFirrbase();
      setState(() {});
    } catch (e) {
      this.isLoading = false;
      setState(() {});
      print('error $e');
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
                  staticVar.inRomanian
                      ? "Acum urmează să schimbați statusul plății acestei comenzi. Vă rugăm să vă asigurați că primiți ${totalPrice.toStringAsFixed(2)} RON de la client."
                      : "You are now about to change the payment status of this order. Please make sure to receive ${totalPrice.toStringAsFixed(2)} RON from the client.",
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
                  staticVar.inRomanian
                      ? "Acum urmează să schimbați statusul plății acestei comenzi. Vă rugăm să vă asigurați că primiți ${(totalPrice - advancePayment).toStringAsFixed(2)} RON de la client."
                      : "You are now about to change the payment status of this order. Please make sure to receive ${(totalPrice - advancePayment).toStringAsFixed(2)} RON from the client.",
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
          title: Text(
              staticVar.inRomanian
                  ? "Nu se poate schimba statusul plății"
                  : 'Can\'t change the payment status',
              style: TextStyle(color: Colors.white)),
          content: Text(
              staticVar.inRomanian
                  ? "Comanda pe care ați ales-o este deja plătită, anulată sau finalizată."
                  : "The order you chose is either already paid, canceled, or completed.",
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
        String mesaj = status == orderStatus.canceled
            ? 'Nu puteți anula această comandă deoarece a fost deja anulată.'
            : 'Nu puteți anula această comandă deoarece a fost deja finalizată.';

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
                staticVar.inRomanian ? mesaj : message,
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
                  staticVar.inRomanian
                      ? "Clientul a plătit ${totalPrice.toStringAsFixed(2)} RON. Sunteți sigur că doriți să continuați?"
                      : 'The client has paid ${totalPrice.toStringAsFixed(2)} RON. Are you sure you want to proceed?',
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

      /// if the client made advance payment make sure to notify the user about it
      if (paymentStatus == PaymentStatus.partiallyPaid.toString()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title:
                  Text('Payment Status', style: TextStyle(color: Colors.white)),
              content: Text(
                  staticVar.inRomanian
                      ? "Clientul v-a dat un avans de ${advancePayment} RON. Sunteți sigur că doriți să continuați?"
                      : 'The client gave you and advance payment  ${advancePayment} RON. Are you sure you want to proceed?',
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
              title: Text(staticVar.inRomanian
                  ? "Avertisment de anulare"
                  : 'Cancellation Warning'),
              content: Text(staticVar.inRomanian
                  ? "Sunteți sigur că doriți să anulați această comandă?"
                  : 'Are you sure you want to cancel this order ? '),
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

      /// Check if the advance payement is less than the total price after disocunt
      double advancePayment = this.priceSummryDetails["advancePayment"];
      double totalWithVat =
          double.tryParse(priceSummryDetails["totalWithVat"] ?? "0.0") ?? 0.0;
      if (advancePayment >= totalWithVat) {
        MyDialog.showAlert(context, "OK",
            "Avansul dumneavoastră este mai mare decât prețul total.");
        this.advancedPayment = 0.0;
        this.discount = 0;
        setState(() {});
        return;
      }

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
        'specifecEmployeeMode': this.specifecEmployeeMode,
        'employeePaymentStatus': false
      };

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').add(orderData);
      staticVar.showSubscriptionSnackbar(
          context: context, msg: "Comanda a fost adăugată cu succes.");
      ordersFromFirrbase();
      this.isLoading = false;
      this.addNewOrderMode = false;
      resetVars();
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
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore
          .collection('orders')
          .orderBy('issuedDate', descending: true)
          .snapshots()
          .listen((querySnapshot) {
        List<orderModel> ordersHeper = [];

        /// Ok the reason why i created this list is get copy of the orders so when i want to show certain order details I'll filter them
        /// by doc ID
        List<Map<String, dynamic>> ordersHelperListTOShowDetailsFromFirebase =
            [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["docId"] = doc.id;
          orderModel order = orderModel(
            docId: doc.id,
            carModel: data['carModel'] ?? '',
            orderIssueDate: data['issuedDate'].toDate() ?? '',
            orderStatus: data['status'] ?? '',
            paymentStatus: data['paymentStatus'] ?? '',
            employeePaymentStatus: data['employeePaymentStatus'] ?? false,
            employeeWhoWashIt: data['empName'] ?? '',
            orderSchedule: data['appointmentDate'].toDate() ?? '',
          );

          ordersHeper.add(order);
          ordersHelperListTOShowDetailsFromFirebase.add(data);
        }
        ordersListTodisplay = ordersHeper;
        ordersDataSources = ordersDataSource(orders: ordersListTodisplay);
        ordersHelperListTOShowDetails =
            ordersHelperListTOShowDetailsFromFirebase;

        setState(() {});
      });
    } catch (e) {
      // Print any errors for debugging purposes
      print('Error fetching : $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching orders: $e');
    }
  }

  void resetVars() {
    clientName = '';
    clientEmail = '';
    clientPhone = '';
    carModel = '';
    entranceDate = null;
    appointmentDate = DateTime.now().add(Duration(days: 1));
    finishedDate = null;
    this.status = orderStatus.pending;
    paymentStatus = PaymentStatus.init;
    paymentMethod = PaymentMethod.init;
    cui = '';
    selectedServices = [];
    priceSummryDetails = {};
    advancedPayment = 0.0;
    discount = 0;
    servicesPounce = '';
    imageBefore = '';
    imageAfter = '';
    lock = false;
    empId = '';
    empName = '';
    empAcceptanceTimestamp = null;
    completionTimestamp = null;
    billUrl = '';
    dealerName = '';
    dealerID = '';
    dealerMode = false;
    specifecEmployeeMode = false;
  }
}
