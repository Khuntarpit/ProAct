import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:proact/controller/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  ThemeController controller = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.all(8),
          icon : Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color) ,
          onPressed: () => Get.back(),),
        title: const Text('PROFILE',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 27),),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Stack(
              children: [
                Container(
                  child: Row(
                    children: [
                      SizedBox(width: 170,),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0,top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Violet Amelia",style: TextStyle(fontSize: 25,color: Colors.white),),
                            SizedBox(height: 8,),
                            Text("violet17@ame.com",style: TextStyle(fontSize: 18,color: Colors.white),),
                          ],
                        ),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0,left: 25),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage("https://c1.35photo.pro/profile/photos/192/963119_140.jpg"),
                    radius: 70,
                  ),
                )

              ],
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: const Divider(color: Colors.grey,thickness: 0.2,),
          ),

          _buildTile(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () {},
          ),
          Obx(() => ListTile(
            leading: Icon(Icons.brightness_6, color: Theme.of(context).iconTheme.color),
            title: Text(
              'App Appearance',
              style: TextStyle(fontSize: 20,color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            trailing: CupertinoSwitch(
              value: controller.isDarkMode.value,
              onChanged: controller.toggleTheme,
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: const Divider(color: Colors.grey,thickness: 0.2,),
          ),


          _buildTile(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Handle your logout logic here
            print("Logging out...");
          },
          icon: Icon(Icons.logout, color: Colors.white),
          label: Text(
            'Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shadowColor: Colors.black.withOpacity(0.4),
            elevation: 10, // Higher elevation = deeper shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),

    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(

          leading: Icon(icon, color: Theme.of(context).iconTheme.color),
          title: Text(title, style: TextStyle(fontSize:20,color: Theme.of(context).textTheme.bodyLarge?.color)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Divider(color: Colors.grey,thickness: 0.2,),
        ),
      ],
    );
  }
} 
