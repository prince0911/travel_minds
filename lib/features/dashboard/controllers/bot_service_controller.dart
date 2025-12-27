import 'package:http/http.dart' as http;
import 'dart:convert';

class BotpressService {
  static Future<String> sendMessage(String userMessage, String userId) async {
    final String url = 'https://webhook.botpress.cloud/6db4ba0e-527b-4cbd-8a25-f36c01a1edf0'; // Replace with the webhook URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'conversationId': userId, // Unique user ID
          'message': {
            'type': 'text',
            'text': userMessage,
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData['text'] ?? 'No response from bot');
        return responseData['text'] ?? 'No response from bot';
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Error: Failed to send message. Exception: $e');
      return 'Error: Failed to send message. Exception: $e';
    }
  }
}
