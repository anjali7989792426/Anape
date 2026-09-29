import 'database_helper.dart';

/// GrammarEngine: Responsible for identifying linguistic patterns 
/// and generating professional feedback based on DB rules.
class GrammarEngine {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<GrammarAnalysisReport> analyzeTranscription(String spokenText) async {
    // 1. Fetching logic patterns from local SQLite repository
    final List<Map<String, dynamic>> rules = await _dbHelper.getAllGrammarRules();
    
    List<GrammarMistake> detectedMistakes = [];
    
    // Cleaning text: punctuation hata rahe hain aur split kar rahe hain check karne ke liye
    String cleanText = spokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    List<String> wordsInSpeech = cleanText.split(' ').where((w) => w.isNotEmpty).toList();

    double penaltyPoints = 0.0;

    // 2. ULTRA-STRICT SCANNING LOGIC
    for (var rule in rules) {
      // Logic: Exact word boundaries (\b) use kar rahe hain 
      // taaki "re" match ho, par "report" ya "ready" match na ho.
      final pattern = RegExp('\\b(${rule['pattern']})\\b', caseSensitive: false);
      
      if (pattern.hasMatch(cleanText)) {
        Iterable<RegExpMatch> matches = pattern.allMatches(cleanText);
        
        for (var match in matches) {
          detectedMistakes.add(GrammarMistake(
            original: match.group(0) ?? "",
            replacement: rule['replacement'] ?? "Professional English",
            header: rule['feedback_header'] ?? "Grammar Alert",
            description: rule['feedback_description'] ?? "Suggested correction for professional clarity.",
            severity: rule['severity_level'] ?? "Medium",
          ));

          // --- DYNAMIC PENALTY SCORING ---
          if (rule['severity_level'] == 'Critical') {
            penaltyPoints += 35.0; // Slangs/Hinglish ke liye bhari penalty
          } else if (rule['severity_level'] == 'High') {
            penaltyPoints += 20.0; // Tense/Subject-Verb errors
          } else {
            penaltyPoints += 10.0; // Fillers/Articles
          }
        }
      }
    }

    // --- STRICT SCORING LOGIC ---
    
    // A. Length Multiplier: User ko kam se kam 10 words bolne honge full potential ke liye
    // Agar "Hi re kaisa" (3 words) bola toh score 70% automatic cut ho jayega.
    double lengthMultiplier = (wordsInSpeech.length / 10).clamp(0.2, 1.0);
    
    // B. Base Score Calculation
    double baseScore = (100.0 - penaltyPoints).clamp(0.0, 100.0);
    
    // C. Final Weighted Score
    double finalScore = baseScore * lengthMultiplier;

    // D. Strict Ceiling: Agar Critical slang detect hua, toh score 40% ke upar nahi ja sakta.
    bool hasCriticalError = detectedMistakes.any((m) => m.severity == 'Critical');
    if (hasCriticalError && finalScore > 40) {
      finalScore = 39.0; // Fail Grade
    }

    return GrammarAnalysisReport(
      originalText: spokenText,
      mistakes: detectedMistakes,
      errorCount: detectedMistakes.length,
      calculatedScore: finalScore,
    );
  }
}

// --- STRUCTURED DATA MODELS ---

class GrammarMistake {
  final String original;
  final String replacement;
  final String header;
  final String description;
  final String severity;

  GrammarMistake({
    required this.original,
    required this.replacement,
    required this.header,
    required this.description,
    required this.severity,
  });
}

class GrammarAnalysisReport {
  final String originalText;
  final List<GrammarMistake> mistakes;
  final int errorCount;
  final double calculatedScore;

  GrammarAnalysisReport({
    required this.originalText,
    required this.mistakes,
    required this.errorCount,
    required this.calculatedScore,
  });
}