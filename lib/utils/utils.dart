import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proact/constants/constants.dart';

import '../custom_elements/elements/custom_colors.dart';

///  this class contains small functions like validation and checking
///  functions that we can use in all pages.

class Utils {
 static showToast(String value) {
  Fluttertoast.showToast(
   msg: value,
   toastLength: Toast.LENGTH_LONG,
   gravity: ToastGravity.CENTER,
   timeInSecForIosWeb: 1,
   textColor: Colors.white,
   backgroundColor: Colors.black,
   fontSize: 16.0,
  );
 }

 static bool isValidEmail(String? value) => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value ?? '');
 // static bool isValidPhoneNumber(String? value) => RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3}$)').hasMatch(value ?? '');
 static bool isValidPhoneNumber(String? value) => (value!.length == 9);

 static Future<bool> isInternetConnected()async{
  try {
   final result = await InternetAddress.lookup('https://www.google.com');
   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    return true;
   }
  } on SocketException catch (_) {
   printLog('not internet connected');
  }
  return false;
 }

 static showLoading({String msg = 'Loading...'}){
  EasyLoading.show(status: msg,indicator: CircularProgressIndicator(color: CustomColors.primary,),dismissOnTap: false,maskType: EasyLoadingMaskType.black);
 }

 static closeLoading() {
  EasyLoading.dismiss();
 }

 static openDatePicker(BuildContext context,Function(DateTime?) onDone,{DateTime? initDate}){
  showDatePicker(
   context: context,
   initialDate: initDate ?? DateTime.now(),
   firstDate: DateTime(1900),
   lastDate: DateTime(5000),
   builder: (context, child) {
    return child!;
   },
  ).then((value) => onDone(value));
 }
}

DateTime? currentBackPressTime;

Future<bool> onWillPop(BuildContext context) {
 DateTime now = DateTime.now();
 if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  currentBackPressTime = now;

  Utils.showToast("Tap again to exit from app.",);
  return Future.value(false);
 }
 return Future.value(true);
}

Future<bool> backPressed(BuildContext context) async {
 bool back = await onWillPop(context );
 if (back) {
  if (Platform.isAndroid)
   SystemNavigator.pop();
  else
   exit(0);
 }
 return back;
}