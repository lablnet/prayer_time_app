import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time_app/utils.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: customAppBar(context, "About"),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0f0f1e),
                    const Color(0xFF1a1a2e),
                  ]
                : [
                    const Color(0xFFf5f7fa),
                    const Color(0xFFc3cfe2),
                  ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // App Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5f72bd),
                    Color(0xFF9921e8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5f72bd).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.mosque,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Prayer Times",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Version 1.0.2",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // App Info Section
            _buildSectionTitle("App Information", isDark),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.copyright,
              title: "Copyright",
              subtitle: "2021 - Muhammad Umer Farooq",
              isDark: isDark,
            ),
            _buildInfoCard(
              icon: Icons.description,
              title: "License",
              subtitle: "GNU GPL 3",
              isDark: isDark,
            ),
            _buildInfoCard(
              icon: Icons.favorite,
              title: "Special Thanks",
              subtitle: "http://praytimes.org/",
              isDark: isDark,
              onTap: () async {
                await openUrl("http://praytimes.org/");
              },
            ),
            
            const SizedBox(height: 24),
            
            // Flutter Info Section
            _buildSectionTitle("Flutter Information", isDark),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.flutter_dash,
              title: "Flutter Version",
              subtitle: "3.22.2",
              isDark: isDark,
            ),
            _buildInfoCard(
              icon: Icons.settings_suggest,
              title: "SDK Channel",
              subtitle: "Stable",
              isDark: isDark,
            ),
            _buildInfoCard(
              icon: Icons.code,
              title: "Dart SDK Version",
              subtitle: "3.4.1",
              isDark: isDark,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFf5f6fa) : const Color(0xFF2d3436),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF00adb5),
                              const Color(0xFF00d4aa),
                            ]
                          : [
                              const Color(0xFF667eea),
                              const Color(0xFF764ba2),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFf5f6fa)
                              : const Color(0xFF2d3436),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFdfe6e9)
                              : const Color(0xFF636e72),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF00adb5)
                        : const Color(0xFF667eea),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
