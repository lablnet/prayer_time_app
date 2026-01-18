import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_time_app/services/notification_service.dart';
import 'Home.dart';

class Settings extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int? method;
  Settings({this.latitude, this.longitude, this.method});


  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool("notifications_enabled") ?? true;
    });
  }

  _toggleNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications_enabled", value);
    setState(() {
      _notificationsEnabled = value;
    });
    
    // Immediate action
    if (value) {
      if (widget.latitude != null && widget.longitude != null && widget.method != null) {
        await NotificationService().schedulePrayerNotifications(
          widget.latitude!, 
          widget.longitude!, 
          widget.method!
        );
      }
    } else {
      await NotificationService().cancelAllNotifications();
    }
  }


  NavigationsRoute(BuildContext context, var item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var latitude = prefs.getDouble("latitude") ?? null;
    var longitude = prefs.getDouble("longitude") ?? null;

    prefs.setInt("method", item);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(latitude:latitude, longitude: longitude, method: item,)));

    //Navigator.pushNamed(context, 'home');

  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List methods = [
      'Jafari',
      'University of Islamic Sciences, Karachi',
      'Islamic Society of North America (ISNA)',
      'Muslim World League (MWL)',
      'Umm al-Qura, Makkah',
      'Egyptian General Authority of Survey',
      'Institute of Geophysics, University of Tehran'
    ];
    
    List<IconData> methodIcons = [
      Icons.mosque,
      Icons.school,
      Icons.public,
      Icons.language,
      Icons.location_city,
      Icons.map,
      Icons.science,
    ];
    
    return Scaffold(
      appBar: customAppBar(context, "Settings"),
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
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF5f72bd),
                          const Color(0xFF9921e8),
                        ]
                      : [
                          const Color(0xFF5f72bd),
                          const Color(0xFF9921e8),
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
                    Icons.settings,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Prayer Calculation Method",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Select the method used to calculate prayer times",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Method Cards
            ...List.generate(methods.length, (index) {
              final isSelected = index == widget.method;
              return _buildMethodCard(
                context,
                methods[index],
                methodIcons[index],
                isSelected,
                isDark,
                () => NavigationsRoute(context, index),
              );
            }),

            const SizedBox(height: 32),
            
            // Notification Setting
            _buildNotificationCard(isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          "Prayer Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          "Get notified when it's time for prayer",
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 12,
          ),
        ),
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        secondary: Icon(
          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
          color: _notificationsEnabled ? (isDark ? const Color(0xFFe94560) : const Color(0xFF667eea)) : Colors.grey,
        ),
        activeColor: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea),
      ),
    );
  }
  
  Widget _buildMethodCard(
    BuildContext context,
    String methodName,
    IconData icon,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isDark
                    ? [
                        const Color(0xFF11998e),
                        const Color(0xFF38ef7d),
                      ]
                    : [
                        const Color(0xFF4facfe),
                        const Color(0xFF00f2fe),
                      ],
              )
            : null,
        color: isSelected ? null : (isDark ? const Color(0xFF1e1e2e) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (isDark ? const Color(0xFF11998e) : const Color(0xFF4facfe)).withOpacity(0.4)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
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
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : (isDark ? const Color(0xFF2d2d3d) : const Color(0xFFf0f0f0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFF00adb5) : const Color(0xFF5f72bd)),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    methodName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFf5f6fa) : const Color(0xFF2d3436)),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
