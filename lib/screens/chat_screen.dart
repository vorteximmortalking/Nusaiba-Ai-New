import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GenerativeModel? _model;

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
    String apiKey = prefs.getString('gemini_api_key') ?? "";
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0.8) _sendMessage();
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
    if (_model == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আগে সেটিংস থেকে API Key দিন!')));
      return;
    }

    String userMsg = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userMsg});
      _controller.clear();
      _isLoading = true;
    });

    try {
      // Nusaiba-র ব্যক্তিত্ব (System Prompt)
      final prompt = "You are Nusaiba, a warm, caring, and friendly female AI assistant. You speak in a soft, empathetic tone. Always answer in the language the user speaks. You occasionally use gentle emojis like 🌸💙. User says: $userMsg";
      
      final response = await _model!.generateContent([Content.text(prompt)]);
      String botMsg = response.text ?? "আমি বুঝতে পারিনি।";

      setState(() {
        _messages.add({"role": "bot", "text": botMsg});
        _isLoading = false;
      });
      
      _tts.speak(botMsg);

    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "এরর: $e"});
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
                      hintText: 'মেসেজ লিখুন...',
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
