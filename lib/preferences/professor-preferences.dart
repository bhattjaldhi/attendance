import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
class ProfessorPreferences {
  static var KEY_PROFESSOR_ID = "professor-id";
  static var KEY_PROFESSOR_NAME = "professor-name";
  static var KEY_PROFESSOR_EMAIL = "professor-email";
  static var KEY_PROFESSOR_DEPTID = "professor-department-id";
  static var KEY_PROFESSOR_ORGANIZATION_ID = "professor-organization-id";

  storeDataAtLogin(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(KEY_PROFESSOR_ID, data['professor_detail']['id']);
    prefs.setString(KEY_PROFESSOR_NAME, data['professor_detail']['name']);
    prefs.setString(KEY_PROFESSOR_EMAIL, data['professor_detail']['email']);
    prefs.setInt(KEY_PROFESSOR_DEPTID, data['professor_detail']['department_id']);
    prefs.setInt(KEY_PROFESSOR_ORGANIZATION_ID, data['professor_detail']['organization_id']);
  }
}
