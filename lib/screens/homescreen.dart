import 'dart:ui';
import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isConnected = false;

  String selectedServer = "Local Server";
  String selectedFlag = "assets/pakistan.png";
  String selectedPing = "85ms";

  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  final List<Map<String, String>> servers = [
    {'flag': 'assets/pakistan.png', 'name': 'Local Server', 'ping': '85ms'},
    {'flag': 'assets/pakistan.png', 'name': 'Pakistan Server', 'ping': '120ms'},
    {'flag': 'assets/uae.png', 'name': 'UAE Server', 'ping': '210ms'},
    {'flag': 'assets/malaysia.png', 'name': 'Malaysia Server', 'ping': '190ms'},
  ];

  bool isLightMode = false;

  // ✅ Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Dynamic profile
  String userName = "User";
  String userEmail = "";
  String userPhone = "";

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(_controller);

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    userEmail = user.email ?? "";

    try {
      final doc = await _db.collection("users").doc(user.uid).get();
      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userName = (data["name"] ?? "User").toString();
          userPhone = (data["phone"] ?? "").toString();
          userEmail = (data["email"] ?? userEmail).toString();
        });
      } else {
        setState(() {
          userName = "User";
          userEmail = user.email ?? "";
          userPhone = "";
        });
      }
    } catch (_) {
      // handle error
    }

  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🌫️ Server List Bottom Sheet
  void _showServerListSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Server List",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: servers.length,
                        itemBuilder: (context, index) {
                          final server = servers[index];
                          final isSelected = server['name'] == selectedServer;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedServer = server['name']!;
                                selectedFlag = server['flag']!;
                                selectedPing = server['ping']!;
                              });
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.greenAccent,
                                  content: Text(
                                    "Selected: ${server['name']}",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0CBC8B).withOpacity(0.8)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.asset(
                                          server['flag']!,
                                          width: 30,
                                          height: 20,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            server['name']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            "Limited speed   Free plan",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.signal_cellular_alt,
                                        color: Colors.greenAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        server['ping']!,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🍔 Drawer Menu
  Drawer _buildDrawerMenu() {
    return Drawer(
      backgroundColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑 User Info (Dynamic)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userEmail.isEmpty ? "No Email" : userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _menuItem("Upgrade to Premium", Icons.star, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            }),

            _menuItem("Server List", Icons.public, _showServerListSheet),

            _menuItem("Settings", Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),

            const Divider(color: Colors.white24, height: 30),

            _menuItem("Privacy Policy", Icons.privacy_tip, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              );
            }),

            _menuItem("FAQ", Icons.help_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQScreen()),
              );
            }),

            // ✅ Logout
            _menuItem("Logout", Icons.logout, _logout),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Light Mode",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Switch(
                  value: isLightMode,
                  activeColor: const Color(0xFF0CBC8B),
                  onChanged: (val) => setState(() => isLightMode = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, VoidCallback onTap) => ListTile(
    contentPadding: EdgeInsets.zero,
    onTap: onTap,
    leading: Icon(icon, color: Colors.white70),
    title: Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 15)),
    trailing:
    const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: _buildDrawerMenu(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "PAKVPN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.orange[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isConnected ? "Secured" : "Not Secured",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          const SizedBox(height: 40),

          // Glow Power Button
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isConnected
                      ? [
                    BoxShadow(
                      color: const Color(0xFF0CBC8B).withOpacity(0.6),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value,
                    )
                  ]
                      : [],
                ),
                child: GestureDetector(
                  onTap: () => setState(() => isConnected = !isConnected),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isConnected
                            ? const Color(0xFF0CBC8B)
                            : Colors.white.withOpacity(0.4),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.power_settings_new,
                            color: Color(0xFF0CBC8B),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isConnected ? "Stop" : "Start",
                            style: const TextStyle(
                              color: Color(0xFF0CBC8B),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Connected Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.orange[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isConnected ? "Connected" : "Not Connected",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          const SizedBox(height: 40),

          // Speed Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpeedCard("Download", Icons.arrow_downward, "0.00"),
                _buildSpeedCard("Upload", Icons.arrow_upward, "0.00"),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Server Selector
          GestureDetector(
            onTap: _showServerListSheet,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0CBC8B),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          selectedFlag,
                          width: 30,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedServer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Limited speed   Free plan",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.signal_cellular_alt,
                          color: Colors.white),
                      const SizedBox(width: 4),
                      Text(selectedPing,
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 5),
                      const Icon(Icons.arrow_upward,
                          color: Colors.white, size: 16),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCard(String title, IconData icon, String speed) {
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 6),
              Icon(icon, color: Colors.white70, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$speed mb/s",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// 💎 Reusable Info Screens
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  @override
  Widget build(BuildContext context) => const _SimpleInfoPage(
    title: "Premium Subscription",
    content: "Coming Soon!",
  );
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) => const _SimpleInfoPage(
    title: "Privacy Policy",
    content:
    "We respect your privacy. PAKVPN never stores or shares user browsing data. All your traffic is encrypted and secure.",
  );
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});
  @override
  Widget build(BuildContext context) => const _SimpleInfoPage(
    title: "FAQ",
    content:
    "Q: Is PAKVPN free?\nA: Yes, free servers are available.\n\nQ: How can I get faster speeds?\nA: Upgrade to Premium (coming soon).",
  );
}

class _SimpleInfoPage extends StatelessWidget {
  final String title;
  final String content;

  const _SimpleInfoPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        content,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    ),
  );
}

// ⚙️ Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white70),
            title: const Text("Account Info",
                style: TextStyle(color: Colors.white)),
            trailing:
            const Icon(Icons.arrow_forward_ios, color: Colors.white38),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white70),
            title: const Text("Privacy Policy",
                style: TextStyle(color: Colors.white)),
            trailing:
            const Icon(Icons.arrow_forward_ios, color: Colors.white38),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text("App Version 1.0.0",
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// 👤 Account Info Screen (Dynamic)
class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Not logged in",
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Account Info",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _db.collection("users").doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? {};
          final name = (data["name"] ?? "User").toString();
          final email = (data["email"] ?? user.email ?? "").toString();
          final phone = (data["phone"] ?? "").toString();
          final dob = (data["dob"] ?? "").toString();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoBlock("Name", name),
                  const SizedBox(height: 18),
                  _infoBlock("Email", email),
                  const SizedBox(height: 18),
                  _infoBlock("Phone Number", phone.isEmpty ? "Not set" : phone),
                  const SizedBox(height: 18),
                  _infoBlock("DOB", dob.isEmpty ? "Not set" : dob),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// ✅ Dummy LoginScreen (Replace with your real login page)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Login",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Replace this with your real Login Screen",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
