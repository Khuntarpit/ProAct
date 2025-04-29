import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proact/controller/auth_controller.dart';
import 'package:proact/model/user_model.dart';
import 'package:proact/services/user_service.dart';

import '../../../utils/hive_store_util.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
     UserModel user = UserService.getCurrentUserData();
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }


  AuthController authController = Get.put(AuthController());

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextField(
      {
        required String hintText,
        required String title,
        required IconData icon,
        required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: TextStyle(fontSize: 16),),
        SizedBox(height: 10,),
        TextField(
          style: TextStyle(fontSize: 18),
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            hintText: hintText,
            // filled: true,
            // fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : NetworkImage("https://c1.35photo.pro/profile/photos/192/963119_140.jpg"),

                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).iconTheme.color,
                        child: Icon(Icons.edit,color: Theme.of(context).scaffoldBackgroundColor,size: 16,),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Violet Amelia"),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                title: "First Name",
                hintText: 'Your First Name',
                icon: Icons.person,
                controller: _firstNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                title: "Last Name",
                hintText: 'Your Last Name',
                icon: Icons.person_outline,
                controller: _lastNameController,
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ),

      bottomNavigationBar:Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              authController.editProfile(
                  firstName: _firstNameController.text.trim().toString(),
                  lastName: _lastNameController.text.trim().toString(),
                  photoUrl: "");
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),

    );
  }
}
