import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_state.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";

class ResetPasswordPage extends StatefulWidget {
  final String sessionToken;
  const ResetPasswordPage({super.key, required this.sessionToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password reset successfully!"), backgroundColor: Colors.green),
            );
            context.goNamed(Routes.loginRoute);
          } else if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your new password",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Gap(30),
                getTitlesForFields(title: "New Password", isFieldRequired: true),
                const Gap(5),
                customTextFieldDecoration(
                  textFormField: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: textFieldInputDecoration(
                      hint: "Enter new password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter password";
                      if (value.length < 6) return "Min 6 characters";
                      return null;
                    },
                  ),
                ),
                const Gap(20),
                getTitlesForFields(title: "Confirm Password", isFieldRequired: true),
                const Gap(5),
                customTextFieldDecoration(
                  textFormField: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: textFieldInputDecoration(
                      hint: "Confirm new password",
                      prefixIcon: const Icon(Icons.lock_clock, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value != passwordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                ),
                const Gap(30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is ForgotPasswordLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  context.read<ForgotPasswordCubit>().resetPassword(
                                        passwordController.text,
                                        widget.sessionToken,
                                      );
                                }
                              },
                        child: state is ForgotPasswordLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Reset Password"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
