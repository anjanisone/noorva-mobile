class ApiConstants {
  static const String baseUrl = 'https://api-dev.constructiontechnect.com/v1/api';
  
  // Auth
  static const String login = '$baseUrl/auth/user/signin/phone';
  static const String signup = '$baseUrl/auth/user/signup/phone';
  static const String verifyOtp = '$baseUrl/auth/user/signup/verify';
  
  // Project Management
  static const String projects = '$baseUrl/project-management/projects';
  static String projectDetails(String id) => '$projects/$id';
  static const String tasks = '$projects/tasks';
  static String taskStatus(String id) => '$tasks/$id/status';
  static const String activity = '$projects/activity';
  static const String dashboardSummary = '$projects/report/dashboard';
  
  // Headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
