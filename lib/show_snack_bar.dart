// import 'package:chat_app1/constants/colors.dart';
// import 'package:chat_app1/pages/forget_password_page.dart';
// import 'package:chat_app1/pages/sign_up_page.dart';
// import 'package:chat_app1/services/authentication_service.dart';
// import 'package:chat_app1/widgets/email_text_field.dart';
// import 'package:chat_app1/widgets/password_text_field.dart';
// import 'package:chat_app1/widgets/private_progress_indicator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   bool isLoading = false;
//   bool isEmailCorrect = false;
//   bool isPasswordCorrect = false;
//   bool isObscureText = true;
//   String? email = "";
//   String? password = "";

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;
//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController();
//     _passwordController = TextEditingController();
//   }

//   String? emailValidationMehod(String? value) {
//     if (value!.isEmpty) {
//       return "This place can't be empty";
//     }
//     if (!value.contains("@gmail.com")) {
//       return "Email must be like this exp@gmail.com";
//     }
//     return null;
//   }

//   void emailOnSave(String? value) {
//     email = value;
//   }

//   String? passwordValidationMehod(String? value) {
//     if (value!.isEmpty) {
//       return "This place can't be empty";
//     }
//     if (value.length < 8) {
//       return "The password must be more than or equal 8 characters";
//     }
//     return null;
//   }

//   void passwordOnSave(String? value) {
//     password = value;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: kPrimaryColor,
//         body: isLoading
//             ? const PrivateProgessIndicator()
//             : SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: SafeArea(
//                     child: Column(
//                       children: [
//                         Column(
//                           children: [
//                             Center(
//                               child: Text(
//                                 "Welcome Back",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 42,
//                                     color: textColor),
//                               ),
//                             ),
//                             const CircleAvatar(
//                               radius: 125,
//                               backgroundImage:
//                                   AssetImage("assets/images/Login.gif"),
//                             ),
//                             const SizedBox(
//                               height: 35,
//                             ),
//                             Center(
//                               child: Text(
//                                 "Enter your account to login",
//                                 style:
//                                     TextStyle(color: textColor, fontSize: 24),
//                               ),
//                             )
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 25),
//                           child: Column(
//                             children: [
//                               EmailTextField(
//                                   emailValidationMehod: emailValidationMehod,
//                                   emailOnSave: emailOnSave),
//                               const SizedBox(
//                                 height: 15,
//                               ),
//                               PasswordTextField(
//                                   passwordOnSave: passwordOnSave,
//                                   passwordValidationMehod:
//                                       passwordValidationMehod),
//                               const SizedBox(
//                                 height: 30,
//                               ),
//                               ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: kSecondaryColor,
//                                       fixedSize: const Size(360, 70)),
//                                   onPressed: () async {
//                                     if (_formKey.currentState!.validate()) {
//                                       _formKey.currentState!.save();
//                                       setState(() {
//                                         isLoading = true;
//                                       });
//                                       try {
//                                         await AuthenticationService().login(
//                                             context,
//                                             email: email!,
//                                             password: password!);
//                                       } on FirebaseException catch (e) {
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                         String errorMessage = "";
//                                         print(e.code);
//                                         if (e.code == "user-not-found") {
//                                           errorMessage =
//                                               "No user found for that email.";
//                                         } else if (e.code ==
//                                             "invalid-credential") {
//                                           print("Wrong account");
//                                           errorMessage = "Wrong account";
//                                         } else if (e.code == "invalid-email")
//                                           errorMessage = "Wrong email";
//                                         if (errorMessage.isNotEmpty) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(SnackBar(
//                                                   backgroundColor:
//                                                       kSecondaryColor,
//                                                   content: Text(
//                                                     errorMessage,
//                                                     style: TextStyle(
//                                                         fontSize: 22,
//                                                         color: kPrimaryColor),
//                                                   )));
//                                         }
//                                       } catch (e) {
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                         String errorMessage =
//                                             "There is an error, try again later";
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(SnackBar(
//                                                 content: Text(errorMessage)));
//                                       }
//                                     }
//                                   },
//                                   child: const Text(
//                                     "Login",
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 28),
//                                   ))
//                             ],
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 30,
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         const ForgetPasswordPage()));
//                           },
//                           child: Text(
//                             "Forget password?",
//                             style:
//                                 TextStyle(color: kSecondaryColor, fontSize: 21),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 50,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text(
//                               "Don't have an account?  ",
//                               style:
//                                   TextStyle(color: Colors.black, fontSize: 18),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             const SignupPage()));
//                               },
//                               child: Text("Sign Up",
//                                   style: TextStyle(
//                                       color: kSecondaryColor, fontSize: 19)),
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ));
//   }
// }
