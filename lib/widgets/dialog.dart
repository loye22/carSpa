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

  static void showOrderDetailsPopup({required BuildContext context , required Map<String, dynamic> orderData} ) {
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
                _buildOrderInfo('***Sechdual date', _formatTimestamp(orderData["appointmentDate"])),
                _buildOrderInfo('Expected Finishing Date', _formatTimestamp(orderData['expectedFinishingDate'])),
                _buildOrderInfo('Entrance Date', _formatTimestamp(orderData['entranceDate'])),
                _buildOrderInfo('Completion date', _formatTimestamp(orderData['completionTimestamp'])),
                _buildOrderInfo('Employee Acceptance Date', _formatTimestamp(orderData['empAcceptanceTimestamp'])),
                _buildOrderInfo('Status', orderData['status']),
                _buildOrderInfo('Payment Status', orderData['paymentStatus']),
                _buildOrderInfo('Payment Method', orderData['paymentMethod']),
                _buildOrderInfo('Discount', '${orderData['priceSummryDetails']['discount']}%'),
                _buildOrderInfo('Total Price', '${orderData['priceSummryDetails']['totalPrice']}'),
                _buildOrderInfo('Total with VAT', '${orderData['priceSummryDetails']['totalWithVat']}'),
                _buildOrderInfo('Advance Payment', '${orderData['priceSummryDetails']['advancePayment']}'),
                _buildOrderInfo('VAT', '${orderData['priceSummryDetails']['vat']}'),
                _buildOrderInfo('Bill URL', orderData['billUrl']),
                // _buildOrderInfo('Image Before', orderData['imageBefore']),
                // _buildOrderInfo('Image After', orderData['imageAfter']),
                // _buildOrderInfo('Dealer ID', orderData['dealerID']),
                _buildOrderInfo('Dealer Name', orderData['dealerName']),
                // _buildOrderInfo('Lock', '${orderData['lock']}'),
                _buildOrderInfo('Advanced Payment', '${orderData['advancedPayment']}'),
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