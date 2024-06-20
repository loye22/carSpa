import 'package:car_spa/widgets/staticVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

/// This widget is gonna take list of orders and filter them based on date range
/// and it will return the filted list with date range ,
/// you can access it using the onDateRangeChanged() function

class dateCalnderPickUp extends StatefulWidget {
  final List<Map<String, dynamic>> ordersfromFirebase;

  final Function(
          DateRange dateRange, List<Map<String, dynamic>> filterdList)
      onDateRangeChanged;

  const dateCalnderPickUp({
    super.key,
    required this.ordersfromFirebase,
    required this.onDateRangeChanged,
  });

  @override
  State<dateCalnderPickUp> createState() => _dateCalnderPickUpState();
}

class _dateCalnderPickUpState extends State<dateCalnderPickUp> {
  DateTime? startDateRangeFilter = null;

  DateTime? endDateRangeFilter = null;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: "Filtrează după interval de date",
        child: IconButton(
          onPressed: showCalender,
          icon: Icon(
            Icons.calendar_month_sharp,
            size: 40,
          ),
          color: Color(0xFF1abc9c),
        ));
  }

  /// this function gonna handel filter by date range event
  void showCalender() async {
    await showDateRangePickerDialog(
        offset: Offset(staticVar.fullWidth(context) * .35,
            staticVar.fullhigth(context) * .12),
        context: context,
        builder: datePickerBuilder);
  }

  Widget datePickerBuilder(BuildContext context,
          dynamic Function(DateRange) onDateRangeChanged) =>
      Animate(
        effects: [FadeEffect()],
        child: DateRangePickerWidget(
          theme: CalendarTheme(
            selectedColor: Color(0xFF1abc9c),
            // Color for selected dates
            inRangeColor: Color(0xFF2c3e50),
            // Color for dates within range
            inRangeTextStyle: TextStyle(color: Colors.white),
            // Text style for dates within range
            selectedTextStyle: TextStyle(color: Colors.white),
            // Text style for selected dates
            todayTextStyle: TextStyle(color: Colors.black),
            // Text style for today's date
            defaultTextStyle: TextStyle(color: Colors.black),
            // Default text style for other dates
            disabledTextStyle: TextStyle(color: Colors.grey),
            // Text style for disabled dates
            radius: 50,
            // Radius of each calendar tile
            tileSize: 50, // Size of each calendar tile
          ),
          doubleMonth: true,
          initialDateRange: DateRange(DateTime.now(), DateTime(2030)),
          onDateRangeChanged: (selctedDateRange) {
            this.startDateRangeFilter = selctedDateRange?.start;
            this.endDateRangeFilter = selctedDateRange?.end;
            if (this.startDateRangeFilter == null ||
                this.endDateRangeFilter == null)
              throw Exception("Error while selecting the date range");

            ///
            List<Map<String, dynamic>> results = filterByDateRange(
                orders: widget.ordersfromFirebase,
                startDate: this.startDateRangeFilter ?? DateTime(3000),
                endDate: this.endDateRangeFilter ?? DateTime(3000));

            final defults = DateRange(DateTime.now().add(Duration(days: 5000)),
                DateTime.now().add(Duration(days: 10000)));
            widget.onDateRangeChanged(selctedDateRange ?? defults, results);
          },
          height: staticVar.fullhigth(context) * .45,
        ),
      );

  /// this function gonna handel the filter by date range
  List<Map<String, dynamic>> filterByDateRange(
      {required List<Map<String, dynamic>> orders,
      required DateTime startDate,
      required DateTime endDate}) {
    return orders.where((order) {
      DateTime appointmentDate = order['issuedDate'].toDate();
      bool isWithinDateRange = appointmentDate.isAfter(startDate) &&
          appointmentDate.isBefore(endDate.add(Duration(days: 1)));

      return isWithinDateRange;
    }).toList();
  }
}
