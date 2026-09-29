import 'package:flutter/material.dart';

class VideoResultScreen extends StatelessWidget {
  final double score;
  final Map<String, dynamic> videoData; 
  final Map<String, dynamic> grammarData; 

  const VideoResultScreen({
    super.key, 
    required this.score, 
    required this.videoData, 
    required this.grammarData
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic Color based on Performance
    final Color statusColor = score >= 80 ? Colors.green : (score >= 50 ? Colors.orange : Colors.redAccent);
    const Color primaryColor = Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("FULL PERFORMANCE AUDIT 🔍", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. OVERALL SCORE CARD
            _buildSectionHeader("OVERALL CONFIDENCE"),
            _buildScoreCard(score, statusColor),
            
            const SizedBox(height: 25),

            // 2. SESSION TRANSCRIPT (What user said)
            _buildSectionHeader("SESSION TRANSCRIPT"),
            _buildFullTranscriptBox(grammarData['fullText'] ?? "No speech detected."),

            const SizedBox(height: 25),

            // 3. AI GRAMMAR CORRECTIONS (Spotting Errors)
            _buildSectionHeader("AI GRAMMAR CORRECTIONS"),
            _buildTranscriptionAnalysis(grammarData),

            const SizedBox(height: 25),

            // 4. VISUAL PERFORMANCE (Eye Contact & Posture)
            _buildSectionHeader("VISUAL ANALYSIS"),
            _buildVisualCard(videoData),

            const SizedBox(height: 35),

            // ACTION BUTTONS
            _buildActionButtons(context, primaryColor),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- SCORE DISPLAY ---
  Widget _buildScoreCard(double score, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: statusColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text(
            "${score.toStringAsFixed(0)}%", 
            style: const TextStyle(fontSize: 55, fontWeight: FontWeight.w900, color: Colors.white)
          ),
          Text(
            score >= 80 ? "EXCELLENT COMMUNICATION" : (score >= 50 ? "AVERAGE - NEED IMPROVEMENT" : "REJECTED - HIGH ERRORS"),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  // --- TRANSCRIPT BOX ---
  Widget _buildFullTranscriptBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Text(
        "\"$text\"",
        style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5, fontStyle: FontStyle.italic),
      ),
    );
  }

  // --- ERROR SPOTTING & CORRECTION ---
  Widget _buildTranscriptionAnalysis(Map<String, dynamic> data) {
    List<dynamic> mistakes = data['mistakes'] ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mistakes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("Perfectly spoken! No linguistic errors found. ✨", 
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          else
            Column(
              children: mistakes.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _reviewRow(Icons.close_rounded, "You Said:", m['original'], Colors.redAccent),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                      _reviewRow(Icons.check_circle_rounded, "Correct Way:", m['replacement'], Colors.green),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            Expanded(child: Text("Tip: ${m['tip']}", style: const TextStyle(fontSize: 11, color: Colors.blueGrey))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _reviewRow(IconData icon, String label, String text, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: col, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col)),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 4),
          child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
      ],
    );
  }

  // --- VISUAL METRICS ---
  Widget _buildVisualCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric("Eye Contact", "${data['eyeContact']}%", Colors.blue),
          _buildMetric("Body Posture", data['posture'], Colors.green),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: col)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.1)),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("FINISH REVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}