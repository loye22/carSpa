import 'package:flutter/material.dart';

class filterFeedBack extends StatelessWidget {
  final String filterName;

  const filterFeedBack({Key? key, required this.filterName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        filterName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
