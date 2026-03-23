import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/ticket_repository.dart';
import '../../../core/models/ticket_model.dart';
import '../../../core/models/ticket_media_model.dart';
import '../../../core/utils/cache_helper.dart';
import 'ticket_state.dart';

class TicketCubit extends Cubit<TicketState> {
  final TicketRepository ticketRepository;

  // Cache to store the first signed URL generated for a ticket
  // This helps show images in the ticket list even when the list API doesn't return them
  final Map<int, String> _ticketCoverCache = {};

  TicketCubit(this.ticketRepository) : super(TicketInitial());

  static TicketCubit get(context) => BlocProvider.of(context);

  void _injectCachedCovers(List<TicketModel> tickets) {
    for (int i = 0; i < tickets.length; i++) {
      final ticket = tickets[i];
      if (_ticketCoverCache.containsKey(ticket.id)) {
        try {
          if (ticket.media == null || ticket.media!.isEmpty) {
            // Create a new mutable list with the cached cover
            final newMedia = <TicketMediaModel>[
              TicketMediaModel(
                id: 0,
                mediaType: 'Image',
                mediaUrl: _ticketCoverCache[ticket.id],
              )
            ];
            // Since media is final, we need to work with the existing list
            // If media is null, we can't add to it; skip this ticket
            if (ticket.media != null) {
              ticket.media!.add(TicketMediaModel(
                id: 0,
                mediaType: 'Image',
                mediaUrl: _ticketCoverCache[ticket.id],
              ));
            }
          } else if (ticket.media!.first.mediaUrl == null) {
            ticket.media![0] = TicketMediaModel(
              id: ticket.media!.first.id,
              mediaType: ticket.media!.first.mediaType,
              mediaUrl: _ticketCoverCache[ticket.id],
            );
          }
        } catch (e) {
          print('⚠️ Could not inject cached cover for ticket ${ticket.id}: $e');
        }
      }
    }
  }

  Future<void> getTickets({
    String? status,
    String? priority,
    int? categoryId,
    int? areaId,
    int? perPage,
  }) async {
    // 1. Try to load cached data first for instant UX
    final cachedData = CacheHelper.getData(key: 'cached_tickets');
    bool hasEmittedCache = false;
    
    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData);
        final cachedResponse = TicketsResponseModel.fromJson(decoded);
        if (cachedResponse.success && cachedResponse.data.isNotEmpty) {
          _injectCachedCovers(cachedResponse.data);
          emit(TicketSuccess(tickets: cachedResponse.data));
          hasEmittedCache = true;
        }
      } catch (e) {
        // Stale or corrupt cache — clear it so it doesn't fail repeatedly
        print('⚠️ Clearing stale ticket cache: $e');
        CacheHelper.removeData(key: 'cached_tickets');
      }
    }

    if (!hasEmittedCache) {
      emit(TicketLoading());
    }

    try {
      final response = await ticketRepository.getTickets(
        status: status,
        priority: priority,
        categoryId: categoryId,
        areaId: areaId,
        perPage: perPage ?? 100, // Request 100 items by default instead of Laravel's default 15
      );

      if (response.success) {
        _injectCachedCovers(response.data);
        
        // 2. Save the fresh data to cache
        try {
          final jsonString = jsonEncode(response.toJson());
          await CacheHelper.saveData(key: 'cached_tickets', value: jsonString);
        } catch (e) {
          // Ignore failing to save cache
        }
        
        // Create a new list object so BlocBuilder correctly detects the update
        final updatedList = List<TicketModel>.from(response.data);
        emit(TicketSuccess(tickets: updatedList));
      } else {
        if (!hasEmittedCache) {
          emit(TicketError(error: 'Failed to load tickets'));
        }
      }
    } catch (e) {
      if (!hasEmittedCache) {
        emit(TicketError(error: e.toString()));
      }
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
      // Invalidate stale cache so getTickets() fetches fresh data
      // and the newly created ticket appears right away.
      await CacheHelper.removeData(key: 'cached_tickets');
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

  /// Fetch ticket details including media, and resolve signed URLs.
  Future<void> getTicketDetails(int ticketId) async {
    emit(TicketDetailLoading());
    try {
      final result = await ticketRepository.getTicketDetails(ticketId);
      final TicketModel ticket = result['ticket'];
      final List<TicketMediaModel> media = result['media'];

      // Fetch signed URLs for each media item
      final List<String> signedUrls = [];
      for (var item in media) {
        try {
          final url = await ticketRepository.getMediaSignedUrl(ticketId, item.id);
          signedUrls.add(url);
        } catch (e) {
          // If signed URL fails, try the direct media_url as fallback
          if (item.mediaUrl != null && item.mediaUrl!.isNotEmpty) {
            signedUrls.add(item.mediaUrl!);
          }
        }
      }

      if (signedUrls.isNotEmpty) {
        _ticketCoverCache[ticketId] = signedUrls.first;
        // Optionally update the list so the cache is immediately applied
        getTickets(
          perPage: 100, // keep the current 100 limit when updating
        );
      }

      emit(TicketDetailLoaded(
        ticket: ticket,
        media: media,
        signedUrls: signedUrls,
      ));
    } catch (e) {
      emit(TicketDetailError(error: e.toString()));
    }
  }

  Future<void> deleteTicketMedia({
    required int ticketId,
    required int mediaId, 
  }) async {
    emit(TicketDeleteMediaLoading());
    try {
      await ticketRepository.deleteTicketMedia(ticketId, mediaId);
      emit(TicketDeleteMediaSuccess(message: 'Media deleted successfully'));
      getTicketDetails(ticketId); // Refresh details after deletion
      // getTickets(); // We might also want to refresh the main list if the cover image changed.
    } catch (e) {
      emit(TicketDeleteMediaError(error: e.toString()));
    }
  }
}
