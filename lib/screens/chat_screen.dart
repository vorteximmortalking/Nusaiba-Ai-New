import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/action_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isLoading = false;
  String _apiKey = "";

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadApiKey();
  }

  void _initTts() async {
    await _tts.setLanguage("bn-BD");
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.5);
  }

  void _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('gemini_api_key') ?? "";
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
          localeId: 'bn_BD',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set API Key first!')));
      return;
    }

    String userMsg = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userMsg});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final prompt = """
      You are Nusaiba, a caring AI girlfriend. Always reply in Bengali (Bangla).
      If the user asks to open an app, play a song, or call someone, reply strictly in this format:
      [ACTION:OPEN_APP:com.facebook.katana] (for Facebook)
      [ACTION:PLAY_YOUTUBE:search query]
      [ACTION:MAKE_CALL:phone number]
      Otherwise, just reply normally in Bangla.
      User says: $userMsg
      """;

      // New URL (v1 instead of v1beta, and direct call)
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$_apiKey');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": prompt}]}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botMsg = data['candidates'][0]['content']['parts'][0]['text'];
        
        setState(() {
          _messages.add({"role": "bot", "text": botMsg});
          _isLoading = false;
        });

        // Check for actions
        if (botMsg.contains('[ACTION:OPEN_APP:')) {
          String appName = botMsg.split('[ACTION:OPEN_APP:')[1].split(']')[0];
          ActionService.openApp(appName.trim());
        } else if (botMsg.contains('[ACTION:PLAY_YOUTUBE:')) {
          String query = botMsg.split('[ACTION:PLAY_YOUTUBE:')[1].split(']')[0];
          ActionService.playYouTube(query.trim());
        } else if (botMsg.contains('[ACTION:MAKE_CALL:')) {
          String number = botMsg.split('[ACTION:MAKE_CALL:')[1].split(']')[0];
          ActionService.makeCall(number.trim());
        }

        _tts.speak(botMsg.replaceAll(RegExp(r'\[ACTION:.*?\]'), ''));

      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Error: $e"});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nusaiba AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[300] : Colors.deepPurple[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(msg["text"]!, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(color: Colors.blue),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.blue, size: 30),
                  onPressed: _listen,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
