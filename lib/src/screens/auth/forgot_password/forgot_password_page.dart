import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_state.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController mobileController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is OtpSent) {
            context.pushNamed(Routes.verifyOtpRoute, extra: {
              "mobile": state.mobile,
              "hash": state.hash,
            });
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
                  "Enter your mobile number to receive an OTP",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Gap(30),
                getTitlesForFields(title: "Phone Number", isFieldRequired: true),
                const Gap(5),
                customTextFieldDecoration(
                  textFormField: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: textFieldInputDecoration(
                      hint: "+8801xxxxxxxxx",
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter phone number";
                      if (value.length < 11) return "Enter valid phone number";
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
                                  context.read<ForgotPasswordCubit>().sendOtp(mobileController.text);
                                }
                              },
                        child: state is ForgotPasswordLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Send OTP"),
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
