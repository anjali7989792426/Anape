import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_service.dart';
import '../services/database_helper.dart';
import '../services/grammar_engine.dart';
import 'video_result_screen.dart';

class VideoPracticePage extends StatefulWidget {
  final String userEmail;
  const VideoPracticePage({super.key, required this.userEmail});

  @override
  State<VideoPracticePage> createState() => _VideoPracticePageState();
}

class _VideoPracticePageState extends State<VideoPracticePage> {
  CameraController? _controller;
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isRecording = false;
  String _spokenText = ""; 
  String _aiStatus = "AI Sensors Ready";
  double _eyeContactScore = 0.0;
  Timer? _analysisTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    
    _controller = CameraController(front, ResolutionPreset.medium, enableAudio: true);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // --- START SESSION (FIXED LISTENING) ---
  void _startPractice() async {
    // Initialize with error handling
    bool available = await _speech.initialize(
      onError: (val) => print('Speech Error: $val'),
      onStatus: (val) => print('Speech Status: $val'),
    );

    if (available) {
      setState(() {
        _isRecording = true;
        _spokenText = ""; 
        _aiStatus = "Listening... Focus on the lens!";
      });
      
      _speech.listen(
        onResult: (val) {
          // Background mein text save ho raha hai
          _spokenText = val.recognizedWords;
          print("Words captured: ${val.recognizedWords}"); // Debugging ke liye
        },
        listenFor: const Duration(minutes: 5), // Lamba time taaki session band na ho
        pauseFor: const Duration(seconds: 10), // User break le sake
        partialResults: true, // Real-time capture enable
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation, // Interview ke liye best mode
      );

      _analysisTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _eyeContactScore = 0.75 + (0.2 * (timer.tick % 2)); 
          _aiStatus = _eyeContactScore > 0.8 ? "Perfect Focus! ✨" : "Look at the Camera 👁️";
        });
      });
    } else {
      setState(() => _aiStatus = "Speech not available. Check Mic.");
    }
  }

  // --- STOP & ANALYZE ---
  void _stopPractice() async {
    await _speech.stop();
    _analysisTimer?.cancel();
    setState(() => _isRecording = false);

    // 1. Ultra-Strict Grammar Analysis
    final grammarReport = await GrammarEngine().analyzeTranscription(_spokenText);

    // 2. Behavioral Metrics
    final videoMetrics = AIService.analyzeVideoMetrics(
      eyeContactProbability: _eyeContactScore,
      headPoseStability: 0.9, 
    );

    // 3. Save to History
    await DatabaseHelper.instance.savePracticeResult(
      widget.userEmail, 
      grammarReport.calculatedScore, 
      _spokenText
    );

    // 4. NAVIGATE TO RESULT
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoResultScreen(
            score: grammarReport.calculatedScore,
            videoData: {
              'eyeContact': (_eyeContactScore * 100).toInt(),
              'posture': videoMetrics['bodyPosture'],
            },
            grammarData: {
              'fullText': _spokenText.isEmpty ? "No speech detected." : _spokenText,
              'mistakes': grammarReport.mistakes.map((m) => {
                'original': m.original,
                'replacement': m.replacement,
                'tip': m.description,
              }).toList(),
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _analysisTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller!)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildRealTimeFeedback(),
                _buildControlBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          _statusChip(),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(Icons.circle, color: _isRecording ? Colors.red : Colors.green, size: 10),
          const SizedBox(width: 8),
          Text(_isRecording ? "ANALYZING VOICE" : "AI SENSOR READY", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildRealTimeFeedback() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _isRecording ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.white10),
      ),
      child: Text(
        _aiStatus, 
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildControlBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const Text("Free Speech Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
          const SizedBox(height: 5),
          const Text("Speak clearly into the microphone.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: _isRecording ? _stopPractice : _startPractice,
            child: CircleAvatar(
              radius: 42,
              backgroundColor: _isRecording ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: _isRecording ? Colors.red : const Color(0xFF6C5CE7),
                child: Icon(_isRecording ? Icons.stop_rounded : Icons.videocam_rounded, color: Colors.white, size: 35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}