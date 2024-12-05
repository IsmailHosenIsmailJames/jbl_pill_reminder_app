import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/screens/auth/signup/controller/signup_page_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/home_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../theme/colors.dart';
import '../../../widgets/intro_pages.dart';
import '../../../widgets/textfieldinput_decoration.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController textEditingControllerName = TextEditingController();
  TextEditingController textEditingControllerPhone = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();
  TextEditingController textEditingControllerConfirmPassword =
      TextEditingController();
  PageController pageController = PageController();

  final signupControllerGetx = Get.put(SignupPageController());

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
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
                const Gap(20),
                const Row(
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      " *",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Gap(5),
                // phone text field
                customTextFieldDecoration(
                  textFormField: TextFormField(
                    controller: textEditingControllerName,
                    keyboardType: TextInputType.name,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: textFieldInputDecoration(
                      hint: "type your name here...",
                    ),
                  ),
                ),
                const Gap(10),

                const Row(
                  children: [
                    Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      " *",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: textFieldInputDecoration(
                      hint: "type your phone number here...",
                    ),
                  ),
                ),
                const Gap(10),
                const Row(
                  children: [
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      " *",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
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
                      obscureText: signupControllerGetx.showPassword.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: textFieldInputDecoration(
                        hint: "type your password here...",
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                const Row(
                  children: [
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      " *",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Gap(5),
                // confirm password text field
                Obx(
                  () => customTextFieldDecoration(
                    textFormField: TextFormField(
                      controller: textEditingControllerConfirmPassword,
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return "Please enter your password again";
                        }
                        if (textEditingControllerConfirmPassword.text !=
                            textEditingControllerPassword.text) {
                          return "Confirm password does not match";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: signupControllerGetx.showPassword.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: textFieldInputDecoration(
                        hint: "type your password again...",
                      ),
                    ),
                  ),
                ),
                const Gap(15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() == true) {
                        bool isSuccessful = await signupControllerGetx.signUp(
                          name: textEditingControllerName.text,
                          phone: textEditingControllerPhone.text,
                          password: textEditingControllerPassword.text,
                        );
                        if (isSuccessful) {
                          Get.off(() => const HomePage());
                        }
                      }
                    },
                    child: const Text(
                      "Sign Up",
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
                    const Text("Have an account?"),
                    SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Login"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
