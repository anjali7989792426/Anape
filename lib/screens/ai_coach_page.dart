import 'package:flutter/material.dart';

class AICoachPage extends StatelessWidget {
  const AICoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          "AI Speaking Coach",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. MOTIVATION SECTION ---
            _buildMotivationCard(primaryColor),
            const SizedBox(height: 30),

            const Text(
              "Pro Speaking Tricks ⚡",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
            ),
            const SizedBox(height: 15),
            
            // --- 2. CORE TECHNIQUES ---
            _buildTipTile(
              "Shadowing Technique", 
              "Listen to a native speaker and repeat 1 second later. It builds natural rhythm and timing.", 
              Icons.record_voice_over // FIXED: Snake_case name
            ),
            _buildTipTile(
              "The Mirror Method", 
              "Speak in front of a mirror. Watch your mouth movements to ensure clarity and confidence.", 
              Icons.face_retouching_natural
            ),
            _buildTipTile(
              "Record & Review", 
              "Listen to your own recordings in the Video Bot. Self-correction is the fastest way to grow.", 
              Icons.videocam_rounded
            ),

            const SizedBox(height: 30),
            const Text(
              "Pronunciation & Syllables 🗣️",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
            ),
            const SizedBox(height: 15),

            // --- 3. SYLLABLES MASTERY ---
            _buildDetailedTipCard(
              "How to Master Syllables?",
              "Every English word is broken into 'beats'. For example:\n\n"
              "• WA-TER (2 Syllables)\n"
              "• COM-PU-TER (3 Syllables)\n"
              "• E-CON-O-MY (4 Syllables)\n\n"
              "Tip: Clap your hands for every beat. It helps you understand word stress!",
              primaryColor,
            ),
            
            const SizedBox(height: 15),

            // --- 4. PRONUNCIATION TIP ---
            _buildDetailedTipCard(
              "The Magic 'R' Sound",
              "In English, your tongue should never touch the roof of your mouth when saying 'R'. Let it float in the middle! Try saying: 'Rare Red Rabbit'.",
              Colors.orangeAccent,
            ),

            const SizedBox(height: 40),

            // --- 5. FINAL PUSH ---
            _buildFinalMotivation(primaryColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildMotivationCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: Colors.white, size: 40),
          SizedBox(height: 5),
          Text(
            "English is not just a language, it's the key to your global future.",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "\"Consistent practice for 10 minutes is better than 2 hours once a week.\"",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTipTile(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6C5CE7), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436)),
                ),
                const SizedBox(height: 4),
                Text(
                  desc, 
                  style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailedTipCard(String title, String content, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border(left: BorderSide(color: accent, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title, 
                style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content, 
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF636E72)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalMotivation(Color primaryColor) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: Colors.orangeAccent, size: 60),
          const SizedBox(height: 15),
          const Text(
            "Ready to be unstoppable?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Every mistake is a step closer to fluency.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Start Today's Session", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}