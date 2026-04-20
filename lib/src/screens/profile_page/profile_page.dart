import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_state.dart";

import "package:jbl_pills_reminder_app/src/screens/home/drawer/my_drawer.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    context.read<AuthCubit>().getUserProfile();
    super.initState();
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
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final user = state.user;
          String userName = user.name ?? "User";

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
                  userName,
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
                    ": ${user.mobile}",
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
                    ": ${user.age ?? 'N/A'}",
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
                    ": ${user.status}",
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
                    ": ${user.division ?? 'N/A'}",
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
                    ": ${user.district ?? 'N/A'}",
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
                    ": ${user.upazila ?? 'N/A'}",
                  ),
                ],
              ),
              const Divider(),
              const Gap(30),
              OutlinedButton.icon(
                onPressed: () {
                  // Edit profile logic
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text("Edit Profile"),
              ),
              const Gap(10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showUpdatePasswordDialog(context);
                },
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text("Update Password"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Old Password"),
                validator: (value) =>
                    value!.isEmpty ? "Enter old password" : null,
              ),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
                validator: (value) => value!.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Confirm New Password"),
                validator: (value) => value != newPasswordController.text
                    ? "Passwords do not match"
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await context.read<AuthCubit>().updatePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                    );
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
