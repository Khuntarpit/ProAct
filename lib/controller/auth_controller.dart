import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/routes.dart';
import '../utils/utils.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  login()async{
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    // Perform login using Supabase
    Utils.showLoading();
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    Utils.closeLoading();
    if (response.user != null) {
      // Successful login
      HiveStoreUtil.setString(HiveStoreUtil.emailKey, email); // Store email locally
      Get.offAllNamed(Routes.homeScreen);
    } else {
      // Handle unsuccessful login if needed
      print('Login failed');
    }
  }

  signup()async{
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    // Perform signup using Supabase
    Utils.showLoading();
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    Utils.closeLoading();
    if (response.user != null) {
      // Successful signup
      HiveStoreUtil.setString(HiveStoreUtil.emailKey, email); // Store email locally
      Get.offAllNamed(Routes.homeScreen);
    } else {
      // Handle unsuccessful signup if needed
      print('signup failed');
    }
  }

  resetPasswordSend(){
    Get.back();
    final email = emailController.text.trim();
    Utils.showLoading(msg: "Check your email for token");

    Supabase.instance.client.auth
        .resetPasswordForEmail(email)
    // .resetPasswordForEmail(email)
        .then((value) {
      Utils.closeLoading();
      Get.toNamed(Routes.resetPasswordScreen);
    }).catchError((error) {
      print("error");
    });
  }

  final tokenController = TextEditingController();
  final resetPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  resetPassword()async{
    final password = resetPasswordController.text.trim();
    final email = emailController.text.trim();
    final token = tokenController.text.trim();
    Utils.showLoading(msg: "Resetting Password");
    // Perform login using Supabase
    try {
      var supabaseClient = Supabase.instance.client;
      final recovery = await supabaseClient.auth
          .verifyOTP(
          email: email,
          token: token,
          type: OtpType.recovery);
      print(recovery);
      final response = await supabaseClient.auth
          .updateUser(UserAttributes(password: password));

      print(response);
      if (response.user != null) {
        await supabaseClient.auth
            .signOut(scope: SignOutScope.global);
        Utils.closeLoading();
        Get.back();
      } else {
        print('Reset password failed');
      }
    } catch (error) {
      Utils.closeLoading();
    }
  }
}