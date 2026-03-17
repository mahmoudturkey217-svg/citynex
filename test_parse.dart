import 'dart:convert';
import 'lib/core/models/ticket_model.dart';
import 'lib/core/models/ticket_media_model.dart';

void main() {
  final jsonStr = '''
  {
      "success": true,
      "message": null,
      "data": {
          "ticket": {
              "title": "Broken street light",
              "description": "Street light not working near my house",
              "priority": "High",
              "status": "Pending",
              "location": {
                  "lat": 30.12345,
                  "lng": 31.12345
              },
              "confirmed_count": 0,
              "emergency_flag": false,
              "created_at": null,
              "updated_at": null
          },
          "potential_duplicates": []
      }
  }
  ''';

  try {
    final Map<String, dynamic> response = jsonDecode(jsonStr);
    final data = response['data'];
    final ticketJson = data is Map && data.containsKey('ticket')
        ? data['ticket']
        : data;
        
    final ticket = TicketModel.fromJson(ticketJson);
    print('SUCCESS: Ticket parsed successfully!');
    print('Title: \${ticket.title}');
    print('Status: \${ticket.status}');
    print('Category: \${ticket.category.name}');
  } catch (e, stacktrace) {
    print('ERROR parsing ticket: \$e');
    print(stacktrace);
  }
}
