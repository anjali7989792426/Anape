import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/database_helper.dart';
import '../services/ai_service.dart';
import 'result_screen.dart';

class PracticePage extends StatefulWidget {
  final String userEmail;
  const PracticePage({super.key, required this.userEmail});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAnalyzing = false;
  String _targetSentence = "Loading...";
  String _wordsSpoken = "Tap mic to start...";

  DateTime? _lastWordTime;
  bool _longPauseFound = false;

  @override
  void initState() {
    super.initState();
    _loadNewSentence();
  }

  void _loadNewSentence() async {
    String sentence = await DatabaseHelper.instance.getRandomSentence();
    if (mounted) {
      setState(() {
        _targetSentence = sentence;
        _wordsSpoken = "Tap mic to start...";
        _isListening = false;
        _isAnalyzing = false;
        _longPauseFound = false;
      });
    }
  }

  // --- REBUILT MIC LOGIC ---
  Future<void> _toggleMic() async {
    if (_isAnalyzing) return;

    if (!_isListening) {
      // 1. Re-initialize engine every time to clear previous crashes
      _speech = stt.SpeechToText(); 
      
      bool available = await _speech.initialize(
        onStatus: (status) {
          print("Mic Status Update: $status");
          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              // Sirf tab restart karo agar user ne khud STOP nahi dabaya
              _startSafeListening();
            }
          }
        },
        onError: (error) {
          print("Mic Critical Error: ${error.errorMsg}");
          if (error.errorMsg == "error_busy") {
             _speech.stop();
          }
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _wordsSpoken = "";
        });
        _startSafeListening();
      }
    } else {
      // Manual STOP
      setState(() {
        _isListening = false;
        _isAnalyzing = true;
      });
      await _speech.stop();
      // Thoda wait karo taaki last words capture ho jayein
      await Future.delayed(const Duration(milliseconds: 800));
      _processEvaluation();
    }
  }

  void _startSafeListening() {
    if (!_isListening) return;

    _speech.listen(
      onResult: (val) {
        setState(() {
          _wordsSpoken = val.recognizedWords;
          if (_lastWordTime != null && val.recognizedWords.isNotEmpty) {
            if (DateTime.now().difference(_lastWordTime!).inSeconds >= 2) {
              _longPauseFound = true;
            }
          }
          _lastWordTime = DateTime.now();
        });
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onDevice: false, // Xiaomi fix
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 60), // Silence timeout increase
    );
  }

  void _processEvaluation() async {
    if (_wordsSpoken.isEmpty || _wordsSpoken.length < 3 || _wordsSpoken == "Tap mic to start...") {
      setState(() {
        _isAnalyzing = false;
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mic error: No voice detected. Try again!")),
      );
      return;
    }

    final accuracy = await AIService.calculateAIAccuracy(_targetSentence, _wordsSpoken);
    final aiFeedback = AIService.analyzeSpeech(
      _targetSentence, 
      _wordsSpoken, 
      "Shaik Mujasim", 
      _longPauseFound
    );

    await DatabaseHelper.instance.savePracticeResult(widget.userEmail, accuracy, _targetSentence);

    if (mounted) {
      setState(() => _isAnalyzing = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => ResultScreen(score: accuracy, aiData: aiFeedback)),
      ).then((_) => _loadNewSentence());
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("Voice Practice"), centerTitle: true),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  child: Text(_targetSentence, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(_wordsSpoken, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: primaryColor, fontStyle: FontStyle.italic)),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleMic,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: _isListening ? Colors.redAccent : primaryColor,
                    child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 15),
                Text(_isListening ? "TAP TO STOP" : "TAP TO START", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 15),
                    Text("AI is analyzing...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}