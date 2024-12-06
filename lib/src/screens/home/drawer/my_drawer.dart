import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: MyAppColors.primaryColor,
            ),
          ),
          const Gap(20),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.home_24_regular),
            title: const Text("Home"),
            onTap: () {},
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.person_24_regular),
            title: const Text("Profile"),
            onTap: () {},
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.pill_24_regular),
            title: const Text("My Pills"),
            onTap: () {},
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.share_24_regular),
            title: const Text("Share Dosecast"),
            onTap: () {},
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.settings_24_regular),
            title: const Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.sign_out_24_regular),
            title: const Text("Sign Out"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
