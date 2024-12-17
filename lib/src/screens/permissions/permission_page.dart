import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

import '../../core/foreground_service/foreground_task_manager.dart';
import '../../data/check/auth_check.dart';
import '../auth/login/login_page.dart';
import '../home/home_page.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  String permissionString = "Allow Notifications";
  IconData iconData = Icons.notifications_active;
  IconData topIcon = Icons.notifications_active_rounded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                child: Center(
                  child: Icon(
                    iconData,
                    size: 100,
                    color: MyAppColors.primaryColor,
                  ),
                ),
              ),
              const Gap(20),
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "We need some permissions. Please allow them. Else we can't proceed further.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              const Gap(20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (!(await Permission.notification.isGranted)) {
                      PermissionStatus status =
                          await Permission.notification.request();
                      if (status != PermissionStatus.granted) {
                        status = await Permission.notification.request();
                      }
                      if (status == PermissionStatus.granted) {
                        Get.back(result: true);
                        toastification.show(
                          title: const Text("Notification Permission Granted"),
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                      }
                    }

                    if (await Permission.notification.isGranted) {
                      // Start the service
                      initService();
                      await startService();
                      await LocalNotifications.initializeService();
                      // Check auth and rote
                      AuthCheck.isLoggedIn()
                          ? Get.to(() => const HomePage())
                          : Get.to(() => const LoginPage());
                    }
                  },
                  icon: Icon(
                    iconData,
                  ),
                  label: Text(
                    permissionString,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
