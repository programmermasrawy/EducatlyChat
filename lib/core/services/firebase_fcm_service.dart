import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMNotificationService {
  final String _serverKey = '946340308610'; // Get this from Firebase console

  // Retrieve the recipient's FCM token (you can store user tokens in Firestore)
  Future<String> getRecipientToken(String recipientId) async {
    // Retrieve recipient token from Firestore (assuming it's stored in user document)
    // Example:
    // DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(recipientId).get();
    // return userDoc['fcmToken'];
    return 'recipient-fcm-token';
  }

  Future<void> sendFCMNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to send FCM notification');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }
}
