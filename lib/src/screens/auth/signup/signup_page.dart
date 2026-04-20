import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_state.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/bloc/signup_cubit.dart";

import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
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

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textEditingControllerName.dispose();
    textEditingControllerAge.dispose();
    textEditingControllerPhoneNumber.dispose();
    textEditingControllerPassword.dispose();
    textEditingControllerConfirmPassword.dispose();
    pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SignupCubit();
        if (widget.userInfoModel != null) {
          cubit.updateGender(widget.userInfoModel?.gender);
          cubit.updateDivision(widget.userInfoModel?.division);
          cubit.updateDistrict(widget.userInfoModel?.district);
          cubit.updateThana(widget.userInfoModel?.thana);
        }
        return cubit;
      },
      child: Scaffold(
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
                                widget.userInfoModel == null
                                    ? "Create an Account"
                                    : "Update Profile",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: MyAppColors.primaryColor,
                                    ),
                              ),
                              const Gap(5),
                              Text(
                                widget.userInfoModel == null
                                    ? "Please fill the information to sign up"
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
                                  autofillHints: const [AutofillHints.name],
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: textEditingControllerName,
                                  decoration: textFieldInputDecoration(
                                    hint: "type your name here...",
                                    prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        color: Colors.grey),
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: textEditingControllerAge,
                                  decoration: textFieldInputDecoration(
                                    hint: "type your age here...",
                                    prefixIcon: const Icon(Icons.cake_outlined,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const Gap(10),
                              getTitlesForFields(
                                title: "Gender",
                                isFieldRequired: true,
                              ),
                              const Gap(5),
                              BlocBuilder<SignupCubit, SignupState>(
                                builder: (context, state) {
                                  return customTextFieldDecoration(
                                    textFormField: DropdownButtonFormField<String>(
                                      value: state.gender,
                                      decoration: textFieldInputDecoration(
                                        hint: "type your gender here...",
                                        prefixIcon: const Icon(Icons.wc_outlined,
                                            color: Colors.grey),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Male",
                                          child: Text("Male"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Female",
                                          child: Text("Female"),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        context.read<SignupCubit>().updateGender(value);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select your gender";
                                        }
                                        return null;
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                    ),
                                  );
                                },
                              ),
                              const Gap(10),
                              getTitlesForFields(
                                title: "Address",
                                isFieldRequired: true,
                              ),
                              const Gap(5),
                              const _AddressSelectionWidget(),
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
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your phone number";
                                      }
                                      if (value.length != 11 &&
                                          value.length != 14) {
                                        return "Please enter a valid phone number";
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
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
                                    autofillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                    onEditingComplete: () =>
                                        TextInput.finishAutofillContext(),
                                    decoration: textFieldInputDecoration(
                                      hint: "type your password here...",
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: Colors.grey),
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
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
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
                                    controller:
                                        textEditingControllerConfirmPassword,
                                    autofillHints: const [AutofillHints.newPassword],
                                    decoration: textFieldInputDecoration(
                                      hint: "type your confirm password here...",
                                      prefixIcon: const Icon(Icons.lock_rounded,
                                          color: Colors.grey),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your confirm password";
                                      }
                                      if (value !=
                                          textEditingControllerPassword.text) {
                                        return "Password does not match";
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
                                  ),
                                ),
                              const Gap(10),
                              const Gap(15),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, authState) {
                                    return ElevatedButton(
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
                                          
                                          final signupState = context.read<SignupCubit>().state;
                                          final authCubit = context.read<AuthCubit>();

                                          Map<String, dynamic> signupData = {
                                            "name": textEditingControllerName.text,
                                            "mobile":
                                                textEditingControllerPhoneNumber.text,
                                            "password":
                                                textEditingControllerPassword.text,
                                            "age": int.parse(
                                                textEditingControllerAge.text),
                                            "division": signupState.choosenDivision,
                                            "district": signupState.choosenDistrict,
                                            "upazila": signupState.choosenThana,
                                            "gender": signupState.gender,
                                          };

                                          final success =
                                              await authCubit.signup(signupData);

                                          if (success) {
                                            toastification.show(
                                              context: context,
                                              title: const Text("Signup Successful"),
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
                                      child: authState is AuthLoading 
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              widget.userInfoModel == null
                                                  ? "Sign up"
                                                  : "Save changes",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    );
                                  },
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
                                        context.goNamed(Routes.loginRoute);
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressSelectionWidget extends StatelessWidget {
  const _AddressSelectionWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        String? choosenDivision = state.choosenDivision;
        String? choosenDistrict = state.choosenDistrict;

        List<String> dvision = divisionDistrictThana.keys.toList();
        List<String> district = choosenDivision != null 
            ? (divisionDistrictThana[choosenDivision]?.keys.toList() ?? []) 
            : [];
        List<String> thana = (choosenDivision != null && choosenDistrict != null)
            ? (divisionDistrictThana[choosenDivision]?[choosenDistrict] ?? [])
            : [];

        return Column(
          children: [
            customTextFieldDecoration(
              textFormField: DropdownButtonFormField<String>(
                value: choosenDivision,
                decoration: textFieldInputDecoration(
                  hint: "Select Division",
                  prefixIcon: const Icon(Icons.map_outlined, color: Colors.grey),
                ),
                items: dvision
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  final cubit = context.read<SignupCubit>();
                  cubit.updateDivision(value);
                  cubit.updateDistrict(null);
                  cubit.updateThana(null);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select your division";
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            const Gap(5),
            customTextFieldDecoration(
              textFormField: DropdownButtonFormField<String>(
                value: choosenDistrict,
                decoration: textFieldInputDecoration(
                  hint: "Select District",
                  prefixIcon: const Icon(Icons.location_city_outlined,
                      color: Colors.grey),
                ),
                items: district
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  final cubit = context.read<SignupCubit>();
                  cubit.updateDistrict(value);
                  cubit.updateThana(null);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select your district";
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            const Gap(5),
            customTextFieldDecoration(
              textFormField: DropdownButtonFormField<String>(
                value: state.choosenThana,
                decoration: textFieldInputDecoration(
                  hint: "Select Upazila",
                  prefixIcon:
                      const Icon(Icons.my_location_outlined, color: Colors.grey),
                ),
                items: thana
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  context.read<SignupCubit>().updateThana(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select your thana";
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ],
        );
      },
    );
  }
}
