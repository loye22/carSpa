import 'package:car_spa/widgets/button.dart';
import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/staticVar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class loginPage extends StatefulWidget {
  static const routeName = '/loginPage';
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailControllerRecovery = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false ;
  bool isLoadingRecovery = false ;
  bool forget = false ;



  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double spacer = 20;
    return Scaffold(
      backgroundColor:Color.fromRGBO(242, 247, 252, 1.0), // Color.fromRGBO(242, 247, 252, 1),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/wall2.jpeg"), fit: BoxFit.cover),
            ),
          ),
          Animate(
            effects: [FadeEffect(duration: Duration(milliseconds: 900))],
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                 // Image.asset("assets/logo.png"),
                  SizedBox(
                    height: spacer,
                  ), //Namdhinggo
                  Text(
                    "Login",
                    style: TextStyle( fontSize:  32 , fontWeight: FontWeight.w400 , color: Colors.black),
                  ),
                  SizedBox(
                    height: spacer,
                  ),
                  Container(
                    width: size.width * 0.4,
                    height: size.height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color:Colors.black.withOpacity(0.5),
                      //color: Color.fromRGBO(232, 240, 254, 1.0), // Background color
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child:Form(
                        key: _formKey,
                        child:forget == false ?
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Username',
                                  fillColor: Colors.white, // Text input background color
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0), // Spacer
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                obscureText: true, // Password field with hidden text
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  fillColor: Colors.white, // Text input background color
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0), // Spacer
                              this.isLoading ? staticVar.loading(size: MediaQuery.of(context).size.width * .05):
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, perform login logic here
                                    // For now, you can print a message
                                    await  _login();
                                  }
                                },
                                child: Container(
                                  width: 90,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:Colors.black, //Color.fromRGBO(33, 103, 199, 1) ,
                                    borderRadius: BorderRadius.circular(30) ,
                                  ),
                                  child: Center(child: Text("Login" , style: TextStyle(color: Colors.white),)),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextButton(onPressed: (){
                                forget = true ;
                                setState(() {});
                              }, child: Text("Forgot your password?" , style: TextStyle(color: Colors.white),))

                            ],
                          ),
                        ):
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          //  crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _emailControllerRecovery,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email to recover your account';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'enter your email to recover your account',
                                fillColor: Colors.white, // Text input background color
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.0), // Spacer
                            this.isLoadingRecovery ? staticVar.loading(size: MediaQuery.of(context).size.width * .1) :
                            Button(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _resetPassword();
                                }
                              },
                              text: "Recover",

                            ),
                            Button(onTap: (){
                              this.forget = false;
                              setState(() {});
                            },text: "Login in",)


                          ],
                        ),
                      ),
                    ),

                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
  // Function to handle login using Firebase
  Future<void> _login() async {
    try {
      this.isLoading = true ;
      setState(() {});
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );



      // Login successful, you can now access user information using userCredential.user
      print('Login successful: ${userCredential.user!.uid}');
      this.isLoading = false  ;
      setState(() {});
    } catch (e) {
      this.isLoading = false  ;
      setState(() {});
      // Handle login errors
      print('Login failed: $e');
      // You can show an error message to the user
      MyDialog.showAlert(context, "Ok", "Login Failed");

    }
  }

  // email reset funciton
  Future<void> _resetPassword() async {
    try {
      this.isLoadingRecovery = true;
      setState(() {});
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailControllerRecovery.text,
      );

      // Password reset email sent successfully
      //  print('Password reset email sent to ${_emailController.text}');
      MyDialog.showAlert(context, "Ok", 'Password reset email sent successfully. Check your email inbox.');
      this.isLoadingRecovery = false;
      setState(() {});

    } catch (e) {
      // Handle password reset errors
      print('Password reset failed: $e');
      // You can show an error message to the user
      this.isLoadingRecovery = false;
      setState(() {});
      MyDialog.showAlert(context, "Ok", 'Password reset failed: $e');
    }
  }

}
