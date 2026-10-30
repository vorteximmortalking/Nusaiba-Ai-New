import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionService {
  
  // Open App
  static Future<void> openApp(String packageName) async {
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        package: packageName,
      );
      await intent.launch();
    } catch (e) {
      print("App not found: $e");
    }
  }

  // Play YouTube
  static Future<void> playYouTube(String query) async {
    final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch YouTube');
    }
  }

  // Make Call
  static Future<void> makeCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch dialer');
    }
  }

  // Web Search
  static Future<void> searchWeb(String query) async {
    final url = Uri.parse('https://www.google.com/search?q=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch browser');
    }
  }
}
