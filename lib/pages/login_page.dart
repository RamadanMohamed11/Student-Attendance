import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';
import '../helper/tansitions.dart';
import '../pages/about_page.dart';
import '../services/authentication_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/email_text_field_widget.dart';
import '../widgets/my_custom_widget.dart';
import '../widgets/password_text_field_widget.dart';
import '../widgets/private_progress_indicator.dart';
import '../widgets/theme_mode_button.dart';
import '../widgets/welcome_widget.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String id = 'login_page';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  String? email = "";

  String? password = "";

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [ThemeModeButton()],
      ),
      // backgroundColor: kPrimaryColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: isLoading
          ? const PrivateProgessIndicator()
          : Form(
              key: _loginFormKey,
              child: Padding(
                padding: EdgeInsets.all(8.0.sp),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.h),
                      const MyCustomWidget(),
                      const WelcomeWidget(
                        welcomeMessage: "Welcome Back",
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      EmailTextFieldWidget(
                        emailOnSave: emailOnSave,
                        emailValidationMethod: emailValidationMethod,
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      PasswordTextFieldWidget(
                        passwordOnSave: passwordOnSave,
                        passwordValidationMethod: passwordValidationMethod,
                        hintText: "Enter your password",
                        labelText: "Password",
                      ),
                      SizedBox(height: 8.h),
                      // Forgot Password Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            // Show a dialog to enter email for password reset
                            showDialog(
                              context: context,
                              builder: (context) {
                                // Get the current theme brightness
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                        Brightness.dark;
                                String resetEmail = email ?? "";
                                return AlertDialog(
                                  // Use theme-adaptive background color
                                  backgroundColor: isDarkMode
                                      ? Theme.of(context).dialogBackgroundColor
                                      : kPrimaryColor,
                                  title: Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      color: kSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Enter your email to receive a password reset link",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          // Use theme-adaptive text color
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      TextFormField(
                                        initialValue: resetEmail,
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          // Use theme-adaptive fill color
                                          fillColor: isDarkMode
                                              ? Theme.of(context)
                                                      .inputDecorationTheme
                                                      .fillColor ??
                                                  Colors.grey[800]
                                              : kTextFieldColor,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          resetEmail = value;
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          // Use theme-adaptive text color
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.black38,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kSecondaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (resetEmail.isNotEmpty) {
                                          // Get a reference to the BuildContext from the Scaffold
                                          final navigatorContext =
                                              Navigator.of(context);
                                          Navigator.pop(context);

                                          // Use the navigator context for showing dialogs
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            // Pass the root context from the Scaffold
                                            AuthenticationService()
                                                .resetPassword(
                                              navigatorContext.context,
                                              resetEmail,
                                            );
                                          });
                                        } else {
                                          // Show error if email is empty
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please enter your email address',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              backgroundColor: kSecondaryColor,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        "Reset",
                                        style: TextStyle(
                                          // Use theme-adaptive text color for the button
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: kSecondaryColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      CustomButton(
                          text: "Login",
                          onTap: () async {
                            if (_loginFormKey.currentState!.validate()) {
                              _loginFormKey.currentState!.save();
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                await AuthenticationService().login(context,
                                    email: email!, password: password!);
                              } on FirebaseException catch (e) {
                                setState(() {
                                  isLoading = false;
                                });
                                String errorMessage = "";
                                debugPrint(e.code);
                                if (e.code == "user-not-found") {
                                  errorMessage =
                                      "No user found for that email.";
                                } else if (e.code == "invalid-credential") {
                                  debugPrint("Wrong account");
                                  errorMessage = "Wrong account";
                                } else if (e.code == "invalid-email") {
                                  errorMessage = "Wrong email";
                                }
                                if (errorMessage.isNotEmpty && mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: kSecondaryColor,
                                          content: Text(
                                            errorMessage,
                                            style: TextStyle(
                                                fontSize: 22,
                                                color: kTextColor),
                                          )));
                                }
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                });
                                String errorMessage =
                                    "There is an error, try again later";
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)));
                                }
                              }
                            }
                          }),
                      SizedBox(
                        height: 15.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CustomScaleTransition(const SignUpPage(),
                                      alignment: Alignment.bottomRight));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             const SignUpPage()));
                            },
                            child: Text(
                              "Register now",
                              style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Want to know more? ",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, AboutPage.id);
                            },
                            child: Text(
                              "About Us",
                              style: TextStyle(
                                color: kSecondaryColor,
                                fontSize: 16.sp,
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
    );
  }
}
