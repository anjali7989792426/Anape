import 'dart:ui';
import 'package:flutter/material.dart';
import 'practice_page.dart';
import 'video_upload_page.dart';
import 'ai_coach_page.dart';
import '../services/database_helper.dart';
import 'video_practice_page.dart'; // Agar dono file ek hi folder mein hain

class PremiumDashboard extends StatefulWidget {
  final String userName;
  final String userEmail;
  const PremiumDashboard({super.key, required this.userName, required this.userEmail});

  @override
  State<PremiumDashboard> createState() => _PremiumDashboardState();
}

class _PremiumDashboardState extends State<PremiumDashboard> {
  String avgScore = "0";
  int totalSessions = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDynamicData();
  }

  Future<void> _loadDynamicData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final stats = await DatabaseHelper.instance.getUserStats(widget.userEmail);
    if (mounted) {
      setState(() {
        avgScore = "${stats['average']}%";
        totalSessions = stats['sessions'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      extendBodyBehindAppBar: true,
      drawer: _buildSidebar(primaryColor),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text("ANAPE AI", 
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        iconTheme: const IconThemeData(color: primaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDynamicData,
          ),
        ],
      ),

      body: Stack(
        children: [
          _buildBackgroundEffects(primaryColor),

          isLoading 
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: _loadDynamicData,
                  color: primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text("Hello,", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                        Text("${widget.userName} !", 
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                        
                        const SizedBox(height: 25),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(child: _buildGlassStatCard("Avg Accuracy", avgScore, Icons.insights_rounded, primaryColor)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildGlassStatCard("Sessions", totalSessions.toString(), Icons.bolt_rounded, Colors.orangeAccent)),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        const Text("Training Hub", 
                          style: TextStyle(fontSize: 22, color: Color(0xFF2D3436), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),

                        // Training Grid - Fixed Parameter Order
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85, 
                          children: [
                            // 1. Voice AI
                            _buildVerticalCard(
                              "Start\nPractice", 
                              "Voice AI", 
                              primaryColor, 
                              Icons.mic_none_rounded, 
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => PracticePage(userEmail: widget.userEmail)))
                                .then((_) => _loadDynamicData());
                              }
                            ),
                            // 2. Video Bot
                            _buildVerticalCard(
                              "Body\nLanguage", 
                              "Video Bot", 
                              const Color(0xFF0984E3), 
                              Icons.videocam_outlined, 
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const VideoUploadPage()));
                              }
                            ),
                            // 3. Progress Log
                           // 3. Video Interview (Replaced Progress Log with Live Practice)
_buildVerticalCard(
  "Video\nInterview", 
  "Face & Eye Analysis", 
  const Color(0xFF00B894), 
  Icons.face_retouching_natural_rounded, 
  () {
    // FIX: Yahan VideoUploadPage ki jagah VideoPracticePage call hoga live camera ke liye
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (c) => VideoPracticePage(userEmail: widget.userEmail)
      )
    ).then((_) => _loadDynamicData()); // Refresh stats after practice
  }
),
                            // 4. AI Coach
                            _buildVerticalCard(
                              "AI\nCoach", 
                              "Speaking Tips", 
                              const Color(0xFFF39C12), 
                              Icons.lightbulb_outline_rounded, 
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const AICoachPage()));
                              }
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // --- SIDEBAR (DRAWER) ---
  Widget _buildSidebar(Color primaryColor) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(widget.userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white, 
              child: Icon(Icons.person, color: Color(0xFF6C5CE7), size: 40)
            ),
          ),
          _drawerItem(Icons.dashboard_rounded, "Dashboard", () => Navigator.pop(context)),
          _drawerItem(Icons.history_edu_rounded, "Practice History", () => _navigateToPage("Practice History")),
          _drawerItem(Icons.person_outline_rounded, "Profile Settings", () => _navigateToPage("Profile Settings")),
          _drawerItem(Icons.workspace_premium_rounded, "Go Premium", () => _navigateToPage("Premium Plans"), iconColor: Colors.orange),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout_rounded, "Logout", () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }, iconColor: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color iconColor = const Color(0xFF6C5CE7)}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3436))),
      onTap: onTap,
    );
  }

  // --- NAVIGATION HELPER ---
  void _navigateToPage(String title) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => GenericToolPage(title: title)));
  }

  // --- UI COMPONENTS ---
  Widget _buildBackgroundEffects(Color primaryColor) {
    return Stack(
      children: [
        Positioned(top: -50, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withValues(alpha: 0.15)))),
        Positioned(top: 250, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00CEC9).withValues(alpha: 0.1)))),
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent))),
      ],
    );
  }

  Widget _buildGlassStatCard(String label, String value, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: col.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: col, size: 28),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(color: Color(0xFF2D3436), fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Helper Widget for Training Cards
  Widget _buildVerticalCard(String title, String sub, Color col, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [col, col.withValues(alpha: 0.8)], 
            begin: Alignment.topLeft, 
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: col.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), 
              child: Icon(icon, color: Colors.white, size: 28)
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                const SizedBox(height: 5),
                Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- UNDER DEVELOPMENT PLACEHOLDER PAGE ---
class GenericToolPage extends StatelessWidget {
  final String title;
  const GenericToolPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_fix_high_rounded, size: 80, color: Color(0xFF6C5CE7)),
            const SizedBox(height: 20),
            Text("$title is coming soon!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                "Our AI engineers are working hard to bring this feature to life.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}