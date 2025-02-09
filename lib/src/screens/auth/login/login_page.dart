import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:jbl_pills_reminder_app/src/api/apis.dart';
import 'package:jbl_pills_reminder_app/src/screens/auth/signup/signup_page.dart';
import 'package:jbl_pills_reminder_app/src/screens/home/home_screen.dart';
import 'package:jbl_pills_reminder_app/src/widgets/get_titles.dart';
import 'package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:toastification/toastification.dart';

import '../../../theme/colors.dart';
import '../../../widgets/intro_pages.dart';

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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  getTitlesForFields(
                    title: 'Phone Number',
                    isFieldRequired: true,
                  ),
                  const Gap(5),
                  customTextFieldDecoration(
                    textFormField: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: textFieldInputDecoration(
                        hint: '+8801xxxxxxxxx',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 11 && value.length != 14) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      controller: textEditingControllerPhoneNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const Gap(10),
                  getTitlesForFields(
                    title: 'Password',
                    isFieldRequired: true,
                  ),
                  const Gap(5),
                  customTextFieldDecoration(
                    textFormField: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      decoration: textFieldInputDecoration(
                        hint: 'type your password...',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      controller: textEditingControllerPassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await login(context);
                        }
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Haven't signed up yet?"),
                      TextButton(
                        onPressed: () {
                          Get.off(
                            () => const SignupPage(),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    String phone = textEditingControllerPhoneNumber.text;
    if (!phone.startsWith('+88')) {
      phone = '+88$phone';
    }
    try {
      final response = await post(
        Uri.parse(loginAPI),
        body: jsonEncode({
          'phone': phone,
          'password': textEditingControllerPassword.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      log('Hit : $loginAPI', name: 'HTTP');
      log(response.statusCode.toString(), name: 'HTTP');
      log(response.body, name: 'HTTP');
      if (response.statusCode == StatusCode.OK) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        data.addAll({'password': textEditingControllerPassword.text});
        await Hive.box('user_db').put(
          'user_info',
          jsonEncode(data),
        );
        toastification.show(
          context: context,
          title: const Text('Login Successful'),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.success,
        );
        Get.off(
          () => const HomeScreen(),
        );
      } else {
        String errorMsg = jsonDecode(response.body)['message'];
        toastification.show(
          context: context,
          title: const Text('Login Failed'),
          description: Text(errorMsg),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
        );
      }
    } on HttpException catch (e) {
      toastification.show(
        context: context,
        title: Text(e.message),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
    } on SocketException catch (e) {
      toastification.show(
        context: context,
        title: Text(e.message),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
    } catch (e) {
      log(e.toString());
      toastification.show(
        context: context,
        title: const Text('Something went wrong'),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
    }
  }
}
