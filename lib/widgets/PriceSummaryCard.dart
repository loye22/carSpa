import 'package:flutter/material.dart';

// Assuming StaticVar includes your predefined styles and constants

class PriceSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> serviceList;
  final double discount;
  final DiscountType discountType;
  final void Function(Map<String, dynamic>) dataSummary;
  final double advancePayment  ;

  PriceSummaryCard({
    required this.serviceList,
    required this.discount,
    this.discountType = DiscountType.Percentage,
    required this.dataSummary,
    this.advancePayment = 0.0
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total price of services
    double totalPrice = serviceList.fold(0, (previous, service) => previous + (service['price'] ?? 0));

    double afterDiscount;

    // Apply discount to the total price
    if (discountType == DiscountType.Fixed) {
      afterDiscount = totalPrice - discount;
    } else {
      afterDiscount = totalPrice * (1 - discount / 100);
    }

    double vat = afterDiscount * 0.19; // Calculate VAT based on the discounted total
    double totalWithVat = afterDiscount + vat; // Calculate total with VAT

    // Call the callback function with the calculated values
    Map<String, dynamic> data = {
      "totalPrice": totalPrice.toStringAsFixed(2),
      "discountType": discountType.toString(),
      "discount": discount.toStringAsFixed(2),
      "afterDiscount": afterDiscount.toStringAsFixed(2),
      "vat": vat.toStringAsFixed(2),
      "totalWithVat": totalWithVat.toStringAsFixed(2),
      "advancePayment" : advancePayment ,


    };
    dataSummary(data);
    String currency = 'Ron';

    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // Adjust according to your needs
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Summary for Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This is the summary based on the provided service list and discount.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var service in serviceList) ...[
                      _buildRow(service['serviceName'], '${service['price'].toStringAsFixed(2)} $currency'),
                      SizedBox(height: 10),
                    ],
                    SizedBox(height: 10),
                    _buildRow2(
                      'Total Price',
                      '${totalPrice.toStringAsFixed(2)}$currency',
                    ),
                    SizedBox(height: 10),
                    _buildRow2(
                      'Discount',
                      this.discountType == DiscountType.Fixed
                          ? '- ${discount.toStringAsFixed(2)} $currency'
                          : '- %${discount.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 10),
                    _buildRow2('Price After Discount', '${afterDiscount.toStringAsFixed(2)}'),
                    SizedBox(height: 10),
                    _buildRow2('VAT (19%)', '${vat.toStringAsFixed(2)} $currency'),
                    SizedBox(height: 10),
                    _buildRow2('Total Price with VAT', '${totalWithVat.toStringAsFixed(2)} $currency' ),
          
          
                    // this part to hande the advance payment
                    if(this.advancePayment != 0 )
                    SizedBox(height: 10),
                    if(this.advancePayment != 0 )
                    _buildRow2('Advance payment', '${this.advancePayment.toStringAsFixed(2)} $currency' ),
                    if(this.advancePayment != 0 )
                    SizedBox(height: 10),
                    if(this.advancePayment != 0 )
                    _buildRow2('Remaining amount', '${(this.advancePayment - totalWithVat).toStringAsFixed(2)} $currency' ),
          
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRow2(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Example style
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Example style
          ),
        ),
      ],
    );
  }
}

enum DiscountType {
  Fixed,
  Percentage,
}
