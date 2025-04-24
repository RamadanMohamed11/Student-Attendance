import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String email;
  final String userType;
  final List<String> userSubjects;
  final String? sectionNumber;
  UserModel(
      {required this.name,
      required this.email,
      required this.userType,
      required this.userSubjects,
      required this.sectionNumber});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        name: json['name'],
        email: json['email'],
        userType: json['userType'],
        userSubjects: List<String>.from(json['userSubjects']),
        sectionNumber: json['sectionNumber']);
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "userType": userType,
        "userSubjects": userSubjects,
        "sectionNumber": sectionNumber
      };
}
