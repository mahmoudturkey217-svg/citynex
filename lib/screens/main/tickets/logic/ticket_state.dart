import '../../../../core/models/ticket_model.dart';

abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketSuccess extends TicketState {
  final List<TicketModel> tickets;

  TicketSuccess({required this.tickets});
}

class TicketError extends TicketState {
  final String error;

  TicketError({required this.error});
}

class TicketActionLoading extends TicketState {}

class TicketActionSuccess extends TicketState {
  final String message;
  final TicketModel? ticket;

  TicketActionSuccess({required this.message, this.ticket});
}

class TicketActionError extends TicketState {
  final String error;

  TicketActionError({required this.error});
}
