


import 'package:car_spa/widgets/staticVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmployeeNameCard extends StatelessWidget {
  final String name;

  const EmployeeNameCard({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [SlideEffect()],
      child: Container(
        height: 100,
        width: 300,
        child: Card(
          color: Color(0xFF1ABC9C),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(child: Text(this.name , style: TextStyle(color: Colors.white , fontSize: 30),)),
        ),
      ),
    );
  }
}