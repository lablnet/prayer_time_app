import 'package:flutter/material.dart';
import 'package:prayer_time_app/pages/Home.dart';
import 'package:prayer_time_app/pages/Monthly.dart';
import 'package:prayer_time_app/pages/Settings.dart';
import 'package:prayer_time_app/pages/About.dart';
import 'package:prayer_time_app/pages/QiblaPage.dart';
import 'package:prayer_time_app/pages/TasbihPage.dart';
import 'package:prayer_time_app/pages/ZakatPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainNavigation extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int method;

  MainNavigation({this.latitude, this.longitude, required this.method});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Home(latitude: widget.latitude, longitude: widget.longitude, method: widget.method),
      QiblaPage(),
      TasbihPage(),
      ZakatPage(),
      Settings(latitude: widget.latitude, longitude: widget.longitude, method: widget.method),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
            selectedItemColor: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea),
            unselectedItemColor: Colors.grey.withOpacity(0.5),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_rounded),
                label: 'Qibla',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.circleDot),
                label: 'Tasbih',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate_rounded),
                label: 'Zakat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
