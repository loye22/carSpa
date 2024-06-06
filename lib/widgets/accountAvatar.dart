import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class customAccountWidget extends StatefulWidget {
  @override
  _customAccountWidgetState createState() => _customAccountWidgetState();
}

class _customAccountWidgetState extends State<customAccountWidget> {
  bool isMenuOpen = false;
  bool isLoading = false;
  String? currentUserEmail;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentUserEmail();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(Icons.account_circle),
            SizedBox(width: 8.0),
            Text(this.currentUserEmail ?? "Error"),
            if (isMenuOpen) ...[
              // Additional widgets when the menu is open
              SizedBox(width: 8.0),
              InkWell(
                onTap: () async {
                  // Handle logout action
                  await FirebaseAuth.instance.signOut();
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red, // Customize the color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Future<void> _getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email;
      });
    }
  }
}