import '../../data/models/student_classes_model/class_status_request_model.dart';
import '../../data/models/student_classes_model/class_status_response_model.dart';
import '../repositories/student_classes_repository.dart';

class ChangeStudentClassStatusUseCase {
  final StudentClassesRepository repository;

  ChangeStudentClassStatusUseCase(this.repository);

  Future<ClassStatusResponseModel> execute({
    required ClassStatusRequestModel request,
    required bool activate,
  }) {
    return repository.changeStudentClassStatus(
      request: request,
      activate: activate,
    );
  }
}
