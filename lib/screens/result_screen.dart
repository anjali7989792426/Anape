import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double score;
  final Map<String, dynamic> aiData;

  const ResultScreen({super.key, required this.score, required this.aiData});

  @override
  Widget build(BuildContext context) {
    final themeColor = score >= 80 
        ? const Color(0xFF00B894) 
        : (score >= 50 ? Colors.orange : Colors.redAccent);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Performance Scorecard 📊", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. ANIMATED HERO SCORE
            _buildAnimatedSection(
              delay: 0,
              child: _buildMainScoreCard(themeColor),
            ),
            const SizedBox(height: 20),

            // 2. CATEGORY MARKS
            _buildAnimatedSection(
              delay: 200,
              child: Row(
                children: [
                  _buildSmallMarkCard("Pronunciation", "${aiData['pronunciationMarks'] ?? 0}%", Colors.blue),
                  const SizedBox(width: 12),
                  _buildSmallMarkCard("Speech Clarity", "${score.toStringAsFixed(0)}%", Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 3. MISTAKE TRACKERS
            _buildAnimatedSection(
              delay: 400,
              child: _buildMistakeDetailCard(
                "Words Skipped 💨", 
                aiData['missedCount'].toString(), 
                aiData['missedWords'] ?? ["None!"], 
                Colors.redAccent,
                int.parse(aiData['missedCount'].toString()) == 0 
                  ? "Perfect! You spoke every single word. 🌟" 
                  : "Don't rush. Make sure you don't jump over words."
              ),
            ),
            const SizedBox(height: 15),

            _buildAnimatedSection(
              delay: 600,
              child: _buildMistakeDetailCard(
                "Mispronounced 🙊", 
                aiData['mispronouncedCount'].toString(), 
                aiData['mispronouncedWords'] ?? ["None!"], 
                Colors.orange,
                int.parse(aiData['mispronouncedCount'].toString()) == 0 
                  ? "Excellent! Your word clarity is spot on. ✨" 
                  : "Focus on the sounds. Check the breakdown below."
              ),
            ),
            const SizedBox(height: 15),

            _buildAnimatedSection(
              delay: 800,
              child: _buildMistakeDetailCard(
                "Extra Spoken ➕", 
                (aiData['extraCount'] ?? 0).toString(), 
                aiData['extraWords'] ?? ["None!"], 
                Colors.blueGrey,
                int.parse((aiData['extraCount'] ?? 0).toString()) == 0 
                  ? "Great focus! You stayed strictly on script. 🎯" 
                  : "Avoid adding extra words while speaking."
              ),
            ),
            const SizedBox(height: 25),

            // 4. MULTI-WORD SYLLABLE COACH (Fixed Error Here)
            _buildAnimatedSection(
              delay: 1000,
              child: _buildMultiSyllableSection(aiData),
            ),
            
            const SizedBox(height: 20),

            // 5. SUMMARY FEEDBACK
            _buildAnimatedSection(
              delay: 1200,
              child: _buildSummarySection(themeColor),
            ),

            const SizedBox(height: 35),
            
            // ACTION BUTTON
            _buildAnimatedSection(
              delay: 1400,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 8,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("PRACTICE AGAIN 🚀", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Multi-Word Syllable Coach Section ---
  Widget _buildMultiSyllableSection(Map<String, dynamic> data) {
    List<dynamic> mispronouncedWords = data['mispronouncedWords'] ?? [];
    List<dynamic> actualWords = mispronouncedWords.where((w) => 
      w.toString() != "None!" && w.toString() != "None! ✨" && w.toString() != "Great pronunciation!"
    ).toList();

    if (actualWords.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text("VOICE COACH: MASTER THE SOUNDS 🗣️", 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          ...actualWords.map((word) {
            return Column(
              children: [
                Text(
                  _splitWord(word.toString()), 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 4),
                ),
                const SizedBox(height: 5),
                Text("Correct: ${word.toString().toUpperCase()}", 
                  style: TextStyle(fontSize: 12, color: Colors.blue.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
                if (actualWords.last != word) Divider(height: 40, color: Colors.blue.withValues(alpha: 0.2)), // FIXED ERROR HERE
              ],
            );
          }),
          const SizedBox(height: 10),
          const Text("Slowly repeat each part", 
            style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _splitWord(String word) {
    word = word.toUpperCase();
    if (word.length <= 4) return word;
    final reg = RegExp(r'[^AEIOUY]*[AEIOUY]+(?:[^AEIOUY](?=[^AEIOUY]))?', caseSensitive: false);
    return reg.allMatches(word).map((m) => m.group(0)!).join(' • ');
  }

  Widget _buildAnimatedSection({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildMainScoreCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(score >= 80 ? "EXCELLENT WORK! 🏆" : "YOU CAN DO BETTER! 💪", 
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11)),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) => Text(
              "${value.toStringAsFixed(0)}%", 
              style: const TextStyle(color: Colors.white, fontSize: 75, fontWeight: FontWeight.w900, letterSpacing: -2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMarkCard(String title, String val, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: col)),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeDetailCard(String title, String count, List<dynamic> words, Color col, String msg) {
    bool isZero = int.tryParse(count) == 0;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: col)),
            CircleAvatar(backgroundColor: col, radius: 15, child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
          const Divider(height: 30),
          Wrap(spacing: 10, runSpacing: 10, children: words.map((w) => Chip(
            label: Text(w.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            backgroundColor: col.withValues(alpha: 0.08), side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )).toList()),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(isZero ? Icons.check_circle : Icons.lightbulb, size: 18, color: col),
              const SizedBox(width: 10),
              Expanded(child: Text(msg, style: TextStyle(fontSize: 12, color: col.withValues(alpha: 0.8), fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Color theme) {
    return Column(
      children: [
        _buildFeedbackBox("Winning Point ✨", aiData['positive'] ?? "Excellent energy!", Colors.green),
        const SizedBox(height: 12),
        _buildFeedbackBox("Critical Flaw ⚠️", score < 65 ? "You skipped core words. Keep focused." : "Improve clarity by stressing word endings.", Colors.red),
      ],
    );
  }

  Widget _buildFeedbackBox(String title, String desc, Color col) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: col.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: col.withValues(alpha: 0.1))),
      child: Row(
        children: [
          Icon(title.contains("Winning") ? Icons.auto_awesome : Icons.error_outline_rounded, color: col, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}