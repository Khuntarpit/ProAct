import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase/supabase.dart';

class ResetPassword extends StatefulWidget {
  final SupabaseClient supabaseClient;
  final String email;
  const ResetPassword(
      {super.key, required this.supabaseClient, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _resetPasswordformKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white),
      child: Form(
          key: _resetPasswordformKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: 'Otp Token',
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Color(0xFFf1f5f9),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your otp token';
                  } else if (value.length != 6) {
                    return 'Otp token should be 6 digit code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Color(0xFFf1f5f9),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value != _confirmpasswordController.text) {
                    return 'Password doesn\'t match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _confirmpasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Color(0xFFf1f5f9),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value != _passwordController.text) {
                    return 'Confirm Password doesn\'t match';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_resetPasswordformKey.currentState!.validate()) {
                    final password = _passwordController.text.trim();
                    print("reset password");

                    BuildContext? progressContext = null;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          progressContext = context;
                          return Dialog(
                            child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                new CircularProgressIndicator(),
                                new Text("Resetting Password"),
                              ],
                            ),
                          );
                        });

                    // Perform login using Supabase
                    try {
                      final recovery = await widget.supabaseClient.auth
                          .verifyOTP(
                              email: widget.email,
                              token: _tokenController.text,
                              type: OtpType.recovery);
                      print(recovery);
                      final response = await widget.supabaseClient.auth
                          .updateUser(UserAttributes(password: password));

                      print(response);
                      if (response.user != null) {
                        await widget.supabaseClient.auth
                            .signOut(scope: SignOutScope.global);
                        Navigator.pop(progressContext!);
                        Navigator.pop(context);
                      } else {
                        print('Reset password failed');
                      }
                    } catch (error) {
                      Navigator.pop(progressContext!);
                    }
                  }
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity, 50)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF1A1A1A)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 55,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )),
    )));
  }
}
