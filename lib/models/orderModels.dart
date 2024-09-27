import 'package:car_spa/widgets/staticVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class orderModel {
  final String carModel;
  final String orderStatus;
  final String paymentStatus;
  final DateTime orderIssueDate;
  final DateTime orderSchedule;
  final String employeeWhoWashIt;
  final bool employeePaymentStatus;
  final String docId;

  orderModel(
      {required this.carModel,
      required this.orderStatus,
      required this.paymentStatus,
      required this.orderIssueDate,
      required this.orderSchedule,
      required this.employeeWhoWashIt,
      required this.employeePaymentStatus,
      required this.docId});
}

class ordersDataSource extends DataGridSource {
  ordersDataSource({required List<orderModel> orders}) {
    _getOrdersData = orders
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(
                columnName: 'carModel',
                value: e.carModel,
              ),
              DataGridCell<String>(
                columnName: 'paymentStatus',
                value: e.paymentStatus,
              ),
              DataGridCell<String>(
                columnName: 'orderStatus',
                value: e.orderStatus,
              ),
              DataGridCell<DateTime>(
                columnName: 'orderSchedule',
                value: e.orderSchedule,
              ),
              DataGridCell<DateTime>(
                columnName: 'orderIssueDate',
                value: e.orderIssueDate,
              ),
              DataGridCell<String>(
                columnName: 'employeeWhoWashIt',
                value: e.employeeWhoWashIt,
              ),
              DataGridCell<bool>(
                columnName: 'employeePaymentStatus',
                value: e.employeePaymentStatus,
              ),
              DataGridCell<String>(
                columnName: 'DBID',
                value: e.docId,
              ),
            ]))
        .toList();
  }

  List<DataGridRow> _getOrdersData = [];

  @override
  List<DataGridRow> get rows => _getOrdersData;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 16.0),
        child: dataGridCell.columnName == 'orderStatus'
            ? Center(
                child:
                    staticVar.getOrderStatusWidget(status2: dataGridCell.value))
            : (dataGridCell.columnName == 'paymentStatus'
                ? staticVar.getPaymentStatusWidget(status2: dataGridCell.value)
                : (dataGridCell.columnName == "employeePaymentStatus" ? staticVar.empPaymentStatus(status2: dataGridCell.value) : Text(dataGridCell.value.toString()))),
      );
    }).toList());
  }
}
