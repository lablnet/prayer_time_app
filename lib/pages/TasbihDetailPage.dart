import 'package:flutter/material.dart';
import 'package:prayer_time_app/pages/TasbihFullScreenPage.dart';
import 'package:provider/provider.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time_app/services/tasbih_provider.dart';
import 'package:prayer_time_app/models/tasbih_item.dart';

class TasbihDetailPage extends StatelessWidget {
  final String tasbihId;

  const TasbihDetailPage({super.key, required this.tasbihId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TasbihProvider>(context);
    final tasbih = provider.getTasbih(tasbihId);

    if (tasbih == null) {
      return Scaffold(
        appBar: customAppBar(context, "Digital Tasbih"),
        body: const Center(child: Text("Tasbih not found.")),
      );
    }

    return Scaffold(
      appBar: customAppBar(
        context,
        tasbih.name,
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
            const SizedBox(height: 8),
            Text(
              "Total All-Time: ${tasbih.totalCount}",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => provider.increment(tasbih.id),
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
                      color: tasbih.counter >= tasbih.goal 
                          ? Colors.green 
                          : (isDark ? Colors.white : const Color(0xFF2d3436)),
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
                  onPressed: () => _showResetDialog(context, provider, tasbih),
                  color: Colors.orange,
                ),
                const SizedBox(width: 30),
                _buildActionButton(
                  icon: Icons.settings,
                  label: "Set Goal",
                  onPressed: () {
                    _showGoalDialog(context, provider, tasbih);
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
                      MaterialPageRoute(
                        builder: (context) => TasbihFullScreenPage(tasbihId: tasbih.id),
                      ),
                    );
                  },
                  color: Colors.teal,
                ),
                const SizedBox(width: 30),
                _buildActionButton(
                  icon: tasbih.vibrationEnabled ? Icons.vibration : Icons.phonelink_erase,
                  label: tasbih.vibrationEnabled ? "Vibrate On" : "Vibrate Off",
                  onPressed: () {
                    provider.toggleVibration(tasbih.id);
                  },
                  color: tasbih.vibrationEnabled ? Colors.indigo : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (tasbih.dailyHistory.isNotEmpty)
              _buildHistoryButton(context, tasbih),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context, TasbihItem tasbih) {
    return TextButton.icon(
      onPressed: () => _showHistoryDialog(context, tasbih),
      icon: const Icon(Icons.history_rounded),
      label: const Text("View Daily History"),
      style: TextButton.styleFrom(foregroundColor: Colors.white70),
    );
  }

  void _showHistoryDialog(BuildContext context, TasbihItem tasbih) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${tasbih.name} History"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tasbih.dailyHistory.length,
              itemBuilder: (context, index) {
                String dateKey = tasbih.dailyHistory.keys.elementAt(index);
                int count = tasbih.dailyHistory[dateKey]!;
                return ListTile(
                  title: Text(dateKey),
                  trailing: Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        );
      },
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
