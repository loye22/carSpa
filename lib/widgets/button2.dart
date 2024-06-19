import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button2 extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  final double size; // Added size parameter

  Button2({
    Key? key,
    required this.onTap,
    required this.text,
    this.color = Colors.black,
    this.size = 100.0, // Default size is 90
  }) : super(key: key);

  @override
  State<Button2> createState() => _Button2State();
}

class _Button2State extends State<Button2> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
       // padding: EdgeInsets.all(8),
        width: widget.size, // Use size parameter for width
        height: 40, // Fixed height
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
