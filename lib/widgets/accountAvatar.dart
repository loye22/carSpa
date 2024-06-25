import 'package:car_spa/widgets/staticVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAccountWidget extends StatefulWidget {
  @override
  _CustomAccountWidgetState createState() => _CustomAccountWidgetState();
}

class _CustomAccountWidgetState extends State<CustomAccountWidget> {
  String? currentUserEmail;



  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              // Handle log out action\
              await FirebaseAuth.instance.signOut();

              print('Logged out');
            },
            child: Text('Log Out'),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('English'),
              Switch(
                value: staticVar.inRomanian,
                onChanged: (value) {
                  setState(() {

                    staticVar.inRomanian = value;
                    setState(() {});
                  });

                },
              ),
              Text('Romanian'),
            ],
          ),
        ],
      )
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
