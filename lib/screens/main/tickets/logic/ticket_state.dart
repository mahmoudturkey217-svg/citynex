import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/ticket_media_model.dart';

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

class TicketDetailLoading extends TicketState {}

class TicketDetailLoaded extends TicketState {
  final TicketModel ticket;
  final List<TicketMediaModel> media;
  final List<String> signedUrls;

  TicketDetailLoaded({
    required this.ticket,
    required this.media,
    required this.signedUrls,
  });
}

class TicketDetailError extends TicketState {
  final String error;

  TicketDetailError({required this.error});
}

class TicketDeleteMediaLoading extends TicketState {}

class TicketDeleteMediaSuccess extends TicketState {
  final String message;
  TicketDeleteMediaSuccess({required this.message});
}

class TicketDeleteMediaError extends TicketState {
  final String error;
  TicketDeleteMediaError({required this.error});
}
