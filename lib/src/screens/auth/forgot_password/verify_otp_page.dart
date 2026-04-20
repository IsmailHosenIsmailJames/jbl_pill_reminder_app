import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:pinput/pinput.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_state.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";

class VerifyOtpPage extends StatefulWidget {
  final String mobile;
  final String hash;
  const VerifyOtpPage({super.key, required this.mobile, required this.hash});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: MyAppColors.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: MyAppColors.shadedGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: MyAppColors.primaryColor, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: MyAppColors.shadedMutedColor.withValues(alpha: 0.3),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            context.pushNamed(Routes.resetPasswordRoute,
                extra: state.sessionToken);
          } else if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the 6-digit OTP sent to ${widget.mobile}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Gap(30),
              getTitlesForFields(title: "OTP", isFieldRequired: true),
              const Gap(15),
              Center(
                child: Form(
                  key: formKey,
                  child: Pinput(
                    autofocus: true,
                    length: 6,
                    controller: otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    validator: (s) {
                      return s?.length == 6 ? null : "Pin is incorrect";
                    },
                    onCompleted: (pin) {
                      context.read<ForgotPasswordCubit>().verifyOtp(
                            widget.mobile,
                            pin,
                            widget.hash,
                          );
                    },
                  ),
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
                                context.read<ForgotPasswordCubit>().verifyOtp(
                                      widget.mobile,
                                      otpController.text,
                                      widget.hash,
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyAppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is ForgotPasswordLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Verify OTP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
