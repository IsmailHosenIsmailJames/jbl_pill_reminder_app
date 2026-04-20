import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:toastification/toastification.dart";
import "package:get/get.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/getx/auth_controller.dart";

import "../../../theme/colors.dart";
import "../../../widgets/intro_pages.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController();
  final formKey = GlobalKey<FormState>();

  TextEditingController textEditingControllerPhoneNumber =
      TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();

  bool isAsyncLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          interactive: true,
          thickness: 5,
          radius: const Radius.circular(7),
          thumbVisibility: true,
          trackVisibility: true,
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                AppIntroPages(pageController: pageController),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: listOfPagesInfo.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: MyAppColors.primaryColor,
                        dotHeight: 5,
                        dotWidth: MediaQuery.of(context).size.width / 10,
                        expansionFactor: 7,
                        spacing: 5,
                      ),
                    ),
                  ),
                ),
                const Gap(30),
                Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: AutofillGroup(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back!",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: MyAppColors.primaryColor,
                                  ),
                            ),
                            const Gap(20),
                            getTitlesForFields(
                              title: "Phone Number",
                              isFieldRequired: true,
                            ),
                            const Gap(5),
                            customTextFieldDecoration(
                              textFormField: TextFormField(
                                keyboardType: TextInputType.phone,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber
                                ],
                                decoration: textFieldInputDecoration(
                                  hint: "+8801xxxxxxxxx",
                                  prefixIcon: const Icon(
                                      Icons.phone_android_rounded,
                                      color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your phone number";
                                  }
                                  if (value.length != 11 &&
                                      value.length != 14) {
                                    return "Please enter a valid phone number";
                                  }
                                  return null;
                                },
                                controller: textEditingControllerPhoneNumber,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            const Gap(15),
                            getTitlesForFields(
                              title: "Password",
                              isFieldRequired: true,
                            ),
                            const Gap(5),
                            customTextFieldDecoration(
                              textFormField: TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                autofillHints: const [AutofillHints.password],
                                obscureText: true,
                                onEditingComplete: () =>
                                    TextInput.finishAutofillContext(),
                                decoration: textFieldInputDecoration(
                                  hint: "type your password...",
                                  prefixIcon: const Icon(Icons.lock_rounded,
                                      color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                                controller: textEditingControllerPassword,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            const Gap(25),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyAppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    TextInput.finishAutofillContext(
                                        shouldSave: true);
                                    final authController =
                                        Get.find<AuthController>();

                                    final success = await authController.login(
                                      textEditingControllerPhoneNumber.text,
                                      textEditingControllerPassword.text,
                                    );

                                    if (success) {
                                      toastification.show(
                                        context: context,
                                        title: const Text("Login Successful"),
                                        autoCloseDuration:
                                            const Duration(seconds: 2),
                                        type: ToastificationType.success,
                                      );
                                      if (context.mounted) {
                                        context.goNamed(Routes.homeRoute);
                                      }
                                    }
                                  }
                                },
                                child: Obx(() {
                                  final authController =
                                      Get.find<AuthController>();
                                  return authController.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Log in",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        );
                                }),
                              ),
                            ),
                            const Gap(15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Haven't signed up yet?"),
                                TextButton(
                                  onPressed: () {
                                    context.goNamed(Routes.signupRoute);
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
