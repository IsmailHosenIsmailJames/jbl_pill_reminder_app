import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:jbl_pills_reminder_app/src/core/background/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/history/history_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/my_pills/my_pills_page.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/profile_page.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:package_info_plus/package_info_plus.dart";

class MyDrawer extends StatelessWidget {
  final String phone;
  const MyDrawer({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
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
                      phone: phone,
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
                      phone: phone,
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
                          await Hive.box("user_db").clear();
                          await Hive.box("reminder_db").clear();
                          await cancelAllScheduledTask();
                          await Hive.initFlutter();
                          // Get.offAll(() => const LoginPage());
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => true,
                          );
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
