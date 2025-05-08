class ApiConfig {
  static const String baseUrl =
      "http://192.168.99.251:5000/api/auth"; // رابط الـ API الأساسي
  static const String getUserNameEndpoint =
      "/user/name"; // رابط جلب اسم المستخدم
  static const String updateSettingsEndpoint =
      "/settings/update"; // رابط تحديث الإعدادات
  static const String getUserProfileEndpoint =
      "/me"; // Endpoint to get user profile
}
