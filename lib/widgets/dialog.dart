import 'package:car_spa/widgets/staticVar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyDialog {
  static void showAlert(BuildContext context, String e , String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title' , style: TextStyle(fontSize: 18),),
       // content: Text('$e'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }



  static Widget _buildOrderInfo(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '$value'),
          ],
        ),
      ),
    );
  }

  static List<Widget> _buildSelectedServicesList(List<dynamic> services) {
    return services.map((service) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          '- ${service['serviceName']} (${service['price']} ${service['isContract'] ? '(Contract)' : ''})',
          style: TextStyle(color: Colors.white),
        ),
      );
    }).toList();
  }

  static String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  /// This function gonna show the order details
  static void showOrderDetailsPopup({required BuildContext context , required Map<String, dynamic> orderData } ) {
    staticVar.inRomanian ?
        /// show the details in romanian
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Detalii Comandă', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOrderInfo('Nume Client', orderData['clientName']),
              _buildOrderInfo('Email Client', orderData['clientEmail']),
              _buildOrderInfo('Telefon Client', orderData['clientPhone']),
              _buildOrderInfo('Model Mașină', orderData['carModel']),
              _buildOrderInfo('Nume Dealer', orderData['dealerName']),
              SizedBox(height: 10),
              Text(
                'Servicii Selectate:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSelectedServicesList(orderData['selectedServices']),
              ),
              SizedBox(height: 10),
              Text(
                'Detalii Comandă:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              _buildOrderInfo('CUI', orderData['cui']),
              // _buildOrderInfo('ID Angajat', orderData['empId']),
              _buildOrderInfo('Nume Angajat', orderData['empName']),
              //  _buildOrderInfo('Mod Specific Angajat', orderData['specifecEmployeeMode']),
              _buildOrderInfo('Data Emiterii', _formatTimestamp(orderData['issuedDate'])),
              _buildOrderInfo('Data Programării', _formatTimestamp(orderData["appointmentDate"])),
              _buildOrderInfo('Data Estimată de Finalizare', _formatTimestamp(orderData['expectedFinishingDate'])),
              _buildOrderInfo('Data Intrării', _formatTimestamp(orderData['entranceDate'])),
              _buildOrderInfo('Data Finalizării', _formatTimestamp(orderData['completionTimestamp'])),
              _buildOrderInfo('Data Acceptării de către Angajat', _formatTimestamp(orderData['empAcceptanceTimestamp'])),
              _buildOrderInfo('Status', orderData['status']),
              _buildOrderInfo('Status Plată', orderData['paymentStatus']),
              _buildOrderInfo('Metodă Plată', orderData['paymentMethod']),
              _buildOrderInfo('Preț Total', '${orderData['priceSummryDetails']['totalPrice']}'),
              _buildOrderInfo('Discount', '${orderData['priceSummryDetails']['discount']}%'),
              _buildOrderInfo('După Discount', '${orderData['priceSummryDetails']['afterDiscount']} RON'),
              _buildOrderInfo('TVA', '${orderData['priceSummryDetails']['vat']} RON'),
              _buildOrderInfo('Total cu TVA', '${orderData['priceSummryDetails']['totalWithVat']} RON'),
              _buildOrderInfo('Avans', '${orderData['priceSummryDetails']['advancePayment']} RON'),
              //_buildOrderInfo('URL Factură', orderData['billUrl']),
              // _buildOrderInfo('Imagine Înainte', orderData['imageBefore']),
              // _buildOrderInfo('Imagine După', orderData['imageAfter']),
              // _buildOrderInfo('ID Dealer', orderData['dealerID']),
              // _buildOrderInfo('Blocare', '${orderData['lock']}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Închide', style: TextStyle(color: Colors.teal)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
    ) :
        /// show the details in english
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text('Order Details', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOrderInfo('Client Name', orderData['clientName']),
                _buildOrderInfo('Client Email', orderData['clientEmail']),
                _buildOrderInfo('Client Phone', orderData['clientPhone']),
                _buildOrderInfo('Car Model', orderData['carModel']),
                _buildOrderInfo('Dealer Name', orderData['dealerName']),
                SizedBox(height: 10),
                Text(
                  'Selected Services:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildSelectedServicesList(orderData['selectedServices']),
                ),
                SizedBox(height: 10),
                Text(
                  'Order Details:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                _buildOrderInfo('CUI', orderData['cui']),
                // _buildOrderInfo('Employee ID', orderData['empId']),
                _buildOrderInfo('Employee Name', orderData['empName']),
                //  _buildOrderInfo('Specific Employee Mode', orderData['specifecEmployeeMode']),
                _buildOrderInfo('Issued Date', _formatTimestamp(orderData['issuedDate'])),
                _buildOrderInfo('Sechdual date', _formatTimestamp(orderData["appointmentDate"])),
                _buildOrderInfo('Expected Finishing Date', _formatTimestamp(orderData['expectedFinishingDate'])),
                _buildOrderInfo('Entrance Date', _formatTimestamp(orderData['entranceDate'])),
                _buildOrderInfo('Completion date', _formatTimestamp(orderData['completionTimestamp'])),
                _buildOrderInfo('Employee Acceptance Date', _formatTimestamp(orderData['empAcceptanceTimestamp'])),
                _buildOrderInfo('Status', orderData['status']),
                _buildOrderInfo('Payment Status', orderData['paymentStatus']),
                _buildOrderInfo('Payment Method', orderData['paymentMethod']),
                _buildOrderInfo('Total Price', '${orderData['priceSummryDetails']['totalPrice']}'),
                _buildOrderInfo('Discount', '${orderData['priceSummryDetails']['discount']}%'),
                _buildOrderInfo('After Discount', '${orderData['priceSummryDetails']['afterDiscount']} RON'),
                _buildOrderInfo('VAT', '${orderData['priceSummryDetails']['vat']} RON'),
                _buildOrderInfo('Total with VAT', '${orderData['priceSummryDetails']['totalWithVat']} RON'),
                _buildOrderInfo('Advance Payment', '${orderData['priceSummryDetails']['advancePayment']} RON'),
                //_buildOrderInfo('Bill URL', orderData['billUrl']),
                // _buildOrderInfo('Image Before', orderData['imageBefore']),
                // _buildOrderInfo('Image After', orderData['imageAfter']),
                // _buildOrderInfo('Dealer ID', orderData['dealerID']),

                // _buildOrderInfo('Lock', '${orderData['lock']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }





}