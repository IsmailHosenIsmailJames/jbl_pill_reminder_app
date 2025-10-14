import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/model/signup_models.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/signup_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/drawer/my_drawer.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfilePageController profilePageController =
      Get.put(ProfilePageController());

  final userDB = Hive.box("user_db");

  @override
  void initState() {
    loadUserData();
    super.initState();
  }

  void loadUserData() {
    String? userInfo = userDB.get("user_info", defaultValue: null);
    profilePageController.userInfo.value =
        userInfo != null ? UserInfoModel.fromJson(userInfo) : null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    TextStyle textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.grey,
    );
    return Scaffold(
      drawer: MyDrawer(
        phone: profilePageController.userInfo.value!.phone,
      ),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Obx(
        () {
          UserInfoModel? userInfo = profilePageController.userInfo.value;
          if (userInfo == null) {
            return const Center(
              child: Text("No user found"),
            );
          }
          String userName = userInfo.name;
          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(
                  userName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              const Gap(20),
              Center(
                child: Text(
                  userInfo.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Gap(20),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                    child: Text("Phone", style: textStyle),
                  ),
                  Text(
                    ": ${userInfo.phone}",
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                    child: Text("Age", style: textStyle),
                  ),
                  Text(
                    ": ${userInfo.age}",
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                    child: Text("Gender", style: textStyle),
                  ),
                  Text(
                    ": ${userInfo.gender}",
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                    child: Text("Division", style: textStyle),
                  ),
                  Text(
                    ": ${userInfo.division}",
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                    child: Text("District", style: textStyle),
                  ),
                  Text(
                    ": ${userInfo.district}",
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                    child: Text("Thana", style: textStyle),
                  ),
                  Text(
                    ": ${userInfo.thana}",
                  ),
                ],
              ),
              const Divider(),
              const Gap(30),
              OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupPage(
                          userInfoModel: userInfo,
                        ),
                      ));
                  loadUserData();
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text("Edit Profile"),
              ),
            ],
          );
        },
      ),
    );
  }
}
