import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/pages/login_page.dart';
import 'package:student_attendance/pages/doctor_subjects_page.dart';
import 'package:intl/intl.dart'; // Import the intl package

import '../helper/my_show_dialog_function.dart';
import '../helper/tansitions.dart';
import '../models/user_model.dart';
import '../pages/student_subjects_page.dart';

class AuthenticationService {
  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference subjectsCollectionReference =
      FirebaseFirestore.instance.collection("Subjects");

  CollectionReference usersCollectionReference =
      FirebaseFirestore.instance.collection("Users");

  CollectionReference qrCodesCollectionReference =
      FirebaseFirestore.instance.collection("QRCodes");

  Future<void> signUp(BuildContext context,
      {required String name,
      required String email,
      required String password,
      required String userType,
      String? sectionNumber}) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // First store the user data in Firebase
    try {
      UserModel userModel = UserModel(
        name: name,
        email: auth.currentUser!.email!,
        userType: userType,
        userSubjects: [],
        sectionNumber: sectionNumber,
      );
      await usersCollectionReference
          .doc(auth.currentUser!.email)
          .set(userModel.toJson());
    } on FirebaseException catch (e) {
      print("Error storing user data: ${e.message}");
      rethrow;
    }

    // Then handle email verification
    if (!userCredential.user!.emailVerified) {
      // Show the banner first
      final materialBanner = MaterialBanner(
        elevation: 0,
        surfaceTintColor: kSecondaryColor,
        shadowColor: kSecondaryColor,
        backgroundColor: kPrimaryColor,
        dividerColor: kSecondaryColor,
        forceActionsBelow: true,
        content: SizedBox(
          height: 150,
          child: AwesomeSnackbarContent(
            color: kSecondaryColor,
            title: 'Welcome To Our Community',
            message:
                'Your Account will be created successfully after verification.',
            titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold),
            messageTextStyle: TextStyle(
                overflow: TextOverflow.visible,
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500),
            contentType: ContentType.success,
            inMaterialBanner: true,
          ),
        ),
        actions: const [SizedBox.shrink()],
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showMaterialBanner(
          materialBanner,
        );
      await userCredential.user!.sendEmailVerification();
      await myShowDialogFunction(
        context,
        "please verify your email",
        pageToGo: LoginPage.id, // This will clear the stack when OK is pressed
      );
      return; // Return early to prevent showing the banner and additional navigation
    }

    // If already verified (unlikely), just show the banner and go to login
    final materialBanner = MaterialBanner(
      elevation: 0,
      surfaceTintColor: kSecondaryColor,
      shadowColor: kSecondaryColor,
      backgroundColor: kPrimaryColor,
      dividerColor: kSecondaryColor,
      forceActionsBelow: true,
      content: SizedBox(
        height: 150,
        child: AwesomeSnackbarContent(
          color: kSecondaryColor,
          title: 'Welcome To Our Community',
          message:
              'Your Account will be created successfully after verification.',
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold),
          messageTextStyle: TextStyle(
              overflow: TextOverflow.visible,
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500),
          contentType: ContentType.success,
          inMaterialBanner: true,
        ),
      ),
      actions: const [SizedBox.shrink()],
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        materialBanner,
      );
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

  Future<void> login(BuildContext context,
      {required String email, required String password}) async {
    UserCredential userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user!;
    if (user.emailVerified) {
      List<UserModel> usersModel = await AuthenticationService().getUsers();
      for (UserModel userModel in usersModel) {
        if (userModel.email == user.email) {
          if (userModel.userType == "Student") {
            Navigator.pushReplacement(
                context,
                CustomScaleTransition(StudentSubjectsPage(student: userModel),
                    alignment: Alignment.center));
          } else if (userModel.userType == "Doctor") {
            Navigator.pushReplacement(
                context,
                CustomScaleTransition(const DoctorSubjectsPage(),
                    alignment: Alignment.center));
          }
        }
      }
      // Navigator.pushReplacementNamed(context, SubjectsPage.id);
      // Navigator.pushReplacement(
      //     context,
      //     CustomScaleTransition(const DoctorSubjectsPage(),
      //         alignment: Alignment.center));
    } else if (!user.emailVerified) {
      await myShowDialogFunction(
        context,
        "please verify your email",
        pageToGo: LoginPage.id, // This will clear the stack when OK is pressed
      );
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      print("Attempting to send password reset email to: $email");

      // Validate email format before sending
      if (!email.contains('@')) {
        // Show error for invalid email format using AwesomeDialog
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            headerAnimationLoop: false,
            title: 'Invalid Email',
            titleTextStyle: TextStyle(
              color: kSecondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
            desc: 'Please enter a valid email address.',
            descTextStyle: TextStyle(fontSize: 16.sp),
            btnOkOnPress: () {},
            btnOkColor: kSecondaryColor,
            btnOkText: 'OK',
          ).show();
        }
        return;
      }

      // Send the reset email
      await auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent successfully to: $email");

      // Show success dialog using AwesomeDialog
      if (context.mounted) {
        print("Showing success dialog");

        // Use AwesomeDialog for better visual feedback
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Password Reset',
          titleTextStyle: TextStyle(
            color: kSecondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          desc:
              'A password reset link has been sent to your email address. Please check your inbox and follow the instructions to reset your password.',
          descTextStyle: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold),
          btnOkOnPress: () {
            print("OK button pressed");
            // Navigate to login page
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.id,
              (route) => false,
            );
          },
          btnOkColor: kSecondaryColor,
          btnOkText: 'OK',
          buttonsTextStyle: TextStyle(
            fontSize: 17.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          dismissOnTouchOutside: false,
        ).show();
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      String errorMessage = "Failed to send password reset email.";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email address.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many password reset attempts. Please try again later or contact support if you need immediate assistance.";
      }

      if (context.mounted) {
        print("Showing error dialog: $errorMessage");

        // Show error using AwesomeDialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          titleTextStyle: TextStyle(
            color: kSecondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          desc: errorMessage,
          descTextStyle: TextStyle(fontSize: 16.sp),
          btnOkOnPress: () {},
          btnOkColor: kSecondaryColor,
          btnOkText: 'OK',
        ).show();
      }
    } catch (e) {
      print("General exception: $e");
      if (context.mounted) {
        print("Showing general error dialog");

        // Show error using AwesomeDialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          titleTextStyle: TextStyle(
            color: kSecondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          desc: "An error occurred. Please try again later.",
          descTextStyle: TextStyle(fontSize: 16.sp),
          btnOkOnPress: () {},
          btnOkColor: kSecondaryColor,
          btnOkText: 'OK',
        ).show();
      }
    }
  }

  void addSubject(SubjectModel subjectModel) async {
    DocumentReference docRef = subjectsCollectionReference.doc();
    subjectModel.subjectCode = docRef.id;
    await docRef.set(subjectModel.toJson());

    addSubjectToUser(subjectModel.subjectCode!);
  }

  void addUser(UserModel userModel) {
    usersCollectionReference.doc(userModel.email).set(userModel.toJson());
  }

  Stream<QuerySnapshot<Object?>> getSubjects() {
    return subjectsCollectionReference.orderBy("subjectName").snapshots();
  }

  Future<List<UserModel>> getUsers() async {
    QuerySnapshot querySnapshot = await usersCollectionReference.get();
    List<UserModel> usersModel = querySnapshot.docs.map((doc) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
    return usersModel;
  }

  Future<UserModel> getUserByEmail(String email) async {
    DocumentSnapshot doc = await usersCollectionReference.doc(email).get();
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<DocumentSnapshot<Object?>> getUserDataUsingEmil(String email) async {
    // First try to get the document directly by email as ID
    DocumentSnapshot<Object?> doc =
        await usersCollectionReference.doc(email).get();

    // If the document doesn't exist with email as ID, try to query by email field
    if (!doc.exists) {
      print(
          "Document not found with ID $email, trying to query by email field");
      QuerySnapshot querySnapshot = await usersCollectionReference
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Found user by email field query: $email");
        return querySnapshot.docs.first;
      }
    } else {
      print("Found user with ID $email");
    }

    return doc;
  }

  Future<void> deleteSubject(String subjectID) async {
    await subjectsCollectionReference.doc(subjectID).delete();
  }

  Future<void> deleteUser(String email) async {
    await usersCollectionReference.doc(email).delete();
  }

  Future<void> updateSubject(SubjectModel subjectModel) async {
    await subjectsCollectionReference.doc(subjectModel.subjectCode).update({
      "subjectName": subjectModel.subjectName,
      "subjectCode": subjectModel.subjectCode,
      "teacherName": subjectModel.profEmail,
      "totalLectures": subjectModel.totalLectures,
      "lecturesMark": subjectModel.lecturesMark,
    });
  }

  void addUserToSubject(String subjectCode) {
    subjectsCollectionReference.doc(subjectCode).update({
      "studentList": FieldValue.arrayUnion([auth.currentUser!.email])
    });
    updateStudentAttendance(subjectCode, auth.currentUser!.email!, null);
  }

  void updateStudentAttendance(
      String subjectCode, String studentEmail, String? dateTime) async {
    DocumentSnapshot subjectDoc =
        await subjectsCollectionReference.doc(subjectCode).get();
    List<dynamic> studentAttendance = subjectDoc['studentAttendance'] ?? [];

    // If dateTime is null, use today's date in standard format
    String formattedDate;
    if (dateTime == null) {
      DateTime now = DateTime.now();
      // Use standard YYYY-MM-DD format
      formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    } else {
      // If a date was provided, standardize it if needed
      formattedDate = dateTime;
      if (dateTime.contains('/')) {
        try {
          final parts = dateTime.split('/');
          if (parts.length == 3) {
            final day = parts[0].padLeft(2, '0');
            final month = parts[1].padLeft(2, '0');
            final year = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
            formattedDate = "$year-$month-$day";
            print("Converted date format from $dateTime to $formattedDate");
          }
        } catch (e) {
          print("Error converting date format: $e");
        }
      }
    }

    print("Recording attendance for $studentEmail on date $formattedDate");

    bool studentFound = false;
    for (var student in studentAttendance) {
      if (student.containsKey(studentEmail)) {
        studentFound = true;
        // Always add the date, even if dateTime was null (we created a formatted date)
        student[studentEmail]!.add(formattedDate);
        break;
      }
    }

    if (!studentFound) {
      studentAttendance.add({
        studentEmail: [formattedDate]
      });
    }

    subjectsCollectionReference
        .doc(subjectCode)
        .update({"studentAttendance": studentAttendance});

    // Also update the attendanceDates array in the subject document
    DocumentSnapshot subjectDocCheck =
        await subjectsCollectionReference.doc(subjectCode).get();
    if (subjectDocCheck.exists) {
      final data = subjectDocCheck.data() as Map<String, dynamic>;
      List<String> attendanceDates = [];

      if (data.containsKey('attendanceDates') &&
          data['attendanceDates'] != null) {
        attendanceDates = List<String>.from(data['attendanceDates']);
      }

      // Add today's date to attendanceDates if not already there
      if (!attendanceDates.contains(formattedDate)) {
        attendanceDates.add(formattedDate);
        await subjectsCollectionReference.doc(subjectCode).update({
          'attendanceDates': attendanceDates,
        });
        print('Added attendance date to subject: $formattedDate');
      }
    }
  }

  void removeUserFromSubject(String subjectCode) {
    subjectsCollectionReference.doc(subjectCode).update({
      "studentList": FieldValue.arrayRemove([auth.currentUser!.email])
    });
  }

  void addSubjectToUser(String subjcetCode) {
    usersCollectionReference.doc(auth.currentUser!.email).update({
      "userSubjects": FieldValue.arrayUnion([subjcetCode])
    });
  }

  void removeSubjectFromUser(String subjcetCode) {
    usersCollectionReference.doc(auth.currentUser!.email).update({
      "userSubjects": FieldValue.arrayRemove([subjcetCode])
    });
  }

  void saveQRCodeToFirebase(String qrCode, String subjectCode) async {
    DocumentReference docRef = qrCodesCollectionReference.doc(subjectCode);
    await docRef.set({
      'qrCodes': FieldValue.arrayUnion([
        {
          'qrCode': qrCode,
          'timestamp': Timestamp.now(),
        }
      ])
    });
  }

  Future<String> getQRCode(String subjectCode) async {
    String qrCodes;
    DocumentSnapshot doc =
        await qrCodesCollectionReference.doc(subjectCode).get();
    qrCodes = doc['qrCodes'][0]['qrCode'];

    return qrCodes;
  }

  Future<bool> isStudentAttended(String subjectCode, String studentEmail,
      [String? specificDate]) async {
    try {
      print(
          "isStudentAttended called for subject: $subjectCode, student: $studentEmail, date: $specificDate");

      DocumentSnapshot subjectDoc =
          await subjectsCollectionReference.doc(subjectCode).get();

      if (!subjectDoc.exists) {
        print('Subject document does not exist');
        return false;
      }

      Map<String, dynamic> subjectData =
          subjectDoc.data() as Map<String, dynamic>;

      if (!subjectData.containsKey('studentAttendance')) {
        print('studentAttendance field does not exist in subject document');
        return false;
      }

      List<dynamic> studentAttendance = subjectData['studentAttendance'];

      // Get current date or use specified date in YYYY-MM-DD format
      String currentDate =
          specificDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      print('Checking attendance for date: $currentDate');

      // Check if the date is in the future
      DateTime checkDate = DateFormat('yyyy-MM-dd').parse(currentDate);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      if (checkDate.isAfter(today)) {
        print('Checking attendance for a future date: $currentDate');
        // For future dates, no one has attended yet
        return false;
      }

      // Debug the attendance records
      print("Student attendance records: $studentAttendance");

      for (var student in studentAttendance) {
        if (student.containsKey(studentEmail)) {
          List<dynamic> attendanceDates = student[studentEmail];
          print(
              "Found attendance dates for student $studentEmail: $attendanceDates");

          for (var date in attendanceDates) {
            String standardDate = date.toString();

            // Check if the date is in DD/MM/YYYY format and convert it
            if (standardDate.contains('/')) {
              try {
                final parts = standardDate.split('/');
                if (parts.length == 3) {
                  final day = parts[0].padLeft(2, '0');
                  final month = parts[1].padLeft(2, '0');
                  final year =
                      parts[2].length == 2 ? '20${parts[2]}' : parts[2];
                  standardDate = "$year-$month-$day";
                  print("Converted date format from $date to $standardDate");
                }
              } catch (e) {
                print("Error converting date format: $e");
              }
            }

            // Compare with the requested date
            print("Comparing dates: '$standardDate' == '$currentDate'");
            if (standardDate == currentDate) {
              print('Student $studentEmail is present on $currentDate');
              return true;
            }
          }

          print('Student $studentEmail is absent on $currentDate');
          return false;
        }
      }

      print('Student $studentEmail not found in attendance records');
      return false;
    } catch (e) {
      print('Error checking attendance: $e');
      return false;
    }
  }
}
