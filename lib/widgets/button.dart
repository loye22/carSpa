import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  Color color;

  Button({Key? key, required this.onTap, required this.text, this.color =const  Color(0xFF461378)})
      : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}




class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: widget.onTap, // Fix the variable name here
        child: Container(
          width: 90,
          height: 50,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(child: Text(widget.text, style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
