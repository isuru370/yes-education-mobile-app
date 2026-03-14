class StudentTempQrModel {
  final int studentId;
  final String customId;
  final String fullName;
  final String initialName;
  final String mobile;
  final String whatsappMobile;
  final DateTime updateAt; // DateTime type
  final int daysLeft;
  final bool isActive;
  final int status; // JSON number

  StudentTempQrModel({
    required this.studentId,
    required this.customId,
    required this.fullName,
    required this.initialName,
    required this.mobile,
    required this.whatsappMobile,
    required this.updateAt,
    required this.daysLeft,
    required this.isActive,
    required this.status,
  });

  factory StudentTempQrModel.fromJson(Map<String, dynamic> json) {
    return StudentTempQrModel(
      studentId: json['student_id'],
      customId: json['custom_id'],
      fullName: json['full_name'],
      initialName: json['initial_name'],
      mobile: json['mobile'],
      whatsappMobile: json['whatsapp_mobile'],
      updateAt: DateTime.parse(json['update_at']), // ✅ parse string to DateTime
      daysLeft: json['days_left'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      status: json['status'],
    );
  }
}
