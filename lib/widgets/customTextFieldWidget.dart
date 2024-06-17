import 'package:car_spa/widgets/inputFormat.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class customTextFieldWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isHidden;
  final Function(String) onChanged;
  final String subLabel;
  final bool isItNumerical;

  final bool editMode;
  final String initialValue;
  final bool isItphoneNr;

  final String suffex;

  final bool dealerMode;

  final String dealerData;
  final bool isItDiscount;
  final int limit;

  customTextFieldWidget(
      {required this.label,
      required this.hintText,
      this.isHidden = false,
      required this.onChanged,
      this.subLabel = "",
      this.isItNumerical = false,
      this.editMode = false,
      this.initialValue = "",
      this.isItphoneNr = false,
      this.suffex = "",
      this.dealerMode = false,
      this.dealerData = "",
      this.isItDiscount = false,
      this.limit = 0});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isHidden,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: staticVar.subtitleStyle1, // Replace with your style
          ),
          this.subLabel == ""
              ? SizedBox.shrink()
              : SizedBox(
                  height: 5,
                ),
          this.subLabel == ""
              ? SizedBox.shrink()
              : Text(
                  subLabel,
                  style: staticVar.subtitleStyle2, // Replace with your style
                ),
          SizedBox(
            height: 5,
          ),
          this.dealerMode
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 60,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          this.dealerData,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    initialValue: editMode ? initialValue : null,
                    keyboardType: this.isItNumerical
                        ? TextInputType.numberWithOptions(decimal: true)
                        : null,
                    inputFormatters: this.isItDiscount
                        ? [
                            LengthLimitingTextInputFormatter(3),
                            LimitRangeTextInputFormatter(0, 100),
                          ]
                        : (this.isItDiscount
                            ? [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3)
                              ]
                            : (this.isItNumerical
                                ? [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'))
                                  ]
                                : null)),
                    onChanged: onChanged,
                    maxLength: this.limit != 0
                        ? this.limit
                        : (this.isItDiscount
                            ? 3
                            : (this.isItphoneNr
                                ? 10
                                : (this.isItNumerical ? 15 : null))),
                    decoration: InputDecoration(
                      suffix: Text(this.suffex),
                      prefixText: label == "Phone Nr" ? "+" : null,
                      hintText: hintText,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
