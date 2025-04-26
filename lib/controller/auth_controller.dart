import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/routes.dart';
import '../utils/utils.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final tokenController = TextEditingController();
  final resetPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();


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

  Future<void> signup() async {
    final supabase = Supabase.instance.client;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    Utils.showLoading();

    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    Utils.closeLoading();

    if (response.user != null) {
      var userData = {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "status": 0,
        "photo": "",
      };

      try {
        final insertResponse = await supabase.from('Users').insert(userData);

        if (insertResponse.error != null) {
          print('❗ Supabase error: ${insertResponse.error!.message}');
        } else {
          print('✅ Data saved to Supabase: ${insertResponse.data}');
        }

        // ✅ Save all data to Hive
        HiveStoreUtil.setString(HiveStoreUtil.emailKey, email);
        HiveStoreUtil.setString('first_name', firstName);
        HiveStoreUtil.setString('last_name', lastName);
        HiveStoreUtil.setString('photo', ""); // empty for now
        HiveStoreUtil.setString('password', password); // not ideal, but you asked for it
      } catch (e) {
        print('❗ Exception saving to Supabase: $e');
      }

      Get.offAllNamed(Routes.homeScreen);
    } else {
      print('❌ Signup failed');
    }
  }


  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final supabase = Supabase.instance.client;
    final email = HiveStoreUtil.getString(HiveStoreUtil.emailKey);

    Utils.showLoading();

    try {
      // Step 1: Re-authenticate with old password
      final signInResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (signInResponse.user == null) {
        Utils.closeLoading();
        print('❗ Old password is incorrect');
        return;
      }

      // Step 2: Change password in Auth
      final updateAuthResponse = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateAuthResponse.user != null) {
        // Step 3: Update password field in 'Users' table too
        final updateUserResponse = await supabase
            .from('Users')
            .update({'password': newPassword})
            .eq('email', email);

        if (updateUserResponse.error != null) {
          print('❗ Failed to update password in Users table: ${updateUserResponse.error!.message}');
        } else {
          print('✅ Password updated successfully in Users table');
        }

        Utils.closeLoading();
        print('✅ Password updated successfully');
      } else {
        Utils.closeLoading();
        print('❗ Failed to update password');
      }
    } catch (e) {
      Utils.closeLoading();
      print('❗ Exception while changing password: $e');
    }
  }

  Future<void> logout() async {
    Utils.showLoading();
    try {
      await Supabase.instance.client.auth.signOut();
      HiveStoreUtil.clear();
      Utils.closeLoading();
      Get.offAllNamed(Routes.loginScreen);
      print('✅ Logged out successfully');
    } catch (e) {
      Utils.closeLoading();
      print('❗ Logout failed: $e');
    }
  }

  Future<void> editProfile({
    required String firstName,
    required String lastName,
    required String photoUrl,
    String? newEmail, // optional new email
  }) async {
    final supabase = Supabase.instance.client;
    final currentEmail = HiveStoreUtil.getString(HiveStoreUtil.emailKey); // get logged-in user's current email

    Utils.showLoading();
    try {
      // Prepare data to update
      Map<String, dynamic> updateData = {
        "first_name": firstName,
        "last_name": lastName,
        "photo": photoUrl,
      };

      if (newEmail != null && newEmail.isNotEmpty) {
        updateData["email"] = newEmail;
      }

      // Update in Users table
      final response = await supabase
          .from('Users')
          .update(updateData)
          .eq("email", currentEmail);

      Utils.closeLoading();

      if (response.error != null) {
        print('❗ Update profile error: ${response.error!.message}');
      } else {
        print('✅ Profile updated successfully');

        if (newEmail != null && newEmail.isNotEmpty) {
          // Update locally stored email
          HiveStoreUtil.setString(HiveStoreUtil.emailKey, newEmail);
        }
      }
    } catch (e) {
      Utils.closeLoading();
      print('❗ Exception while updating profile: $e');
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