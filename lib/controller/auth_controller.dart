import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/services/user_service.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_model.dart';
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

  TasksController _tasksController = Get.put(TasksController());
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    Utils.showLoading();

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    Utils.closeLoading();

    if (response.user != null) {
      final uid = response.user!.id;
      UserService.checkUser(uid);
      _tasksController.loadUserTasks();
      Get.offAllNamed(Routes.homeScreen);
        } else {
      print('❌ Login failed');
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
      final uid = response.user!.id;

      final user = UserModel(
        userId: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        photo: '',
      );

      try {
        final insertResponse = await supabase
            .from(UserService.users)
            .insert(user.toMap());

        if (insertResponse.error != null) {
          print('❗ Supabase error: ${insertResponse.error!.message}');
        } else {
          print('✅ Data saved to Supabase: ${insertResponse.data}');
        }

        // Store in Hive
        HiveStoreUtil.setString(HiveStoreUtil.emailKey, user.email);
        HiveStoreUtil.setString(HiveStoreUtil.userIdKey, user.userId);
        HiveStoreUtil.setString(HiveStoreUtil.firstNameKey, user.firstName);
        HiveStoreUtil.setString(HiveStoreUtil.lastNameKey, user.lastName);
        HiveStoreUtil.setString(HiveStoreUtil.photo, user.photo);
        HiveStoreUtil.setString(HiveStoreUtil.password, user.password); // ⚠️ Avoid this in real apps

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
            .from(UserService.users)
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
        UserService.firstName: firstName,
        UserService.lastName: lastName,
        UserService.photo: photoUrl,
      };

      if (newEmail != null && newEmail.isNotEmpty) {
        updateData["email"] = newEmail;
      }


      final response = await supabase
          .from(UserService.users)
          .update(updateData)
          .eq("email", currentEmail);
      HiveStoreUtil.setString(HiveStoreUtil.firstNameKey, firstName);
      HiveStoreUtil.setString(HiveStoreUtil.lastNameKey, lastName);
      HiveStoreUtil.setString(HiveStoreUtil.photo, photoUrl);
      Get.back();
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