import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String subjectName;
  String? subjectCode;
  final String profEmail;
  final String totalLectures;
  final String lecturesMark;
  // final String subjectID;
  final List<String> studentList;
  final List<Map<String, dynamic>> studentAttendance;

  SubjectModel(
      {required this.subjectName,
      this.subjectCode,
      required this.profEmail,
      required this.totalLectures,
      required this.lecturesMark,
      required this.studentList,
      required this.studentAttendance});
  factory SubjectModel.fromSnapshot(DocumentSnapshot snap) {
    var snapData = snap.data() as Map<String, dynamic>;
    return SubjectModel(
      subjectName: snapData["subjectName"],
      subjectCode: snapData["subjectCode"],
      profEmail: snapData["profEmail"],
      totalLectures: snapData["totalLectures"],
      lecturesMark: snapData["lecturesMark"],
      studentList: List<String>.from(
        snapData["studentList"],
      ),
      studentAttendance: snapData["studentAttendance"] != null
          ? List<Map<String, dynamic>>.from(snapData["studentAttendance"])
          : [],
    );
  }
  factory SubjectModel.fromDocument(DocumentSnapshot doc) {
    return SubjectModel(
      subjectName: doc["subjectName"],
      subjectCode: doc["subjectCode"],
      profEmail: doc["profEmail"],
      totalLectures: doc["totalLectures"],
      lecturesMark: doc["lecturesMark"],
      studentList: List<String>.from(doc["studentList"]),
      studentAttendance: doc["studentAttendance"] != null
          ? List<Map<String, dynamic>>.from(doc["studentAttendance"])
          : [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "subjectName": subjectName,
      "subjectCode": subjectCode,
      "profEmail": profEmail,
      "totalLectures": totalLectures,
      "lecturesMark": lecturesMark,
      "studentList": studentList,
      "studentAttendance": studentAttendance
    };
  }
}
