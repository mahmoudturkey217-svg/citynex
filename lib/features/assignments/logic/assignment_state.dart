import '../../../core/models/assignment_model.dart';

abstract class AssignmentState {}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {}

class AssignmentSuccess extends AssignmentState {
  final List<AssignmentModel> assignments;

  AssignmentSuccess({required this.assignments});
}

class AssignmentError extends AssignmentState {
  final String error;

  AssignmentError({required this.error});
}

/// Emitted while an action (accept/decline/status update) is in progress
class AssignmentActionLoading extends AssignmentState {}

/// Emitted when an action succeeds
class AssignmentActionSuccess extends AssignmentState {
  final String message;

  AssignmentActionSuccess({required this.message});
}

/// Emitted when an action fails
class AssignmentActionError extends AssignmentState {
  final String error;

  AssignmentActionError({required this.error});
}
