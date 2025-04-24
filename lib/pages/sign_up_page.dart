import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../colors.dart';
import '../models/user_model.dart';
import '../services/authentication_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/email_text_field_widget.dart';
import '../widgets/my_custom_widget.dart';
import '../widgets/name_text_field_widget.dart';
import '../widgets/password_text_field_widget.dart';
import '../widgets/private_progress_indicator.dart';
import '../widgets/theme_mode_button.dart';
import '../widgets/welcome_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const String id = "sign_up_page";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading = false;
  // String? username = "";
  String? name = "";
  String? email = "";

  String? password = "";

  String? confirmedPassword = "";
  final List userTypes = ["Doctor", "Student"];

  String selectedUserType = "Student";

  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // void usernameOnSave(String? value) {
  //   username = value;
  // }

  // String? usernameValidationMethod(String? value) {
  //   if (value!.isEmpty) {
  //     return "This place can't be empty";
  //   }
  //   return null;
  // }

  void nameOnSave(String? value) {
    name = value;
  }

  String? nameValidationMethod(String? value) {
    if (value!.isEmpty) {
      return "This place can't be empty";
    }
    return null;
  }

  void emailOnSave(String? value) {
    email = value;
  }

  String? emailValidationMethod(String? value) {
    if (value!.isEmpty) {
      return "This place can't be empty";
    }
    if (!value.contains("@gmail.com")) {
      return "Email must be like this exp@gmail.com";
    }
    return null;
  }

  void passwordOnSave(String? value) {
    password = value;
  }

  String? passwordValidationMethod(String? value) {
    if (value!.isEmpty) {
      return "This place can't be empty";
    }
    if (value.length < 8) {
      return "The password must be more than or equal 8 characters";
    }
    _signUpFormKey.currentState!.save();
    if (password != confirmedPassword) {
      password = "";
      confirmedPassword = "";
      return "The two passwords don't match";
    }
    return null;
  }

  void confirmedPasswordOnSave(String? value) {
    confirmedPassword = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimaryColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [ThemeModeButton()],
      ),
      body: isLoading
          ? const PrivateProgessIndicator()
          : SafeArea(
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: _signUpFormKey,
                child: Padding(
                  padding: EdgeInsets.all(8.0.sp),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const MyCustomWidget(),
                        const WelcomeWidget(
                          welcomeMessage: "Welcome to our community",
                        ),
                        // UsernameWidget(
                        //     usernameOnSave: usernameOnSave,
                        //     usernameValidationMethod: usernameValidationMethod),
                        SizedBox(
                          height: 20.h,
                        ),
                        NameTextFieldWidget(
                            nameOnSave: nameOnSave,
                            nameValidationMethod: nameValidationMethod),
                        SizedBox(
                          height: 20.h,
                        ),
                        EmailTextFieldWidget(
                            emailOnSave: emailOnSave,
                            emailValidationMethod: emailValidationMethod),
                        SizedBox(
                          height: 20.h,
                        ),
                        PasswordTextFieldWidget(
                            passwordOnSave: passwordOnSave,
                            passwordValidationMethod: passwordValidationMethod,
                            hintText: "Enter your password",
                            labelText: "Password"),
                        SizedBox(
                          height: 20.h,
                        ),
                        PasswordTextFieldWidget(
                            passwordOnSave: confirmedPasswordOnSave,
                            passwordValidationMethod: passwordValidationMethod,
                            hintText: "Enter your password again",
                            labelText: "Confirm Password"),
                        SizedBox(
                          height: 20.h,
                        ),
                        ToggleSwitch(
                          minWidth: double.infinity,
                          initialLabelIndex: 1,
                          cornerRadius: 12.r,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey,
                          inactiveFgColor: Colors.white,
                          animate: true,
                          fontSize: 25.sp,
                          iconSize: 25.sp,
                          totalSwitches: 2,
                          centerText: true,
                          minHeight: 45.h,
                          animationDuration: 400,
                          curve: Curves.decelerate,
                          labels: const [' Doctor', 'Student'],
                          icons: const [
                            FontAwesomeIcons.personChalkboard,
                            FontAwesomeIcons.userGraduate
                          ],
                          activeBgColors: const [
                            [Colors.blue],
                            [Colors.pink]
                          ],
                          onToggle: (index) {
                            selectedUserType = userTypes[index!];
                            // setState(() {});
                            // print('switched to: $index');
                          },
                        ),
                        // ToggleSwitch(
                        //   fontSize: 20,
                        //   dividerColor: Colors.blueGrey,
                        //   cornerRadius: 25.0,
                        //   icons: const [Icons.male, Icons.female],
                        //   iconSize: 35,
                        //   minWidth: 170,
                        //   minHeight: 55,
                        //   initialLabelIndex: 0,
                        //   totalSwitches: 2,
                        //   animate: true,
                        //   //linearToEaseOut - fastOutSlowIn
                        //   curve: Curves.fastOutSlowIn,
                        //   activeBgColors: [
                        //     const [Colors.blue],
                        //     [kSecondaryColor]
                        //   ],
                        //   activeFgColor: Colors.white,
                        //   labels: const ["Male", "Female"],
                        //   onToggle: (index) {
                        //     type = maleOrFemale[index!];
                        //   },
                        // ),
                        SizedBox(
                          height: 30.h,
                        ),
                        CustomButton(
                          text: "Sign Up",
                          onTap: () async {
                            if (_signUpFormKey.currentState!.validate()) {
                              _signUpFormKey.currentState!.save();
                              if (password == confirmedPassword) {
                                try {
                                  String sectionNumber = "";

                                  if (selectedUserType == "Student") {
                                    while (sectionNumber.isEmpty) {
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Enter Section Number"),
                                            content: TextField(
                                              style: TextStyle(fontSize: 18.sp),
                                              onChanged: (value) {
                                                sectionNumber = value;
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Section Number",
                                                hintStyle:
                                                    TextStyle(fontSize: 18.sp),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5.h,
                                                      horizontal: 10.w),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.r),
                                                      color: Colors.blue),
                                                  child: Text("OK",
                                                      style: TextStyle(
                                                          fontSize: 22.sp,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await AuthenticationService().signUp(context,
                                      email: email!,
                                      password: password!,
                                      name: name!,
                                      userType: selectedUserType);
                                  AuthenticationService().addUser(UserModel(
                                      name: name!,
                                      email: email!,
                                      userType: selectedUserType,
                                      userSubjects: [],
                                      sectionNumber: sectionNumber));
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });

                                  late String errorMessage;
                                  if (e.toString() ==
                                      "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
                                    errorMessage =
                                        "The account already exists for that email.";
                                  } else if (e.toString() == "weak-password") {
                                    errorMessage =
                                        "The password provided is too weak.";
                                  } else {
                                    errorMessage = e.toString();
                                  }
                                  myShowDialogFunction(context, errorMessage);
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  String errorMessage =
                                      "There is an error, try again later";
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)));
                                }
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                    color: kSecondaryColor),
                              ),
                            )
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

  Future<dynamic> myShowDialogFunction(
      BuildContext context, String errorMessage) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kPrimaryColor,
            title: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      height: 40,
                      width: 55,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kSecondaryColor),
                      child: Center(
                        child: Text(
                          "Ok",
                          style: TextStyle(color: kTextColor),
                        ),
                      )))
            ],
          );
        });
  }
}
