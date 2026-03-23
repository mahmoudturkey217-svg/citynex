import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/assignment_repository.dart';
import '../../../core/models/assignment_model.dart';
import 'assignment_state.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository assignmentRepository;

  AssignmentCubit(this.assignmentRepository) : super(AssignmentInitial());

  static AssignmentCubit get(context) => BlocProvider.of(context);

  /// Cached list so we can restore it after action states
  List<AssignmentModel> _cachedAssignments = [];

  Future<void> getAssignments({
    String? ticketStatus,
    String? priority,
    int? categoryId,
    int? areaId,
    int? perPage,
  }) async {
    emit(AssignmentLoading());

    try {
      final response = await assignmentRepository.getAssignments(
        ticketStatus: ticketStatus,
        priority: priority,
        categoryId: categoryId,
        areaId: areaId,
        perPage: perPage ?? 100,
      );

      if (response.success) {
        _cachedAssignments = List<AssignmentModel>.from(response.data);
        print('✅ Assignments loaded: ${_cachedAssignments.length} items');
        for (var a in _cachedAssignments) {
          print('   📋 Assignment #${a.id} | status: ${a.status} | ticket: ${a.ticket.title}');
        }
        emit(AssignmentSuccess(assignments: _cachedAssignments));
      } else {
        print('❌ Assignments API returned success=false');
        emit(AssignmentError(error: 'Failed to load assignments'));
      }
    } catch (e) {
      print('❌ Assignments fetch error: $e');
      emit(AssignmentError(error: e.toString()));
    }
  }

  /// Accept an assignment, then refresh the list
  Future<void> acceptAssignment(int assignmentId) async {
    emit(AssignmentActionLoading());
    try {
      await assignmentRepository.acceptAssignment(assignmentId);
      emit(AssignmentActionSuccess(message: 'Assignment accepted successfully'));
      // Refresh list
      await getAssignments();
    } catch (e) {
      emit(AssignmentActionError(error: e.toString()));
      // Restore cached data
      emit(AssignmentSuccess(assignments: _cachedAssignments));
    }
  }

  /// Decline an assignment, then refresh the list
  Future<void> declineAssignment(int assignmentId) async {
    emit(AssignmentActionLoading());
    try {
      await assignmentRepository.declineAssignment(assignmentId);
      emit(AssignmentActionSuccess(message: 'Assignment declined successfully'));
      // Refresh list
      await getAssignments();
    } catch (e) {
      emit(AssignmentActionError(error: e.toString()));
      // Restore cached data
      emit(AssignmentSuccess(assignments: _cachedAssignments));
    }
  }

  /// Update assignment status (e.g. to "Completed"), then refresh
  Future<void> updateAssignmentStatus(int assignmentId, String status) async {
    emit(AssignmentActionLoading());
    try {
      await assignmentRepository.updateAssignmentStatus(assignmentId, status);
      emit(AssignmentActionSuccess(message: 'Status updated to $status'));
      // Refresh list
      await getAssignments();
    } catch (e) {
      emit(AssignmentActionError(error: e.toString()));
      // Restore cached data
      emit(AssignmentSuccess(assignments: _cachedAssignments));
    }
  }

  /// Upload photo for a ticket associated with an assignment
  Future<void> uploadMedia(int ticketId, String filePath, {String beforeAfter = 'After'}) async {
    emit(AssignmentActionLoading());
    try {
      await assignmentRepository.uploadTicketMedia(
        ticketId: ticketId,
        filePath: filePath,
        beforeAfter: beforeAfter,
      );
      emit(AssignmentActionSuccess(message: 'Image uploaded successfully'));
      // Refresh list
      await getAssignments();
    } catch (e) {
      emit(AssignmentActionError(error: e.toString()));
      // Restore cached data
      emit(AssignmentSuccess(assignments: _cachedAssignments));
    }
  }
}
