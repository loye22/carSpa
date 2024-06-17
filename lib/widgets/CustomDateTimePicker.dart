import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatefulWidget {
  final String label;
  final String hintText;
  final bool isHidden;
  final Function(DateTime) onChanged;
  final String subLabel;
  final DateTime initialValue;

  CustomDateTimePicker({
    required this.label,
    required this.hintText,
    this.isHidden = false,
    required this.onChanged,
    this.subLabel = "",
    DateTime? initialValue,
  }) : this.initialValue = initialValue ?? DateTime.now();

  @override
  _CustomDateTimePickerState createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late DateTime selectedDateTime;
  final DateFormat dateFormat = DateFormat('dd MMM yyyy : HH:mm');
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now().add(Duration(days: 1));
    _controller = TextEditingController(text: dateFormat.format(selectedDateTime));
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF1abc9c), // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Color(0xFF2c3e50), // Dialog background color
              onSurface: Colors.white, // Text color
            ),
            dialogBackgroundColor: Color(0xFF34495e),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Color(0xFF1abc9c), // Header background color
                onPrimary: Colors.white, // Header text color
                surface: Color(0xFF2c3e50), // Dialog background color
                onSurface: Colors.white, // Text color
              ),
              dialogBackgroundColor: Color(0xFF34495e),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _controller.text = dateFormat.format(selectedDateTime);
          widget.onChanged(selectedDateTime);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !widget.isHidden,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          if (widget.subLabel.isNotEmpty) SizedBox(height: 5),
          if (widget.subLabel.isNotEmpty) _buildSubLabel(),
          SizedBox(height: 5),
          _buildDateTimeField(context),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2c3e50), // Text color
      ), // Replace with your style
    );
  }

  Widget _buildSubLabel() {
    return Text(
      widget.subLabel,
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF1abc9c), // Color for sub-label text
      ), // Replace with your style
    );
  }

  Widget _buildDateTimeField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      child: TextFormField(
        readOnly: true,
        onTap: () => _selectDateTime(context),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Color(0xFF2c3e50)), // Hint text color
          fillColor: Colors.white, // Field background color
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Color(0xFF1abc9c), // Border color
            ),
          ),
        ),
        controller: _controller,
        style: TextStyle(color: Color(0xFF2c3e50)), // Text color
      ),
    );
  }
}
