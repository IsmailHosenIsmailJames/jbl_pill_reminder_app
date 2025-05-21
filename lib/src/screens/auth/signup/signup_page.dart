import "dart:convert";
import "dart:developer";
import "dart:io";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:hive/hive.dart";
import "package:http/http.dart" as http;
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/controller/signip_page_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:http_status_code/http_status_code.dart";
import "package:toastification/toastification.dart";

import "../../../resources/division_district_thana.dart";
import "../../../theme/colors.dart";
import "../../../widgets/intro_pages.dart";
import "model/signup_models.dart";

class SignupPage extends StatefulWidget {
  final UserInfoModel? userInfoModel;
  const SignupPage({super.key, this.userInfoModel});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  PageController pageController = PageController();

  late TextEditingController textEditingControllerName =
      TextEditingController(text: widget.userInfoModel?.name);
  late TextEditingController textEditingControllerAge =
      TextEditingController(text: widget.userInfoModel?.age.toString());
  late TextEditingController textEditingControllerPhoneNumber =
      TextEditingController(text: widget.userInfoModel?.phone);
  late TextEditingController textEditingControllerPassword =
      TextEditingController(text: widget.userInfoModel?.password);
  late TextEditingController textEditingControllerConfirmPassword =
      TextEditingController(
    text: widget.userInfoModel?.password,
  );

  final formKey = GlobalKey<FormState>();

  final SignupPageController signupPageController =
      Get.put(SignupPageController());

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    signupPageController.gender.value = widget.userInfoModel?.gender;
    signupPageController.choosenDivision.value = widget.userInfoModel?.division;
    signupPageController.choosenDistrict.value = widget.userInfoModel?.district;
    signupPageController.choosenThana.value = widget.userInfoModel?.thana;

    super.initState();
  }

  @override
  void dispose() {
    textEditingControllerName.dispose();
    textEditingControllerAge.dispose();
    textEditingControllerPhoneNumber.dispose();
    textEditingControllerPassword.dispose();
    textEditingControllerConfirmPassword.dispose();
    super.dispose();
  }

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
                  Text(
                    widget.userInfoModel == null ? "Sign In" : "Update Profile",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    widget.userInfoModel == null
                        ? "Please fill the information to sign in"
                        : "Please change information to update your profile",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Gap(10),
                  getTitlesForFields(
                    title: "Name",
                    isFieldRequired: true,
                  ),
                  const Gap(5),
                  customTextFieldDecoration(
                    textFormField: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: textEditingControllerName,
                      decoration: textFieldInputDecoration(
                        hint: "type your name here...",
                      ),
                    ),
                  ),
                  const Gap(10),
                  getTitlesForFields(
                    title: "Age",
                    isFieldRequired: true,
                  ),
                  const Gap(5),
                  customTextFieldDecoration(
                    textFormField: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your age";
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return "Please enter a valid age";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: textEditingControllerAge,
                      decoration: textFieldInputDecoration(
                        hint: "type your age here...",
                      ),
                    ),
                  ),
                  const Gap(10),
                  getTitlesForFields(
                    title: "Gender",
                    isFieldRequired: true,
                  ),
                  const Gap(5),
                  customTextFieldDecoration(
                    textFormField: DropdownButtonFormField(
                      value: signupPageController.gender.value,
                      decoration: textFieldInputDecoration(
                        hint: "type your gender here...",
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: "Male",
                          child: Text("Male"),
                        ),
                        const DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                      ],
                      onChanged: (value) {
                        signupPageController.gender.value = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select your gender";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const Gap(10),
                  getTitlesForFields(
                    title: "Address",
                    isFieldRequired: true,
                  ),
                  const Gap(5),
                  Obx(() {
                    String? choosenDivision =
                        signupPageController.choosenDivision.value;
                    String? choosenDistrict =
                        signupPageController.choosenDistrict.value;
                    List<String> dvision = divisionDistrictThana.keys.toList();
                    List<String> district =
                        divisionDistrictThana[choosenDivision]?.keys.toList() ??
                            [];
                    List<String> thana = divisionDistrictThana[choosenDivision]
                            ?[choosenDistrict] ??
                        [];
                    return Column(
                      children: [
                        customTextFieldDecoration(
                          textFormField: DropdownButtonFormField(
                            value: choosenDivision,
                            decoration: textFieldInputDecoration(
                                hint: "Select Division"),
                            items: dvision
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              signupPageController.choosenDivision.value =
                                  value;
                              signupPageController.choosenDistrict.value = null;
                              signupPageController.choosenThana.value = null;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select your division";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        const Gap(5),
                        customTextFieldDecoration(
                          textFormField: DropdownButtonFormField(
                            value: choosenDistrict,
                            decoration: textFieldInputDecoration(
                                hint: "Select District"),
                            items: district
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              signupPageController.choosenDistrict.value =
                                  value;
                              signupPageController.choosenThana.value = null;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select your district";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        const Gap(5),
                        customTextFieldDecoration(
                          textFormField: DropdownButtonFormField(
                            value: signupPageController.choosenThana.value,
                            decoration:
                                textFieldInputDecoration(hint: "Select Thana"),
                            items: thana
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              signupPageController.choosenThana.value = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select your thana";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                      ],
                    );
                  }),
                  const Gap(10),
                  if (widget.userInfoModel == null)
                    getTitlesForFields(
                      title: "Phone Number",
                      isFieldRequired: true,
                    ),
                  if (widget.userInfoModel == null) const Gap(5),
                  if (widget.userInfoModel == null)
                    customTextFieldDecoration(
                      textFormField: TextFormField(
                        controller: textEditingControllerPhoneNumber,
                        decoration: textFieldInputDecoration(
                          hint: "+8801xxxxxxxxx",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }
                          if (value.length != 11 && value.length != 14) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  const Gap(10),
                  if (widget.userInfoModel == null)
                    getTitlesForFields(
                      title: "Password",
                      isFieldRequired: true,
                    ),
                  if (widget.userInfoModel == null) const Gap(5),
                  if (widget.userInfoModel == null)
                    customTextFieldDecoration(
                      textFormField: TextFormField(
                        controller: textEditingControllerPassword,
                        decoration: textFieldInputDecoration(
                          hint: "type your password here...",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                    ),
                  if (widget.userInfoModel == null) const Gap(10),
                  if (widget.userInfoModel == null)
                    getTitlesForFields(
                      title: "Confirm Password",
                      isFieldRequired: true,
                    ),
                  if (widget.userInfoModel == null) const Gap(5),
                  if (widget.userInfoModel == null)
                    customTextFieldDecoration(
                      textFormField: TextFormField(
                        controller: textEditingControllerConfirmPassword,
                        decoration: textFieldInputDecoration(
                          hint: "type your confirm password here...",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your confirm password";
                          }
                          if (value != textEditingControllerPassword.text) {
                            return "Password does not match";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                    ),
                  const Gap(10),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyAppColors.primaryColor,
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await signupOrUpdate(context);
                          }
                        },
                        child: Text(
                          widget.userInfoModel == null
                              ? "Sign up"
                              : "Save changes",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  if (widget.userInfoModel == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Center(
                          child: Text("Already have an account?",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.off(
                              () => const LoginPage(),
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Gap(10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signupOrUpdate(BuildContext context) async {
    String phone = textEditingControllerPhoneNumber.text;
    if (!phone.startsWith("+88")) {
      phone = "+88$phone";
    }

    try {
      UserInfoModel userInfoModel = UserInfoModel(
        name: textEditingControllerName.text,
        age: int.parse(textEditingControllerAge.text),
        gender: signupPageController.gender.value!,
        division: signupPageController.choosenDivision.value!,
        district: signupPageController.choosenDistrict.value!,
        thana: signupPageController.choosenThana.value!,
        phone: phone,
        password: textEditingControllerPassword.text,
      );

      final http.Response? response;
      if (widget.userInfoModel == null) {
        response = await http.post(Uri.parse(signUpAPI),
            body: userInfoModel.toJson(),
            headers: {"Content-Type": "application/json"});
      } else {
        Map<String, dynamic> data = userInfoModel.toMap();
        data.remove("password");
        response = await http.put(
          Uri.parse(updateUserInfoAPI),
          body: jsonEncode(data),
          headers: {"Content-Type": "application/json"},
        );
      }

      if (response.statusCode == StatusCode.CREATED ||
          response.statusCode == StatusCode.OK) {
        log(response.body);

        if (widget.userInfoModel == null) {
          await Hive.box("user_db").put(
            "user_info",
            userInfoModel.toJson(),
          );
          toastification.show(
            context: context,
            title: const Text("Signup Success"),
            autoCloseDuration: const Duration(seconds: 2),
            type: ToastificationType.success,
          );
          Get.off(
            () => const HomeScreen(),
          );
        } else {
          await Hive.box("user_db").put(
            "user_info",
            userInfoModel.toJson(),
          );

          toastification.show(
            context: context,
            title: const Text("Update Success"),
            autoCloseDuration: const Duration(seconds: 2),
            type: ToastificationType.success,
          );
          Get.back();
        }
      } else if (response.statusCode == StatusCode.BAD_REQUEST) {
        toastification.show(
          context: context,
          title: const Text("Information is not valid"),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
        );
      } else {
        log(response.body);
        log(response.statusCode.toString());
        toastification.show(
          context: context,
          title: const Text("Signup Failed"),
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
        title: const Text("Something went wrong"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
    }
  }
}
