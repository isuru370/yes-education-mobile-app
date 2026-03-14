part of 'student_classes_bloc.dart';

sealed class StudentClassesEvent extends Equatable {
  const StudentClassesEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch student classes
final class FetchStudentClasses extends StudentClassesEvent {
  final int studentId;
  final String token;

  const FetchStudentClasses({required this.studentId, required this.token});

  @override
  List<Object?> get props => [studentId, token];
}

final class ChangeStudentClassStatus extends StudentClassesEvent {
  final int studentClassId;
  final String token;
  final bool activate;
  final int studentId; // needed to refresh list

  const ChangeStudentClassStatus({
    required this.studentClassId,
    required this.token,
    required this.activate,
    required this.studentId,
  });

  @override
  List<Object?> get props =>
      [studentClassId, token, activate, studentId];
}
