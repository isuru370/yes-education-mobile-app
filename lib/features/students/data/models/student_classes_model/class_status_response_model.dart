class ClassStatusResponseModel {
  final String status;
  final String message;
  final ClassStatusRecord record;

  ClassStatusResponseModel({
    required this.status,
    required this.message,
    required this.record,
  });

  factory ClassStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return ClassStatusResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      record: ClassStatusRecord.fromJson(json['record'] ?? {}),
    );
  }
}

class ClassStatusRecord {
  final int id;
  final int studentId;
  final int studentClassesId;
  final int classCategoryHasStudentClassId;
  final bool status;
  final bool isFreeCard;
  final String createdAt;
  final String updatedAt;

  ClassStatusRecord({
    required this.id,
    required this.studentId,
    required this.studentClassesId,
    required this.classCategoryHasStudentClassId,
    required this.status,
    required this.isFreeCard,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassStatusRecord.fromJson(Map<String, dynamic> json) {
    return ClassStatusRecord(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentClassesId: json['student_classes_id'] ?? 0,
      classCategoryHasStudentClassId:
          json['class_category_has_student_class_id'] ?? 0,
      status: json['status'] ?? false,
      isFreeCard: json['is_free_card'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
