import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/blockapps/screens/home.dart';
import 'package:proact/blockapps/services/init.dart';
import 'package:proact/event_calender_new.dart';
import 'package:proact/network/network_api_services.dart';
import 'package:proact/notification_service.dart';
import 'package:proact/reset_password.dart';
import 'package:proact/time_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

NotificationService _notifyService = NotificationService();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qtljgttwigasqvkzeqxf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0bGpndHR3aWdhc3F2a3plcXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk5OTQ1NzUsImV4cCI6MjAzNTU3MDU3NX0.hcbOVDajJSmn7EdisH2eBeLpxOww3sSG7PVxoEsOdeU',
  );

  // Initialize Gemini
  // Gemini.init(
  //   apiKey: 'AIzaSyDHtx8QtdqWHUpNEd8J_nogM3tjjj5NSEA',
  // );

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  _notifyService.initialiseNotifications();

  final supabaseClient = Supabase.instance.client;
  runApp(ProAct(supabaseClient: supabaseClient));
}

class ProAct extends StatelessWidget {
  final SupabaseClient supabaseClient;

  ProAct({required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProAct',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            Color(0xFF1A1A1A), // Set background color to hex #1a1a1a
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: checkAuthStatus(), // Check authentication status
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                } else {
                  if (snapshot.data == true) {
                    return MyHomePage(
                        title:
                            'Flutter App Home Page'); // User is logged in, show home page
                  } else {
                    return IntroScreen(
                        supabaseClient:
                            supabaseClient); // User not logged in, show intro screen
                  }
                }
              },
            ),
        '/home': (context) => MyHomePage(title: 'Flutter App Home Page'),
        // '/calendar': (context) => EventCalender()
        '/calendar': (context) => EventCalenderNew(eventData: []),
      },
    );
  }

  Future<bool> checkAuthStatus() async {
    final user = supabaseClient.auth.currentUser;
    return user !=
        null; // Return true if user is authenticated, false otherwise
  }
}

class IntroScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;

  IntroScreen({required this.supabaseClient});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate(); // Check authentication status when screen initializes
  }

  Future<void> checkAuthAndNavigate() async {
    final user = widget.supabaseClient.auth.currentUser;
    if (user != null) {
      // User is already authenticated, navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Flutter App Home Page')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.centerLeft, // Align to the center left
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              35.0, 100.0, 35.0, 0), // Adjust position with padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              Text(
                "Let's Get",
                style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                // Use Poppins font and set color to white
              ),
              Text(
                'Started',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold, // Set fontWeight to bold
                  color:
                      Colors.white, // Use Poppins font and set color to white
                ),
              ),
              Text(
                'Fight Procrastination With Ease',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors
                        .white), // Use Poppins font and set color to white
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity, // Full width button
                padding: EdgeInsets.symmetric(
                    vertical: 7.5), // Smaller vertical padding
                margin: EdgeInsets.only(bottom: 16.0), // Margin between buttons
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  color: Colors.white, // Background color of the button
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreen(
                              supabaseClient: widget
                                  .supabaseClient)), // Navigate to LoginScreen
                    );
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 0)), // Smaller height
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .transparent), // Transparent background for ElevatedButton
                    shadowColor: MaterialStateProperty.all<Color>(
                        Colors.transparent), // Transparent shadow
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color(
                            0xFF1A1A1A), // Set button text color to #1a1a1a
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity, // Full width button
                padding: EdgeInsets.symmetric(
                    vertical: 7.5), // Smaller vertical padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  color: Color(0xFF1A1A1A), // Dark background color
                  border: Border.all(
                      color: Colors.white, width: 2.0), // White border
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpScreen(
                              supabaseClient: widget
                                  .supabaseClient)), // Navigate to SignUpScreen
                    );
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 0)), // Smaller height
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .transparent), // Transparent background for ElevatedButton
                    shadowColor: MaterialStateProperty.all<Color>(
                        Colors.transparent), // Transparent shadow
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white, // White text color
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;

  SignUpScreen({required this.supabaseClient});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context); // Navigate back to previous screen
        //   },
        // ),
        title: Text(
          '',
          style: GoogleFonts.poppins(), // Poppins font for app bar title
        ),
        backgroundColor: Colors.white, // Set app bar background color to white
      ),
      backgroundColor: Colors.white, // Set scaffold background color to white
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0).add(
          EdgeInsets.only(top: 120.0), // Add 120px padding only at the top
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Please enter an email address and password to create your account.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
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
                    style: GoogleFonts.poppins(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
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
                    style: GoogleFonts.poppins(),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        await widget.supabaseClient.auth
                            .signUp(email: email, password: password);
                        Navigator.pop(
                            context); // Navigate back on successful sign up
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(double.infinity, 50)), // Full width button
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xFF1A1A1A)), // Black background color
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Rounded corners
                        ),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 55, // Set a fixed height for consistency
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white, // White text color
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back to LoginScreen
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                          ),
                          TextSpan(
                            text: 'Log In',
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
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;

  LoginScreen({required this.supabaseClient});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resetPasswordformKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void storeUserEmailLocally(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '',
          style: GoogleFonts.poppins(),
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
                    controller: _emailController,
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
                    style: GoogleFonts.poppins(),
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
                    controller: _passwordController,
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
                    style: GoogleFonts.poppins(),
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
                        // widget.supabaseClient.auth.resetPasswordForEmail(email);
                        // widget.supabaseClient.auth.updateUser(UserAttributes());

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
                                      if (_resetPasswordformKey.currentState!
                                          .validate()) {
                                        Navigator.pop(context);
                                        BuildContext? progressContext = null;
                                        final email =
                                            _emailController.text.trim();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              progressContext = context;
                                              return Dialog(
                                                child: new Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    new CircularProgressIndicator(),
                                                    new Text(
                                                        "Check your email for token"),
                                                  ],
                                                ),
                                              );
                                            });

                                        widget.supabaseClient.auth
                                            .resetPasswordForEmail(email)
                                            // .resetPasswordForEmail(email)
                                            .then((value) {
                                          // print("value ");
                                          if (progressContext != null) {
                                            Navigator.pop(progressContext!);
                                            Navigator.push(
                                                progressContext!,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ResetPassword(
                                                          supabaseClient: widget
                                                              .supabaseClient,
                                                          email: email,
                                                        )));
                                          }
                                        }).catchError((error) {
                                          print("error");
                                        });
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
                                            controller: _emailController,
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
                                            style: GoogleFonts.poppins(),
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
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        // Perform login using Supabase

                        final response =
                            await widget.supabaseClient.auth.signInWithPassword(
                          email: email,
                          password: password,
                        );

                        if (response.user != null) {
                          // Successful login
                          storeUserEmailLocally(email); // Store email locally
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(title: 'Flutter App Home Page'),
                            ),
                          );
                        } else {
                          // Handle unsuccessful login if needed
                          print('Login failed');
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SignUpScreen(supabaseClient: widget.supabaseClient),
                  ),
                );
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userEmail = '';
  String emailPrefix = '';
  List<Map<String, String>> eventData = [];

  void showGeminiPrompt(int eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height / 2,
          child: GeminiPrompt(
            onSubmit: (data) {
              setState(() {
                eventData.addAll(data);
              });
              saveEventData(); // Save eventData after adding new tasks
            },
            eventId: eventId,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUserEmail();
    loadEventData(); // Load stored eventData when the widget initializes
    resetEventDataIfNeeded(); // Reset eventData if it's a new day
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? '';
      emailPrefix = userEmail.split('@').first;
    });
  }

  void resetEventDataIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime? lastRefreshDate =
        DateTime.tryParse(prefs.getString('lastRefreshDate') ?? '');
    DateTime currentDate = DateTime.now();
    if (lastRefreshDate == null || lastRefreshDate.day != currentDate.day) {
      // Reset eventData if it's a new day
      setState(() {
        eventData.clear();
      });
      await prefs.setString('lastRefreshDate', currentDate.toString());
      saveEventData(); // Save empty eventData to clear storage
    }
  }

  void saveEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("saving event data ${eventData}");
    String eventData_json = jsonEncode(eventData);
    await prefs.setString('eventData', eventData_json);
    await Get.find<MethodChannelController>().saveEvents(eventData_json);
  }

  void loadEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventDataJson = prefs.getString('eventData') ?? '[]';
    setState(() {
      eventData = List<Map<String, String>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );
    });
  }

  void deleteEvent(int index) async {
    setState(() {
      eventData.removeAt(index); // Remove event from eventData list
    });
    saveEventData(); // Save updated eventData to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HomeScreen(
          showGeminiPrompt: showGeminiPrompt,
          emailPrefix: emailPrefix,
          eventData: eventData,
          deleteEvent: deleteEvent,
          saveEventData: saveEventData, // Pass deleteEvent function
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Container(
          margin: EdgeInsets.only(
            bottom: 30.0,
          ),
          child: FloatingActionButton(
            onPressed: () {
              showGeminiPrompt(-1);
            },
            backgroundColor: Color(0xFF1a1a1a),
            child: Icon(Icons.chat, color: Colors.white),
          ),
        ));
  }
}

class HomeScreen extends StatefulWidget {
  String emailPrefix;
  final List<Map<String, String>> eventData;
  final Function(int) deleteEvent;
  final Function() saveEventData;
  final Function(int) showGeminiPrompt;

  HomeScreen(
      {required this.emailPrefix,
      required this.eventData,
      required this.deleteEvent,
      required this.saveEventData,
      required this.showGeminiPrompt});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool editUserName = false;
  final TextEditingController uNameController = TextEditingController();
  late AnimationController progreesController;

  @override
  void initState() {
    progreesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  showBlockAppDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.fromLTRB(25, 30, 25, 30),
              child: BlockedHomePage());
        });
  }

  getTaskDoneStatus() {
    if (widget.eventData.length > 0) {
      print("object");
      int totalTasks = widget.eventData.length;
      int doneTasks = 0;
      for (var i = 0; i < widget.eventData.length; i++) {
        if (widget.eventData[i]['doneStatus'] == 'true') {
          doneTasks++;
        }
      }
      double value = doneTasks / totalTasks;
      if (totalTasks == 0)
        progreesController.value = 0;
      else
        progreesController.value = doneTasks / totalTasks;
      print(
          'task progress ${widget.eventData} done tasks, ${doneTasks} total tasks ${totalTasks}');

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            height: 22,
            padding: EdgeInsets.all(3),
            width: 200,
            child: LinearProgressIndicator(
              semanticsValue: "Task Progress",
              semanticsLabel: "Task Progress",
              borderRadius: BorderRadius.all(Radius.circular(15)),
              // backgroundColor: Colors.blue,
              color: Color(0xFF1A1A1A),
              backgroundColor: Colors.white,

              value: progreesController.value,
            ),
          ),
          Text(
            "${(progreesController.value * 100).toInt()}%",
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    int pendingTasks = widget.eventData.length; // Number of event cards/tasks
    String weekStatus = pendingTasks < 4
        ? 'You Have a Pretty Light Day'
        : 'You Have a Pretty Busy Day';

    return Scaffold(
      appBar: AppBar(
          leading: null, backgroundColor: Colors.transparent, actions: null),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  editUserName
                      ? getEditNameView(widget.emailPrefix)
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              editUserName = true;
                            });
                          },
                          child: Text(
                            'Hi, ${widget.emailPrefix}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                  // SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      if (Platform.isAndroid) {
                        showBlockAppDialog();
                      }
                    },
                    child: Padding(
                        padding: EdgeInsets.all(20), child: Icon(Icons.lock)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekStatus,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('$pendingTasks tasks',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(width: 20),
                        //Progressbar
                        getTaskDoneStatus()
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'List Of Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: widget.eventData.length,
                itemBuilder: (context, index) {
                  return EventCard(
                      event: widget.eventData[index],
                      showGeminiPrompt: () {
                        widget.showGeminiPrompt(index);
                      },
                      onDelete: () {
                        widget
                            .deleteEvent(index); // Call deleteEvent with index
                        _notifyService.cancelEventNotification(index);
                      },
                      markAsDone: (value) {
                        var event = widget.eventData[index];
                        setState(() {
                          if (value!) {
                            event['doneStatus'] = 'true';
                          } else {
                            event['doneStatus'] = 'false';
                          }
                        });
                        widget.saveEventData();
                      },
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            var event = widget.eventData[index];
                            final TextEditingController taskNameController =
                                TextEditingController();
                            final TextEditingController txtStartTimeController =
                                TextEditingController();
                            final TextEditingController txtEndTimeController =
                                TextEditingController();
                            taskNameController.text = event["name"]!;
                            txtStartTimeController.text = event["startTime"]!;
                            txtEndTimeController.text = event["endTime"]!;

                            print("edit event ${event}");
                            return AlertDialog(
                              title: Text("Edit Task"),
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
                                    setState(() {
                                      event["name"] = taskNameController.text;
                                      event["startTime"] =
                                          txtStartTimeController.text;
                                      event["endTime"] =
                                          txtEndTimeController.text;
                                      event["currenttimeinmillis"] =
                                          '${DateTime.now().millisecondsSinceEpoch}';
                                    });
                                    widget.saveEventData();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Save Task",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Task Name",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextField(
                                    maxLines: null,
                                    controller: taskNameController,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                        hintText: "Task Name"),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Start Time",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        List startTime =
                                            event["startTime"]!.split(":");
                                        int startHour = int.parse(startTime[0]);
                                        int startMin = int.parse(startTime[1]);
                                        TimeOfDay? timePicked =
                                            await showTimePicker(
                                                context: context,
                                                initialEntryMode:
                                                    TimePickerEntryMode.dial,
                                                initialTime: TimeOfDay(
                                                    hour: startHour,
                                                    minute: startMin),
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context)
                                                        .copyWith(
                                                            alwaysUse24HourFormat:
                                                                true),
                                                    child: child!,
                                                  );
                                                });
                                        if (timePicked != null) {
                                          String pickedHour =
                                              timePicked.hour > 9
                                                  ? "${timePicked.hour}"
                                                  : "0${timePicked.hour}";
                                          String pickedMin =
                                              timePicked.minute > 9
                                                  ? "${timePicked.minute}"
                                                  : "0${timePicked.minute}";
                                          setState(() {
                                            event["startTime"] =
                                                "${pickedHour}:${pickedMin}";
                                            txtStartTimeController.text =
                                                "${pickedHour}:${pickedMin}";
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.punch_clock)),
                                  // Text("HI ${txtStartTimeController.text}"),
                                  TextField(
                                    readOnly: true,
                                    controller: txtStartTimeController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "End Time",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  IconButton(
                                      onPressed: () async {
                                        List endTime =
                                            event["endTime"]!.split(":");
                                        int endHour = int.parse(endTime[0]);
                                        int endMin = int.parse(endTime[1]);
                                        TimeOfDay? timePicked =
                                            await showTimePicker(
                                                context: context,
                                                initialEntryMode:
                                                    TimePickerEntryMode.dial,
                                                initialTime: TimeOfDay(
                                                    hour: endHour,
                                                    minute: endMin),
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context)
                                                        .copyWith(
                                                            alwaysUse24HourFormat:
                                                                true),
                                                    child: child!,
                                                  );
                                                });
                                        if (timePicked != null) {
                                           String pickedHour =
                                              timePicked.hour > 9
                                                  ? "${timePicked.hour}"
                                                  : "0${timePicked.hour}";
                                          String pickedMin =
                                              timePicked.minute > 9
                                                  ? "${timePicked.minute}"
                                                  : "0${timePicked.minute}";
                                          setState(() {
                                            event["endTime"] =
                                                "${pickedHour}:${pickedMin}";
                                            txtEndTimeController.text =
                                                "${pickedHour}:${pickedMin}";
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.punch_clock)),
                                  // Text("HI ${txtStartTimeController.text}"),

                                  TextField(
                                    readOnly: true,
                                    controller: txtEndTimeController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 24),
            label: '',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigator.pushNamed(context, '/home');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyHomePage(title: 'Flutter App Home Page'),
                ),

                // EventCalender(eventData: widget.eventData))
                // builder: (context) => CalendarPage(eventData: widget.eventData)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventCalenderNew(
                            eventData: widget.eventData,
                          ))
                  // EventCalender(eventData: widget.eventData))
                  // builder: (context) => CalendarPage(eventData: widget.eventData)),
                  );
              break;
          }
        },
      ),
    );
  }

  getEditNameView(String username) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Expanded(
          child: TextField(
        controller: uNameController,
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
            hintStyle: TextStyle(
                color: Colors.black26,
                fontSize: 20,
                fontWeight: FontWeight.w400),
            hintText: "Enter Username"),
      )),
      Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: IconButton(
              onPressed: () {
                setState(() {
                  editUserName = false;
                });
              },
              icon: Icon(
                color: Color.fromARGB(255, 26, 26, 26),
                Icons.close,
                size: 30,
              ))),
      IconButton(
          onPressed: () {
            widget.emailPrefix = uNameController.text;
            storeUserEmailLocally(uNameController.text);
            setState(() {
              editUserName = false;
            });
          },
          icon: Icon(
            color: Color.fromARGB(255, 26, 26, 26),
            Icons.check,
            size: 30,
          ))
    ]);
  }

  void storeUserEmailLocally(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }
}

class EventCard extends StatefulWidget {
  final Map<String, String> event;
  final Function onDelete;
  final Function onEdit;
  final Function showGeminiPrompt;
  final Function markAsDone;

  const EventCard(
      {super.key,
      required this.event,
      required this.onDelete,
      required this.onEdit,
      required this.showGeminiPrompt,
      required this.markAsDone});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Align delete button to the right
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 8),
                    Container(
                      width: ((screenWidth - 10) / 2),
                      child: Text(
                        '${widget.event['name']}' ?? '',
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Color(0xFF1A1A1A)), // Delete icon button
                      onPressed: () {
                        widget.onEdit();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Color(0xFF1A1A1A)), // Delete icon button
                      onPressed: () {
                        widget
                            .onDelete(); // Call onDelete function when pressed
                      },
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(children: [
                  Icon(Icons.schedule, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Start Time: ${widget.event['startTime'] ?? ''}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message_rounded,
                          color: Color(0xFF1A1A1A)), // Delete icon button
                      onPressed: () {
                        widget.showGeminiPrompt();
                      },
                    ),
                    Checkbox(
                        value: widget.event['doneStatus'] == 'true',
                        checkColor: Colors.white,
                        activeColor: Color(0xFF1A1A1A),
                        onChanged: (value) {
                          print("checkbox on changed");
                          setState(() {
                            widget.markAsDone(value);
                          });
                        })
                  ],
                )
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'End Time: ${widget.event['endTime'] ?? ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeminiPrompt extends StatefulWidget {
  final Function(List<Map<String, String>>) onSubmit;
  final int eventId;

  GeminiPrompt({required this.onSubmit, required this.eventId});

  @override
  _GeminiPromptState createState() => _GeminiPromptState();
}

class _GeminiPromptState extends State<GeminiPrompt> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _submitEventPromptToGemini(String prompt) async {
    try {
      // Define events variable and add event details to the prompt
      List<Map<String, String>> events =
          []; // Replace with your actual events list

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String eventDataJson = prefs.getString('eventData') ?? '[]';
      events = List<Map<String, String>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );

      String? startTime =
          events[widget.eventId]['startTime']; // nullable String
      String? endTime = events[widget.eventId]['endTime']; // nullable String

      String promptWithMessage =
          'Imagine you have been given the following task: "' +
              events[widget.eventId]["name"]! +
              ' from ' +
              startTime! +
              ' to ' +
              endTime! +
              '". To better understand and approach this task effectively, consider asking questions that clarify: ' +
              prompt;

      print("prompt message ${promptWithMessage}");

      final newresponse =
          await NetworkApiServices().postAIPromptApi(promptWithMessage);

      // print("gemini:* " + response!.output! + " ***");
      print("llama # " +
          newresponse["choices"][0]["message"]["content"] +
          " ###");
      if (newresponse != null &&
          newresponse["choices"] != null &&
          newresponse["choices"].length > 0 &&
          newresponse["choices"][0]["message"] != null &&
          newresponse["choices"][0]["message"]["content"] != null) {
        // setState(() {
        String response = newresponse["choices"][0]["message"]["content"] ??
            'No response received'; // Display AI response
        print("response from ai ${response}");
        _controller.clear(); // Clear the text field after submission
        // });
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.black26,
                title: Text(
                  '${prompt} for \n"${events[widget.eventId]["name"]}"',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
                content: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      response,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              );
            });
      }
    } catch (e) {
      print('Error sending prompt to AI: $e');
      // Handle error scenario, such as showing a snackbar
    }
  }

  Future<void> _submitCreateEventPromptToGemini(String prompt) async {
    // final gemini = Gemini.instance; // Initialize Gemini instance

    try {
      // Get current time formatted in 24-hour format
      String currentTime = DateFormat.Hm().format(DateTime.now());

      // Construct the prompt message with the current time included
      String promptWithMessage = prompt;

      // Define events variable and add event details to the prompt
      List<Map<String, String>> events =
          []; // Replace with your actual events list

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String eventDataJson = prefs.getString('eventData') ?? '[]';
      events = List<Map<String, String>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );

      // Create a set to track used timings
      // Set<String> usedTimingsSet = {};
      String usedTimingsSet = "";

      for (int i = 0; i < events.length; i++) {
        String? startTime = events[i]['startTime']; // nullable String
        String? endTime = events[i]['endTime']; // nullable String

        // Ensure startTime and endTime are not null before using them
        if (startTime != null && endTime != null) {
          String formattedTiming = '$startTime - $endTime';

          usedTimingsSet += formattedTiming;
          if (i < (events.length - 1)) {
            usedTimingsSet += ", ";
          }
          // Ensure the timings are unique before adding to the set
          // if (!usedTimingsSet.contains(formattedTiming)) {
          //   promptWithMessage +=
          //       'TASK ${i + 1} == ${events[i]['name']} == $startTime - $endTime\n\n';

          //   usedTimingsSet.add(formattedTiming); // Add to used timings set
          // }
        }
      }

      promptWithMessage += usedTimingsSet.length > 0
          ? "\n*AVOID THE TIME SLOTS " + usedTimingsSet + "*\n"
          : "";
      // Add all used timings from event cards to ensure they are not repeated
      // List<String> usedTimings = usedTimingsSet.toList();

      // promptWithMessage += 'Busy Timings: ${usedTimings.join(', ')}';

      promptWithMessage += ' \nUse This Format:\n'
              'Task 1) # (NAME OF TASK) # START TIME - END TIME\n'
              'Task 2) # (NAME OF TASK) # START TIME - END TIME\n'
              'Do not use any bullet points or anything extra as this response will be decoded by a program that only accepts responses in the provided format.\n' +
          'Use 24-hour format for the time.\n' +
          '*MAKE SURE TO INCLUDE THE # OR ELSE THE RESPONSE WONT BE DECODED*\n' +
          '*MAKE SURE YOU GIVE THE START TIME FROM THE **NEXT PERFECT HOUR AFTER ($currentTime)*.\n' +
          '*DONT WRITE ANYTHING EXTRA THATS NOT IN THE FORMAT AND RESPOND IN 24HR FORMAT .**\n';

      print("prompt message ${promptWithMessage}");

      // String tmpPromptMsg =
      //     "Code for two hours and lunch for for half-hour that avoids the time slots 18:00 - 19:00, 19:30 - 20:30\n" +
      //         "Use This Format:\n" +
      //         "No Of Tasks = (x)\n" +
      //         "Task 1) # (NAME OF TASK) # START TIME - END TIME\n" +
      //         "Do not use any bullet points or anything extra as this response will be decoded by a program that only accepts responses in the provided format.\n" +
      //         "Use 24-hour format for the time.\n" +
      //         "*MAKE SURE TO INCLUDE THE # OR ELSE THE RESPONSE WONT BE DECODED*\n" +
      //         "*MAKE SURE YOU GIVE THE START TIME FROM THE **NEXT PERFECT HOUR AFTER (18:18)*.\n" +
      //         "*AVOID THE TIME SLOTS 18:00 - 19:00, 19:30 - 20:30\n*"
      //             "*DONT WRITE ANYTHING EXTRA THATS NOT IN THE FORMAT AND RESPOND IN 24HR FORMAT .**";

      // print(tmpPromptMsg);

      // Send prompt to Gemini and receive response
      // final Candidates? response = await gemini.text(promptWithMessage);

      final newresponse =
          await NetworkApiServices().postAIPromptApi(promptWithMessage);

      // print("gemini:* " + response!.output! + " ***");
      print("llama # " +
          newresponse["choices"][0]["message"]["content"] +
          " ###");
      if (newresponse != null &&
          newresponse["choices"] != null &&
          newresponse["choices"].length > 0 &&
          newresponse["choices"][0]["message"] != null &&
          newresponse["choices"][0]["message"]["content"] != null) {
        setState(() {
          _response = newresponse["choices"][0]["message"]["content"] ??
              'No response received'; // Display AI response
          _controller.clear(); // Clear the text field after submission
        });

        // Parse response into a list of event data
        List<Map<String, String>> parsedEventData = _parseEventData(
            newresponse["choices"][0]["message"]["content"], events.length);
        widget.onSubmit(
            parsedEventData); // Pass parsed data back to parent widget
      } else {
        setState(() {
          _response = 'No response received'; // Display NO response
          _controller.clear(); // Clear the text field after submission
        });
        return;
      }
    } catch (e) {
      print('Error sending prompt to AI: $e');
      // Handle error scenario, such as showing a snackbar
    }
  }

  List<Map<String, String>> _parseEventData(
      String? response, int prevEventCount) {
    List<Map<String, String>> eventData = [];

    if (response != null && response.isNotEmpty) {
      List<String> lines = response.split('\n');
      String? noOfTasks;

      for (String line in lines) {
        if (line.startsWith('No Of Tasks = ')) {
          noOfTasks = line.substring('No Of Tasks = '.length).trim();
        } else if (line.startsWith('Task')) {
          // Assuming line format: Task 1) # NAME OF THE TASK # START TIME - END TIME
          List<String> parts = line.split('#');

          if (parts.length >= 3) {
            String name = parts[1].trim();
            String timeFrame = parts[2].trim();

            // Extract start and end time from timeFrame
            // Example timeFrame: "NAME OF THE TASK # START TIME - END TIME"
            int startIndex = timeFrame.indexOf('#') + 1;
            int endIndex = timeFrame.lastIndexOf('-');

            if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
              String startTime =
                  timeFrame.substring(startIndex, endIndex).trim();
              String endTime = timeFrame.substring(endIndex + 1).trim();

              DateTime now = DateTime.now();
              var timings = startTime.split(":");
              int startHour = int.parse(timings[0]);
              int startMinutes = int.parse(timings[1].substring(0, 2));
              var startDateTime = DateTime(
                  now.year, now.month, now.day, startHour, startMinutes);
              startDateTime = startDateTime.subtract(Duration(minutes: 5));

              print("new event number ${prevEventCount + eventData.length}");
              int eventNotifyId = prevEventCount + eventData.length;
              _notifyService.scheduleNotification(
                  "Remainder",
                  "${name} ${startTime} - ${endTime}",
                  eventNotifyId,
                  startDateTime.day,
                  startDateTime.hour,
                  startDateTime.minute);
              eventData.add({
                'name': name,
                'startTime': startTime,
                'endTime': endTime,
                'currenttimeinmillis': '${now.millisecondsSinceEpoch}',
                'donesStatus': 'false'
              });
            }
          }
        }
      }
    }

    return eventData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              reverse: true, // Start scrolling from the bottom
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display prompt sent to Gemini
                  if (_response.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('You: ${_controller.text}'),
                    ),

                  // Display response received from Gemini
                  if (_response.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('AI response: $_response'),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Your Tasks',
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        if (widget.eventId >= 0) {
                          _submitEventPromptToGemini(_controller.text);
                        } else {
                          _submitCreateEventPromptToGemini(_controller.text);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  final List<Map<String, String>> eventData;

  CalendarPage({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildTopWhiteArea(),
          _buildCalendarHeader(),
          _buildBottomF1F5F9Area(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTopWhiteArea() {
    return Container(
      color: Colors.white,
      height: 60,
    );
  }

  Widget _buildCalendarHeader() {
    final today = DateTime.now();
    final startOfWeek =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    final daysOfWeek =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('MMMM yyyy').format(today),
              style: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) {
              final isToday = day.day == today.day &&
                  day.month == today.month &&
                  day.year == today.year;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(day),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: isToday ? Colors.black : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor:
                          isToday ? Color(0xFF1A1A1A) : Colors.transparent,
                      child: Text(
                        day.day.toString(),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: isToday ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomF1F5F9Area() {
    List<String> hours = List.generate(24, (index) {
      return DateFormat.Hm().format(DateTime(2024, 1, 1, index));
    });

    return Expanded(
      child: Container(
        color: Color(0xFFF1F5F9),
        child: ListView.builder(
          itemCount: hours.length,
          itemBuilder: (context, index) {
            String hour = hours[index];
            List<Map<String, String>> events = eventData
                .where((event) =>
                    event['startTime']!.startsWith(hour.substring(0, 2)) ||
                    event['endTime']!.startsWith(hour.substring(0, 2)))
                .toList();

            return ListTile(
              title: Row(
                children: [
                  Text(
                    hour,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: Color(0xFFA4B9DE)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Color(0xFFA4B9DE),
                      margin: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events.map((event) {
                  DateTime startTime =
                      DateTime.parse('2024-01-01 ${event['startTime']}:00');
                  DateTime endTime =
                      DateTime.parse('2024-01-01 ${event['endTime']}:00');
                  double eventHeight =
                      endTime.difference(startTime).inMinutes.toDouble();

                  return Padding(
                    padding: const EdgeInsets.only(left: 32.0, bottom: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Color(0xFF1A1A1A), // Background color
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name']!,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white, // Text color
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${event['startTime']} - ${event['endTime']}',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF1A1A1A),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, size: 24),
          label: '',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Navigator.pushNamed(context, '/home');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(title: 'Flutter App Home Page'),
              ),

              // EventCalender(eventData: widget.eventData))
              // builder: (context) => CalendarPage(eventData: widget.eventData)),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EventCalenderNew(eventData: eventData)),
              // builder: (context) => CalendarPage(eventData: eventData)),
            );
            break;
        }
      },
    );
  }
}
