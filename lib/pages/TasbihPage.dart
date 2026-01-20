import 'package:flutter/material.dart';
import 'package:prayer_time_app/pages/TasbihFullScreenPage.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time_app/services/tasbih_provider.dart';

class TasbihPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasbih = Provider.of<TasbihProvider>(context);
    
    return Scaffold(
      appBar: customAppBar(
        context, 
        "Digital Tasbih", 
        back: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0f0f1e), const Color(0xFF1a1a2e)]
                : [const Color(0xFFf5f7fa), const Color(0xFFc3cfe2)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Goal: ${tasbih.goal}",
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: tasbih.increment,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.blueGrey).withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    "${tasbih.counter}",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2d3436),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.refresh,
                  label: "Reset",
                  onPressed: tasbih.reset,
                  color: Colors.orange,
                ),
                const SizedBox(width: 30),
                _buildActionButton(
                  icon: Icons.settings,
                  label: "Set Goal",
                  onPressed: () {
                    _showGoalDialog(context, tasbih);
                  },
                  color: Colors.blue,
                ),
                const SizedBox(width: 30),
                _buildActionButton(
                  icon: Icons.fullscreen_rounded,
                  label: "Fullscreen",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TasbihFullScreenPage()),
                    );
                  },
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed, required Color color}) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 30, color: color),
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            padding: const EdgeInsets.all(15),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showGoalDialog(BuildContext context, TasbihProvider tasbih) {
    int tempGoal = tasbih.goal;
    final controller = TextEditingController(text: tasbih.goal.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Tasbih Goal"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter goal (e.g., 33, 100)"),
            onChanged: (value) {
              tempGoal = int.tryParse(value) ?? tasbih.goal;
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                tasbih.setGoal(tempGoal);
                Navigator.pop(context);
              },
              child: const Text("Set"),
            ),
          ],
        );
      },
    );
  }
}
