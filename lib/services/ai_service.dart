import 'package:string_similarity/string_similarity.dart';

class AIService {
  // --- AUDIO ANALYSIS LOGIC ---

  /// Calculates the raw similarity percentage between two strings.
  /// Used for overall clarity scoring.
  static Future<double> calculateAIAccuracy(String target, String spoken) async {
    if (spoken.isEmpty || spoken.contains("Tap mic")) return 0.0;
    // Using Sørensen–Dice Coefficient for high-precision text comparison
    return target.toLowerCase().trim().similarityTo(spoken.toLowerCase().trim()) * 100;
  }

  /// Deep audit of speech to identify specific pronunciation and fluency issues.
  static Map<String, dynamic> analyzeSpeech(String target, String spoken, String userName, bool hasLongPauses) {
    // 1. Data Sanitization: Remove punctuation and split into words
    List<String> tWords = target.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ').where((w) => w.isNotEmpty).toList();
    List<String> sWords = spoken.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ').where((w) => w.isNotEmpty).toList();

    List<String> mispronounced = [];
    List<String> missed = [];
    List<String> extra = [];

    // 2. Detection Loop: Identifies Omissions vs. Phonetic errors
    for (String tW in tWords) {
      if (!sWords.contains(tW)) {
        // If similarity is high (>0.45) but not exact, it's a mispronunciation
        bool isMis = sWords.any((sW) => sW.similarityTo(tW) > 0.45 && sW.similarityTo(tW) < 1.0);
        if (isMis) {
          mispronounced.add(tW);
        } else {
          missed.add(tW);
        }
      }
    }

    // 3. Filler/Extra Word Detection (Words spoken that weren't in the script)
    for (String sW in sWords) {
      if (!tWords.any((tW) => tW == sW || sW.similarityTo(tW) > 0.80)) {
        extra.add(sW);
      }
    }

    double accScore = target.toLowerCase().trim().similarityTo(spoken.toLowerCase().trim()) * 100;
    
    // 4. Weighted Performance Metrics for the Result Screen
    int pMarks = (100 - (mispronounced.length * 10)).clamp(0, 100);
    int fMarks = (100 - (missed.length * 15 + (hasLongPauses ? 20 : 0))).clamp(0, 100);

    return {
      "overallScore": accScore,
      "pronunciationMarks": pMarks,
      "fluencyMarks": fMarks,
      "mispronouncedCount": mispronounced.length,
      "missedCount": missed.length,
      "extraCount": extra.length,
      "mispronouncedWords": mispronounced.isEmpty ? ["None! ✨"] : mispronounced,
      "missedWords": missed.isEmpty ? ["None! ✨"] : missed,
      "extraWords": extra.isEmpty ? ["None! ✨"] : extra,
      "positive": accScore > 80 ? "You're a Natural! 🌟" : "Keep Grinding! 💪",
      "breakdown": mispronounced.isNotEmpty ? _split(mispronounced.first) : "",
      "points": [
        "Analysis for $userName 👤",
        "Clarity: ${accScore.toStringAsFixed(1)}% match 🎯",
        if (hasLongPauses) "Fluency: Long pauses detected 📉" else "Flow: Smooth rhythm 🌊",
      ],
    };
  }

  /// Syllable Splitter: Breaks down complex words to help user practice sounds.
  static String _split(String word) {
    if (word.length <= 3) return word.toUpperCase();
    // Regex identifies vowel-consonant clusters
    final reg = RegExp(r'[^aeiouy]*[aeiouy]+(?:[^aeiouy](?=[^aeiouy]))?', caseSensitive: false);
    List<String> syllables = reg.allMatches(word).map((m) => m.group(0)!.toUpperCase()).toList();
    return syllables.join(' • ');
  }

  // --- VIDEO METRICS LOGIC ---

  /// Analyzes behavioral data from the camera module.
  static Map<String, dynamic> analyzeVideoMetrics({
    required double eyeContactProbability, 
    required double headPoseStability
  }) {
    // 70% weight on Eye Contact, 30% on Posture Stability
    double visualScore = (eyeContactProbability * 0.7 + headPoseStability * 0.3) * 100;

    return {
      "visualStability": visualScore.clamp(0.0, 100.0),
      "eyeContactStatus": eyeContactProbability > 0.6 ? "Excellent" : "Needs Improvement",
      "bodyPosture": headPoseStability > 0.8 ? "Stable" : "Too much movement",
      "isProfessional": visualScore > 75,
    };
  }
}