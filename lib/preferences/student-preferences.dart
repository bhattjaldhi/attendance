import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';

class StudentPreferences {
  static var KEY_STUDENT_ID = "student-id";
  static var KEY_STUDENT_NAME = "student-name";
  static var KEY_STUDENT_EMAIL = "student-email";
  static var KEY_STUDENT_DEPTID = "student-department-id";
  static var KEY_STUDENT_ENROLLMENT = "student-enrollment";
  static var KEY_STUDENT_ORGANIZATION_ID = "student-organization-id";

  storeDataAtLogin(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(KEY_STUDENT_ID, data['data']['id']);
    prefs.setString(KEY_STUDENT_NAME, data['data']['name']);
    prefs.setString(KEY_STUDENT_EMAIL, data['data']['email']);
    prefs.setInt(KEY_STUDENT_DEPTID, data['data']['department_id']);
    prefs.setString(KEY_STUDENT_ENROLLMENT, data['data']['enrollment']);
    prefs.setInt(KEY_STUDENT_ORGANIZATION_ID, data['data']['organization_id']);
  }
  
  static Future<int> getStudentId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_STUDENT_ID);
  }
}
