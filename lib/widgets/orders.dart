import 'dart:async';
import 'package:car_spa/widgets/CustomDateTimePicker.dart';
import 'package:car_spa/widgets/PriceSummaryCard.dart';
import 'package:car_spa/widgets/customTextFieldWidget.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/enum.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
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


  List<Map<String, dynamic>> employeefromFirebase = [];
  List<Map<String, dynamic>> b2bfromFirebase = [];

  Map<String, dynamic> priceSummryDetails = {};

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
  bool specifecEmployeeMode = false ;

  ////////So here the ends for the vars that we gonna send to data base //////////////////

  bool addNewOrderMode = false;
  bool isLoading = false;

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
      floatingActionButton: this.addNewOrderMode ?
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'trimite',
            child: FloatingActionButton(
              backgroundColor: Color(0xFF1ABC9C),
              onPressed:addNewOrder,
              child: Icon(
                Icons.upload,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Tooltip(
            message: 'anula',
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: ()  {
               this.addNewOrderMode = false ;
               setState(() {});
              },
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.white,
              ),
            ),
          )
        ],
      ):
      FloatingActionButton(
        backgroundColor: Color(0xFF1ABC9C),
        onPressed: () async {
          this.addNewOrderMode = true ;
          setState(() {});
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body:this.addNewOrderMode ?
      // this part will handel adding new orders to the database
      Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 900))],
        child: (this.isLoading
            ? staticVar.loading()
            : Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                            style:
                            TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'modul angajat',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              Switch(
                                value:  this.specifecEmployeeMode ,
                                onChanged: (bool value) {

                                  setState(() {
                                    this.specifecEmployeeMode = value;
                                  });
                                },
                                activeColor: Color(
                                    0xFF1ABC9C), // color when switch is on
                              ),
                            ],
                          ),
                          Text(
                            "Când vei activa acest comutator, doar angajatul pe care l-ai semnat va accepta comanda.",
                            style:
                            TextStyle(fontSize: 14.0, color: Colors.grey),
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
                            width: staticVar.golobalWidth(context) * .32,
                            child: DropdownButtonFormField2<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                // Add more decoration..
                              ),
                              hint: const Text(
                                "Vă rog să selectați clientul.",
                                style: TextStyle(fontSize: 14),
                              ),
                              items: this
                                  .b2bfromFirebase
                                  .map((item) => DropdownMenuItem<String>(
                                value: json
                                    .jsonEncode(item)
                                    .toString(),
                                child: Text(
                                  item["B2BName"],
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                Map<String, dynamic> valueMap =
                                json.jsonDecode(value ?? "");
                                this.dealerID = valueMap["docId"];
                                this.dealerName = valueMap["B2BName"];
                                this.clientName = valueMap["B2BName"];
                                this.clientEmail = valueMap["email"];
                                this.clientPhone = valueMap["phoneNr"];
                                this.cui =  valueMap['cui'];
                                setState(() {});
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
                                padding:
                                EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          )
                              : Expanded(
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
                          SizedBox(
                              width: this.dealerMode
                                  ? staticVar.golobalWidth(context) * .13
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
                      Row(
                        children: [
                          this.dealerMode
                              ? Expanded(
                            child: customTextFieldWidget(
                              dealerMode: this.dealerMode,
                              dealerData: this.cui,
                              label: 'CUI',
                              hintText: 'client@example.com',
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
                              isItNumerical : true ,
                              isItDiscount: true,
                              label: 'Discount',
                              hintText: 'Enter Discount',
                              suffex: "%",
                              onChanged: (value) {
                                setState(() {
                                  discount = int.tryParse(value) ?? 0;
                                });
                              },

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomDateTimePicker(
                              label: "program pentru.",
                              hintText: 'select the appotimeint ',
                              onChanged: (d) {
                                this.appointmentDate = d;
                              }),
                          SizedBox(
                              width: staticVar.golobalWidth(context) * .13),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              // payment method
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    label: Text("metoda de plată"),
                                    // Add Horizontal padding using menuItemStyleData.padding so it matches
                                    // the menu padding when button's width is not specified.
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    // Add more decoration..
                                  ),
                                  hint: const Text(
                                    'Selectați metoda de plată pentru acest client.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: PaymentMethod.values
                                      .getRange(
                                      0, PaymentMethod.values.length - 1)
                                      .map((item) => DropdownMenuItem<String>(
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
                                    this.paymentMethod =
                                        parsePaymentMethodFromString(
                                            value ?? "");
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
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                              ),
                              //employee selection
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                //  height: 100,
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    label: Text("Angajatul"),
                                    // Add Horizontal padding using menuItemStyleData.padding so it matches
                                    // the menu padding when button's width is not specified.
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    // Add more decoration..
                                  ),
                                  hint: const Text(
                                    "Vă rugăm să selectați angajatul care va fi responsabil pentru această comandă.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: this
                                      .employeefromFirebase
                                      .map((item) => DropdownMenuItem<String>(
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
                                    if (value == null) {
                                      MyDialog.showAlert(context, "Ok",
                                          "Error when we try to get the employee ID while the user selecting the emp");
                                      throw Exception(
                                          "Error when we try to get the employee ID while the user selecting the emp");
                                    }
                                    this.empId = value;
                                    this.empName = this
                                        .employeefromFirebase
                                        .where((element) =>
                                    element["docId"] == value)
                                        .first["empName"];
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
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                              ),
                              // payment status
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                //  height: 100,
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    label: Text("statutul plății"),
                                    // Add Horizontal padding using menuItemStyleData.padding so it matches
                                    // the menu padding when button's width is not specified.
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    // Add more decoration..
                                  ),
                                  hint: const Text(
                                    "vă rugăm să selectați statutul plății pentru această comandă",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: PaymentStatus.values
                                      .getRange(
                                      0, PaymentStatus.values.length - 1)
                                      .map((item) => DropdownMenuItem<String>(
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
                                    this.paymentStatus =
                                        parsePaymentStatusFromString(
                                            value ?? "");
                                    if (this.paymentStatus !=
                                        PaymentStatus.partiallyPaid)
                                      this.advancedPayment = 0.0;
                                    setState(() {});
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
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                              ),
                              // this txt filed will handel the partially paid status
                              SizedBox(
                                height: 16,
                              ),
                              this.paymentStatus == PaymentStatus.partiallyPaid
                                  ? customTextFieldWidget(
                                  limit: 4,
                                  isItNumerical: true,
                                  label: "plată în avans",
                                  hintText: "... Ron",
                                  onChanged: (value) {
                                    double advancePayment =
                                        double.tryParse(value) ?? 0.0;
                                    double totalPriceSummry =
                                        double.tryParse(
                                            this.priceSummryDetails[
                                            "totalWithVat"] ??
                                                "0.0") ??
                                            0.0;
                                    if (advancePayment >=
                                        totalPriceSummry) {
                                      MyDialog.showAlert(context, "Ok",
                                          "Plata în avans pe care ați introdus-o este egală sau mai mare decât factura totală. Vă rugăm să vă asigurați că introduceți o plată în avans validă");
                                      advancePayment = 0.0;
                                    }
                                    this.advancedPayment = advancePayment;
                                    setState(() {});
                                  })
                                  : SizedBox.shrink(),
                              // servises
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: MultiSelectDropDown(
                                  showChipInSingleSelectMode: true,
                                  //   controller: _controller,
                                  onOptionSelected: (options) {
                                    this.selectedServices = options.map((e) {
                                      return e.value as Map<String, dynamic>;
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
                                        ? e["serviceName"] + "--" + "B2B"
                                        : e["serviceName"];
                                    return ValueItem(label: label, value: e);
                                  }).toList(),
                                  maxItems: 5,
                                  selectionType: SelectionType.multi,
                                  chipConfig: const ChipConfig(
                                      wrapType: WrapType.wrap,
                                      backgroundColor: Color(0xFF1ABC9C)),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
                                  selectedOptionIcon: const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1ABC9C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: staticVar.golobalWidth(context) * .12,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: staticVar.golobalHigth(context) * 0.5 +
                                (this.selectedServices.length * 15),
                            child: PriceSummaryCard(
                              advancePayment: this.advancedPayment,
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
      ) :
          // this part will show all the oders
      Animate(
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
                        staticVar.Dc("Model de mașină"),
                        staticVar.Dc("statusul plății"),
                        staticVar.Dc("statusul comenzii"),
                        staticVar.Dc("data adăugată"),
                        staticVar.Dc("programare")
                      ],
                      rows: this.ordersfromFirebase.map((e) {
                        String carModeMap = e["carModel"]?? "404Notfound";
                        String paymentStatusMap = e["paymentStatus"]?? "404Notfound";
                        String orderStatusMap = e["status"]?? "404Notfound";
                        String addedDate = staticVar.formatDateFromTimestamp(e["issuedDate"])?? "404Notfound";
                        String appotimentMap = staticVar.formatDateFromTimestamp(e["appointmentDate"])?? "404Notfound";

                        return DataRow(cells: [
                          DataCell(Center(child:  Text(carModeMap))),
                          DataCell(Center(child:  staticVar.getPaymentStatusWidget(status2: paymentStatusMap))),
                          DataCell(Center(child:  staticVar.getOrderStatusWidget(status2: orderStatusMap))),
                          DataCell(Center(child:  Text(addedDate))),
                          DataCell(Center(child:  Text(appotimentMap))),
                        ]);
                      }).toList()
                    ),
                  ))),
        ),
      ),
    );
  }

  /// this function is going to insert new order in the Database
  Future<void> addNewOrder() async {
    try{
      this.isLoading = true ;
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
      if (this.clientPhone.trim() == "" || this.clientPhone.trim().length < 10) {
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
        String msg = "Vă rugăm să selectați metoda de plată și încercați din nou";
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
        'entranceDate': null ,
        'appointmentDate': this.appointmentDate,
        'finishedDate': null ,
        'expectedFinishingDate' : this.appointmentDate.add(Duration(days: 5)) ,
        'status': status.toString(),
        'paymentStatus': this.paymentStatus.toString(),
        'paymentMethod': this.paymentMethod.toString(),
        'cui': this.cui,
        'selectedServices': this.selectedServices,
        'priceSummryDetails': this.priceSummryDetails,
        'advancedPayment': this.advancedPayment,
        'discount': this.discount,
        'createdBy': user?.email ,
        'servicesPounce': this.servicesPounce,
        'imageBefore': "",
        'imageAfter': "",
        'lock': lock,
        'empId': this.empId,
        'empName': this.empName,
        'empAcceptanceTimestamp': null ,
        'completionTimestamp': null ,
        'billUrl': "",
        'dealerName': this.dealerName,
        'dealerID': this.dealerID,
        'dealerMode': this.dealerMode,
        'specifecEmployeeMode' : this.specifecEmployeeMode
      };

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').add(orderData);
      staticVar.showSubscriptionSnackbar(context: context, msg: "Comanda a fost adăugată cu succes.");
      ordersFromFirrbase();
      this.isLoading = false ;
      this.addNewOrderMode = false ;
      setState(() {});



      /// test the data before send
      // for (var i in orderData.keys ){
      //   print(i.toString() + " " + orderData[i].toString());
      //
      // }

    }

    catch (e){

      MyDialog.showAlert(context, "Ok", "Error adding order: $e");
      this.isLoading = false  ;
      setState(() {});

    }
    finally{
      this.isLoading = false  ;
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
      QuerySnapshot querySnapshot =
          await firestore.collection('services').orderBy('addedAt', descending: true).get();

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
      QuerySnapshot querySnapshot =
      await firestore.collection('orders').orderBy('issuedDate', descending: true).get();

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
      print(this.ordersfromFirebase);
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
