import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/button2.dart';
import 'package:car_spa/widgets/employeePage.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class orderDetails extends StatelessWidget {
  final Map<String, dynamic> data;


  orderDetails({required this.data  });

  @override
  Widget build(BuildContext context) {
    return staticVar.inRomanian ?
    Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Nume Client', data['clientName'] ?? "404NotFound"),
              _buildRow('Telefon Client', data['clientPhone'] ?? "404NotFound"),
              _buildRow('Email Client', data['clientEmail'] ?? "404NotFound"),
              _buildRow('Data Emiterii', _formatDateTime(data['issuedDate']) ?? "404NotFound"),
              _buildRow('Data Programării', _formatDateTime(data['appointmentDate']) ?? "404NotFound"),
              _buildRow('Data Estimată de Finalizare', _formatDateTime(data['expectedFinishingDate']) ?? "404NotFound"),
              _buildRow('Acceptare Angajat', _formatDateTime(data['empAcceptanceTimestamp']) ?? "404NotFound"),
              _buildRow('Data Intrării', _formatDateTime(data['entranceDate']) ?? "404NotFound"),
              _buildRow('Data Finalizării', _formatDateTime(data['finishedDate']) ?? "404NotFound"),
              _buildRow('Model Mașină', data['carModel'] ?? "404NotFound"),
              _buildRow('Nume Angajat', data['empName'] ?? "404NotFound"),
              _buildRow('Data Finalizării', _formatDateTime(data['completionTimestamp']) ?? "404NotFound"),
             // _buildRow('Imagine Înainte', data['imageBefore'] ?? 'N/A'),
            //  _buildRow('Imagine După', data['imageAfter'] ?? 'N/A'),
              _buildPriceSummaryRow(priceSummary:data['priceSummryDetails'] ?? "404NotFound" ),
              _buildRow('CUI', data['cui'] ?? 'N/A'),
              _buildRow(
                'Mod Dealer',
                data['dealerMode'].toString(),
                passWidgetAsValue: true,
                widget: data['dealerMode']
                    ? StatusLabel(
                  color: Colors.green,
                  text: "B2B",
                )
                    : Text('N/A'),
              ),
              this.data["billUrl"] == ""
                  ? _buildRowWithButtom(
                  label: 'URL Factură',
                  onPress: () {},
                  buttonLabel: 'show',
                  buttonColor: Colors.blueAccent)
                  : _buildRowWithButtom(
                  label: 'URL Factură',
                  onPress: () {},
                  buttonLabel: 'Arată factură'),
              _buildRow('Metodă Plată', data['paymentMethod']?.toString()?.split(".")?.last ?? "404NotFound"),
              _buildRow('Status Plată', data['paymentStatus']?.toString()?.split(".")?.last ?? "404NotFound"),
              _buildRow('Status Comandă', data['status']?.toString()?.split(".")?.last ?? "404NotFound"),
              _buildRow('Creat de', data['createdBy']),
              _buildRow('Servicii Pounce', data['servicesPounce'] ?? 'N/A'),
              //_buildRow('ID Dealer', data['dealerID'] ?? 'N/A'),
              _buildRow('Mod Specific Angajat', data['specifecEmployeeMode'].toString()),
              _buildSelectedServices(selectedServices: data['selectedServices']   ),
            ],
          ),
        ),
      ),
    ) :
    Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Client Name', data['clientName']?? "404NotFound"),
              _buildRow('Client Phone', data['clientPhone']?? "404NotFound"),
              _buildRow('Client Email', data['clientEmail']?? "404NotFound"),
              _buildRow('Issued Date', _formatDateTime(data['issuedDate'])?? "404NotFound"),
              _buildRow('Appointment Date', _formatDateTime(data['appointmentDate'])?? "404NotFound"),
              _buildRow('Expected Finishing Date', _formatDateTime(data['expectedFinishingDate'])?? "404NotFound"),
              _buildRow('Employee Acceptance ', _formatDateTime(data['empAcceptanceTimestamp'])?? "404NotFound"),
              _buildRow('Entrance Date', _formatDateTime(data['entranceDate'])?? "404NotFound"),
              _buildRow('Finished Date', _formatDateTime(data['finishedDate'])?? "404NotFound"),
              _buildRow('Car Model', data['carModel']?? "404NotFound"),
              _buildRow('Employee Name', data['empName']?? "404NotFound"),
              _buildRow('Completion Date', _formatDateTime(data['completionTimestamp'])?? "404NotFound"),
              _buildRow('Image Before', data['imageBefore'] ?? 'N/A'),
              _buildRow('Image After', data['imageAfter'] ?? 'N/A'),
             _buildPriceSummaryRow(priceSummary: data['priceSummryDetails']?? "404NotFound"),
              _buildRow('CUI', data['cui'] ?? 'N/A'),
              _buildRow('Dealer Mode', data['dealerMode'].toString() , passWidgetAsValue:  true , widget:
              data['dealerMode'] ?
              StatusLabel(
                color: Colors.green,
                text: "B2B",
              ) : Text('N/A') ),
              this.data["billUrl"] == "" ? _buildRowWithButtom(label: 'Bill URL' , onPress: (){},buttonLabel: 'Upload bill' ,buttonColor: Colors.blueAccent)  :  _buildRowWithButtom(label: 'Bill URL' , onPress: (){},buttonLabel: 'Show bill'),
              _buildRow('Payment Method', data['paymentMethod']?.toString()?.split(".")?.last ?? "404NotFound"),
              _buildRow('Payment Status', data['paymentStatus']?.toString()?.split(".")?.last ?? "404NotFound"),
              _buildRow('Order status', data['status']?.toString()?.split(".")?.last ?? "404NotFound"),
              _buildRow('Created By', data['createdBy']),
              _buildRow('Services Pounce', data['servicesPounce'] ?? 'N/A'),
             /// _buildRow('Dealer ID', data['dealerID'] ?? 'N/A'),
              _buildRow('Specific Employee Mode', data['specifecEmployeeMode'].toString()),
              _buildSelectedServices(selectedServices: data['selectedServices'] ),

            ],
          ),
        ),
      ),
    );
  }


  /// this to show the regular row
  Widget _buildRow(String label, String value , {bool addSeparator = true , Widget widget = const SizedBox() , bool passWidgetAsValue = false  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              !passWidgetAsValue ?
              Expanded(
                flex: 3,
                child: Text(value),
              ) :

              Expanded(
                  flex:3 ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: 100,
                          child: widget),
                    ],
                  )),

            ],
          ),
        ),
        if (addSeparator)
          Divider(
            color: Colors.grey,
            thickness: 0.5,
            height: 0,
          ),
      ],
    );
  }


  /// this to show the same row as _buildRow but with button in the value
  Widget _buildRowWithButtom({required String label,bool addSeparator = true , required String buttonLabel , Color buttonColor = Colors.green,required VoidCallback onPress} ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Button2 (text: buttonLabel, onTap: onPress, color: buttonColor),
                    ],
                  ),
                ),
              )

            ],
          ),
          if (addSeparator)
            Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 0,
            ),
        ],
      ),
    );
  }




  Widget _buildPriceSummaryRow({required Map<String, dynamic> priceSummary , bool inRomanian = true}) {
    return
      staticVar.inRomanian ?
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow('Preț Total', priceSummary['totalPrice'].toString() + " RON", addSeparator: false),
        _buildRow('Discount', priceSummary['discount'].toString() + " %", addSeparator: false),
        _buildRow('După Discount', priceSummary['afterDiscount'].toString() + " RON", addSeparator: false),
        _buildRow('TVA', priceSummary['vat'].toString() + " RON", addSeparator: false),
        _buildRow('Total cu TVA', priceSummary['totalWithVat'].toString() + " RON", addSeparator: false),
        _buildRow('Avans', priceSummary['advancePayment'].toString() + " RON"),
      ],
    )  :
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow('Total Price', priceSummary['totalPrice'].toString() + " RON" , addSeparator: false),
        _buildRow('Discount', priceSummary['discount'].toString()+ " %", addSeparator: false),
        _buildRow('After Discount', priceSummary['afterDiscount'].toString()+ " RON", addSeparator: false),
        _buildRow('VAT', priceSummary['vat'].toString()+ " RON", addSeparator: false),
        _buildRow('Total with VAT', priceSummary['totalWithVat'].toString()+ " RON", addSeparator: false),
        _buildRow('Advance Payment', priceSummary['advancePayment'].toString()+ " RON"),

      ],
    );
  }

  Widget _buildSelectedServices({required List<dynamic> selectedServices , bool inRomanian = true}) {
    return
      staticVar.inRomanian ?
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: selectedServices.map<Widget>((service) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Nume Serviciu', service['serviceName'], addSeparator: false),
              _buildRow('Preț', service['price'].toString() + " RON", addSeparator: false),
              // _buildRow('Contract', service['isContract'].toString(), addSeparator: false),
              // _buildRow('Adăugat La', _formatDateTime(service['addedAt']), addSeparator: false),
            ],
          );
        }).toList(),
      ) :

      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedServices.map<Widget>((service) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Service Name', service['serviceName'] ,addSeparator: false),
            _buildRow('Price', service['price'].toString()+ " RON",addSeparator: false),
           // _buildRow('Is Contract', service['isContract'].toString(),addSeparator: false),
           // _buildRow('Added At', _formatDateTime(service['addedAt']),addSeparator: false),
          ],
        );
      }).toList(),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) {
      return 'N/A';
    } else {
      return staticVar.formatDateFromTimestampWithTime(dateTime);
    }
  }
}
