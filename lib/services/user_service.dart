import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_model.dart';
import '../utils/hive_store_util.dart';

class UserService {
  static var client = Supabase.instance.client;
  static var users = "Users";
  static var id = "id";
  static var email = "email";
  static var firstName = "first_name";
  static var lastName = "last_name";
  static var photo = "photo";
  static var password = "password";

  static checkUser(uid)async{
    final userResponse = await client
        .from(users)
        .select()
        .eq(id, uid)
        .single();

    HiveStoreUtil.setString(HiveStoreUtil.emailKey, userResponse[email] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.userIdKey, uid);
    HiveStoreUtil.setString(HiveStoreUtil.firstNameKey, userResponse[firstName] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.lastNameKey, userResponse[lastName] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.photo, userResponse[photo] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.password, userResponse[password] ?? '');

  }

  static UserModel getCurrentUserData() {
    final email = HiveStoreUtil.getString(HiveStoreUtil.emailKey);
    final userId = HiveStoreUtil.getString(HiveStoreUtil.userIdKey);
    final firstName = HiveStoreUtil.getString(HiveStoreUtil.firstNameKey);
    final lastName = HiveStoreUtil.getString(HiveStoreUtil.lastNameKey);
    final photo = HiveStoreUtil.getString(HiveStoreUtil.photo);
    final password = HiveStoreUtil.getString(HiveStoreUtil.password);

    return UserModel(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photo: photo,
      password: password,
    );
  }

}