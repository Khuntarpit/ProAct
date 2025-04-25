import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/controller/auth_controller.dart';
import 'package:proact/routes/routes.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resetPasswordformKey = GlobalKey<FormState>();
  AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(fontSize: 14,),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0).add(
          EdgeInsets.only(top: 120.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Please enter an email address and password to Log In to your account.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Color(0xFFf1f5f9),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14,),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Color(0xFFf1f5f9),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14,),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("Reset Password"),
                                titleTextStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF1A1A1A)),
                                buttonPadding: EdgeInsets.all(25),
                                actions: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (_resetPasswordformKey.currentState!.validate()) {
                                        controller.resetPasswordSend();
                                      }
                                    },
                                    child: Text(
                                      "Send Token",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                                content: Container(
                                  decoration:
                                  BoxDecoration(color: Colors.white),
                                  child: Form(
                                      key: _resetPasswordformKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: controller.emailController,
                                            decoration: InputDecoration(
                                              labelText: 'Email Address',
                                              hintStyle:
                                              TextStyle(color: Colors.grey),
                                              fillColor: Color(0xFFf1f5f9),
                                              filled: true,
                                              contentPadding:
                                              EdgeInsets.symmetric(
                                                  vertical: 16.0,
                                                  horizontal: 12.0),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            style: GoogleFonts.poppins(fontSize: 14,),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your email address';
                                              }
                                              if (!RegExp(
                                                  r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$')
                                                  .hasMatch(value)) {
                                                return 'Please enter a valid email address';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      )),
                                ),
                              );
                            });
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: 3, // Space between underline and text
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF1A1A1A),
                                  width: 1.0, // Underline thickness
                                ))),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      )),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        controller.login();
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all<Size>(
                          Size(double.infinity, 50)),
                      backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF1A1A1A)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 55,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.signupScreen);
              },
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: "Don't have an account? ",
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
