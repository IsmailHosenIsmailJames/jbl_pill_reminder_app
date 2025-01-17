import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/screens/auth/login/controller/login_page_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/auth/signup/signup_page.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/widgets/intro_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../widgets/textfieldinput_decoration.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController textEditingControllerPhone = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();
  PageController pageController = PageController();

  final loginControllerGetx = Get.put(LoginPageController());

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIntroPages(pageController: pageController),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Center(
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: listOfPagesInfo.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: MyAppColors.primaryColor,
                      dotHeight: 5,
                      dotWidth: MediaQuery.of(context).size.width / 11,
                      expansionFactor: 7,
                      spacing: 5,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(5),
                        // phone text field
                        customTextFieldDecoration(
                          textFormField: TextFormField(
                            controller: textEditingControllerPhone,
                            validator: (value) {
                              if (value?.isEmpty == true) {
                                return "Please enter your phone number";
                              }
                              if (value?.length != 11) {
                                return "Please enter a valid phone number";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: textFieldInputDecoration(
                              hint: "type your phone number here...",
                            ),
                          ),
                        ),
                        const Gap(15),

                        const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(5),
                        // password text field
                        Obx(
                          () => customTextFieldDecoration(
                            textFormField: TextFormField(
                              controller: textEditingControllerPassword,
                              validator: (value) {
                                if (value?.isEmpty == true) {
                                  return "Please enter your password";
                                }
                                if ((value?.length ?? 0) < 8) {
                                  return "Require at least 8 characters";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.visiblePassword,
                              obscureText:
                                  loginControllerGetx.showPassword.value,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: textFieldInputDecoration(
                                hint: "type your password here...",
                              ),
                            ),
                          ),
                        ),
                        const Gap(15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() == true) {
                                loginControllerGetx.login(
                                  phone: textEditingControllerPhone.text,
                                  password: textEditingControllerPassword.text,
                                );
                              }
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Gap(30),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey,
                              ),
                            ),
                            const Gap(5),
                            const Text(
                              "Or",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const Gap(5),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Have't an account?"),
                            SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: () {
                                  Get.to(
                                    () => const SignupPage(),
                                  );
                                },
                                child: const Text("Sign Up"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
