import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:package_info_plus/package_info_plus.dart";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_state.dart";

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
              context.pop();
              context.pushNamed(Routes.homeRoute);
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.person_24_regular),
            title: const Text("Profile"),
            onTap: () {
              context.pop();
              context.pushNamed(Routes.profileRoute);
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.pill_24_regular),
            title: const Text("My Pills"),
            onTap: () {
              context.pop();
              final authState = context.read<AuthCubit>().state;
              context.pushNamed(
                Routes.myPillsRoute,
                extra: authState is Authenticated ? authState.user.mobile : "",
              );
            },
          ),
          ListTile(
            minTileHeight: 40,
            leading: const Icon(FluentIcons.history_24_regular),
            title: const Text("My History"),
            onTap: () {
              context.pop();
              final authState = context.read<AuthCubit>().state;
              context.pushNamed(
                Routes.historyRoute,
                extra: authState is Authenticated ? authState.user.mobile : "",
              );
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
                          context.pop();
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
                          context.pop();
                          await context.read<AuthCubit>().logout();
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
