import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer_time_app/services/tasbih_provider.dart';

class TasbihFullScreenPage extends StatelessWidget {
  const TasbihFullScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasbih = Provider.of<TasbihProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0f0f1e), const Color(0xFF1a1a2e)]
                : [const Color(0xFFf5f7fa), const Color(0xFFc3cfe2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      onPressed: () => Navigator.pop(context),
                      tooltip: "Exit Full Screen",
                    ),
                    const Spacer(),
                    Text(
                      "Goal: ${tasbih.goal}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 24),
                      onPressed: () => _showGoalDialog(context, tasbih),
                      tooltip: "Set Goal",
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 24),
                      onPressed: tasbih.reset,
                      tooltip: "Reset Counter",
                    ),
                  ],
                ),
              ),
              // Main Tap Area
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: tasbih.increment,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${tasbih.counter}",
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2d3436),
                            shadows: [
                              Shadow(
                                color: (isDark ? Colors.black : Colors.black12).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "TAP ANYWHERE",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
