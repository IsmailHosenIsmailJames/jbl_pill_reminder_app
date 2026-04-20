import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:jbl_pills_reminder_app/src/screens/history/history_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/my_pills/my_pills_page.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/profile_page.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:package_info_plus/package_info_plus.dart";

import "package:get/get.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/getx/auth_controller.dart";

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: MyAppColors.shadedMutedColor,
              image: const DecorationImage(
                image: AssetImage(
                  "assets/app_logo.jpeg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                          "${snapshot.data!.version} (${snapshot.data!.buildNumber})");
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ),
          const Gap(20),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.home_24_regular),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ));
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.person_24_regular),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ));
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.pill_24_regular),
            title: const Text("My Pills"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPillsPage(
                      phone: authController.userEntity.value?.mobile ?? "",
                    ),
                  ));
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.history_24_regular),
            title: const Text("My History"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      phone: authController.userEntity.value?.mobile ?? "",
                    ),
                  ));
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.sign_out_24_regular),
            title: const Text("Sign Out"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    insetPadding: const EdgeInsets.all(10),
                    title: const Text("Are you sure?"),
                    content: const Text(
                        "Once you sign out, your existing information will be deleted from the local device. Later you will get the data after signing in again."),
                    actions: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyAppColors.primaryColor,
                          iconColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text("Cancel"),
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          iconColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text("Sign Out"),
                        icon: const Icon(Icons.logout_rounded),
                        onPressed: () async {
                          Navigator.pop(context);
                          await authController.logout();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
