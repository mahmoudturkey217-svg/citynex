import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/repositories/ticket_repository.dart';
import 'ticket_state.dart';

class TicketCubit extends Cubit<TicketState> {
  final TicketRepository ticketRepository;

  TicketCubit(this.ticketRepository) : super(TicketInitial());

  static TicketCubit get(context) => BlocProvider.of(context);

  Future<void> getTickets({
    String? status,
    String? priority,
    int? categoryId,
    int? areaId,
    int? perPage,
  }) async {
    emit(TicketLoading());
    try {
      final response = await ticketRepository.getTickets(
        status: status,
        priority: priority,
        categoryId: categoryId,
        areaId: areaId,
        perPage: perPage,
      );

      if (response.success) {
        emit(TicketSuccess(tickets: response.data));
      } else {
        emit(TicketError(error: 'Failed to load tickets'));
      }
    } catch (e) {
      emit(TicketError(error: e.toString()));
    }
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required int categoryId,
    required int areaId,
    required double lat,
    required double lng,
    required String priority,
    bool emergencyFlag = false,
  }) async {
    emit(TicketActionLoading());
    try {
      final ticket = await ticketRepository.createTicket(
        title: title,
        description: description,
        categoryId: categoryId,
        areaId: areaId,
        lat: lat,
        lng: lng,
        priority: priority,
        emergencyFlag: emergencyFlag,
      );
      emit(TicketActionSuccess(
          message: 'Ticket created successfully', ticket: ticket));
      // Refresh tickets list after creating
      getTickets();
    } catch (e) {
      emit(TicketActionError(error: e.toString()));
    }
  }

  Future<void> confirmTicket(int ticketId) async {
    emit(TicketActionLoading());
    try {
      final ticket = await ticketRepository.confirmTicket(ticketId);
      emit(TicketActionSuccess(
          message: 'Ticket confirmed successfully', ticket: ticket));
      // Refresh tickets list
      getTickets();
    } catch (e) {
      emit(TicketActionError(error: e.toString()));
    }
  }

  Future<void> uploadTicketMedia({
    required int ticketId,
    required String filePath,
    String beforeAfter = 'Before',
  }) async {
    emit(TicketActionLoading());
    try {
      await ticketRepository.uploadTicketMedia(
        ticketId: ticketId,
        filePath: filePath,
        beforeAfter: beforeAfter,
      );
      emit(TicketActionSuccess(message: 'Media uploaded successfully'));
      getTickets();
    } catch (e) {
      emit(TicketActionError(error: e.toString()));
    }
  }
}
