import 'package:car_spa/pages/loginPage.dart';
import 'package:car_spa/pages/rootPage.dart';
import 'package:car_spa/widgets/calender.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:car_spa/widgets/testScedualcondfigration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
        apiKey: "AIzaSyDOi19OiifbhMNSOgr45CcLho4qyep2t9E",
        authDomain: "carspa-e80e1.firebaseapp.com",
        projectId: "carspa-e80e1",
        storageBucket: "carspa-e80e1.appspot.com",
        messagingSenderId: "325079862697",
        appId: "1:325079862697:web:07451de59ff8e34b9108b8",
        measurementId: "G-DW4JR1BS91"
    ),
  );
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(

      theme: ThemeData(
        //scaffoldBackgroundColor: Color(0xFF2c3e50), // Sidebar background color
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Color(0xFF2C3E50)), // Text color for body
          bodyText2: TextStyle(color: Color(0xFF2C3E50)), // Text color for body
          // You can define additional text styles here as needed
        ),
      ),
      title: "Car SPA",
       debugShowCheckedModeBanner: true ,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot)  {
          if (snapshot.hasData) {
            return rootPage();
          } else {
            return loginPage();
          }
        },
      ),
      routes: {
        rootPage.routeName: (ctx) => rootPage(),
        loginPage.routeName: (ctx) => loginPage(),





      },
    );


  }
}