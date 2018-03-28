class Config{

  static var baseUrl = "http://192.168.1.106:8000";

  // Professor
  static var professorLoginUrl = baseUrl+"/api/v1/professor/login";
  static var professorViewStudentsUrl = baseUrl+"/api/v1/professor/get-all-students";
  static var createNewSessionUrl = baseUrl+"/api/v1/professor/create-new-session";
  static var getRecentSessionUrl = baseUrl+"/api/v1/professor/get-recent-session";
  static var getAllSessionUrl = baseUrl+"/api/v1/professor/get-all-sessions";
  static var getAllCoursesOfProfessorUrl = baseUrl+"/api/v1/professor/get-all-courses-of-professor";
  static var changeSessionStatusUrl = baseUrl+"/api/v1/professor/change-session-status";

  // Student
  static var storeStudentDataUrl = baseUrl+"/api/v1/student/login-student";
  static var checkStudentStatusUrl = baseUrl+"/api/v1/student/check-student-status";
  static var getCoursesUrl = baseUrl+"/api/v1/student/get-courses";
  static var registerCoursesUrl = baseUrl+"/api/v1/student/register-course";
  static var unregisterCoursesUrl = baseUrl+"/api/v1/student/remove-course";
  static var attendClassUrl = baseUrl+"/api/v1/student/attend-class";
  static var getAttendanceRecordUrl = baseUrl+"/api/v1/student/get-attendance-record";


}