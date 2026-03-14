class ClassCategoryHasStudentClass {
  final int id;
  final int fees;

  ClassCategoryHasStudentClass({required this.id, required this.fees});

  factory ClassCategoryHasStudentClass.fromJson(Map<String, dynamic> json) {
    return ClassCategoryHasStudentClass(
      id: json['id'],
      fees: json['fees'],
    );
  }
}
