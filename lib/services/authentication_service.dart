import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/pages/login_page.dart';
import 'package:student_attendance/pages/doctor_subjects_page.dart';

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
      required String userType}) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (!userCredential.user!.emailVerified) {
      await userCredential.user!.sendEmailVerification();
      await myShowDialogFunction(
        context,
        "please verify your email",
      );
    }
    final materialBanner = MaterialBanner(
      /// need to set following properties for best effect of awesome_snackbar_content
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

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
          // to configure for material banner
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
    // try {
    //   UserModel userModel = UserModel(
    //     bio: bio ?? "",
    //     email: auth.currentUser!.email!,
    //     id: userCredential.user!.uid,
    //     name: name,
    //     profileImg: "",
    //   );
    //   usersCollectionReference
    //       .doc(userCredential.user!.uid)
    //       .set(userModel.toJson());
    // } on FirebaseException {
    //   // TODO
    //   rethrow;
    // }
    Navigator.pushReplacementNamed(context, LoginPage.id);
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
                CustomScaleTransition(const StudentSubjectsPage(),
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
      await myShowDialogFunction(context, "please verify your email");
      Navigator.pushNamed(context, LoginPage.id);
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
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
    return await usersCollectionReference.doc(email).get();
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

    bool studentFound = false;
    for (var student in studentAttendance) {
      if (student.containsKey(studentEmail)) {
        studentFound = true;
        if (dateTime != null) {
          student[studentEmail]!.add(dateTime);
        }
        break;
      }
    }

    if (!studentFound) {
      studentAttendance.add({
        studentEmail: dateTime != null ? [dateTime] : []
      });
    }

    subjectsCollectionReference
        .doc(subjectCode)
        .update({"studentAttendance": studentAttendance});
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

  Future<bool> isStudentAttended(
      String subjectCode, String studentEmail) async {
    DocumentSnapshot subjectDoc =
        await subjectsCollectionReference.doc(subjectCode).get();
    List<dynamic> studentAttendance = subjectDoc['studentAttendance'] ?? [];

    DateTime today = DateTime.now();
    String todayDate = "${today.day}/${today.month}/${today.year}";

    for (var student in studentAttendance) {
      if (student.containsKey(studentEmail)) {
        List<dynamic> attendanceDates = student[studentEmail];
        if (attendanceDates.contains(todayDate)) {
          return true;
        }
      }
    }
    return false;
  }
}
