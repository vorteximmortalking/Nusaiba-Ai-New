import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  void _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('gemini_api_key') ?? "";
    });
  }

  void _saveKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKeyController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ API Key সেভ হয়েছে!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.poppins())),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gemini API Key', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'আপনার API Key দিন (AIzaSy...)',
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Save Key', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
