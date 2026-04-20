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
                  // Edit profile logic (can be implemented later or redirected to old signup page with adaptation)
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
