import 'package:car_spa/pages/loginPage.dart';
import 'package:car_spa/pages/rootPage.dart';
import 'package:car_spa/widgets/calender.dart';
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
      title: "Car SPA",
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      // ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.blue,
      //     brightness: Brightness.dark,
      //   ),
      // ),




      debugShowCheckedModeBanner: false,
      //theme: ThemeData(fontFamily: 'louie' , focusColor: Color.fromRGBO(20, 53, 96,1  )),
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