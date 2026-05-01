import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer_time_app/services/tasbih_provider.dart';
import 'package:prayer_time_app/models/tasbih_item.dart';

class TasbihFullScreenPage extends StatelessWidget {
  final String tasbihId;

  const TasbihFullScreenPage({super.key, required this.tasbihId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);
    final tasbih = provider.getTasbih(tasbihId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tasbih == null) {
      return const Scaffold(body: Center(child: Text("Tasbih not found")));
    }

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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Goal: ${tasbih.goal}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          "Total: ${tasbih.totalCount}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 24),
                      onPressed: () => _showGoalDialog(context, provider, tasbih),
                      tooltip: "Set Goal",
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 24),
                      onPressed: () => _showResetDialog(context, provider, tasbih),
                      tooltip: "Reset Counter",
                    ),
                  ],
                ),
              ),
              // Main Tap Area
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => provider.increment(tasbih.id),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Text(
                            "${tasbih.counter}",
                            style: TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: tasbih.counter >= tasbih.goal 
                                  ? Colors.green 
                                  : (isDark ? Colors.white : const Color(0xFF2d3436)),
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

  void _showResetDialog(BuildContext context, TasbihProvider provider, TasbihItem tasbih) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Tasbih?"),
          content: const Text("Are you sure you want to reset this tasbih counter? This cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                provider.reset(tasbih.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  void _showGoalDialog(BuildContext context, TasbihProvider provider, TasbihItem tasbih) {
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
                provider.updateTasbih(tasbih.id, tasbih.name, tempGoal, tasbih.targetType);
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
