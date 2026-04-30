import 'package:flutter/material.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time_app/models/tasbih_item.dart';
import 'package:prayer_time_app/pages/TasbihDetailPage.dart';
import 'package:prayer_time_app/services/tasbih_provider.dart';
import 'package:provider/provider.dart';

class TasbihPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TasbihProvider>(context);

    return Scaffold(
      appBar: customAppBar(
        context,
        "My Tasbihs",
        back: false,
      ),
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
        child: provider.tasbihs.isEmpty
            ? Center(
                child: Text(
                  "No tasbihs yet. Tap + to add one.",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.tasbihs.length,
                itemBuilder: (context, index) {
                  final tasbih = provider.tasbihs[index];
                  return _buildTasbihCard(context, tasbih, provider, isDark);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTasbihDialog(context, provider),
        backgroundColor: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTasbihCard(BuildContext context, TasbihItem tasbih, TasbihProvider provider, bool isDark) {
    final double progress = tasbih.goal > 0 ? (tasbih.counter / tasbih.goal).clamp(0.0, 1.0) : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TasbihDetailPage(tasbihId: tasbih.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tasbih.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditTasbihDialog(context, provider, tasbih: tasbih);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, provider, tasbih);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Count: ${tasbih.counter}",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    "Goal: ${tasbih.goal}",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? const Color(0xFFe94560) : const Color(0xFF667eea),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (tasbih.targetType != TargetType.none)
                Text(
                  "Target: ${tasbih.targetType == TargetType.daily ? 'Daily' : 'Weekly'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditTasbihDialog(BuildContext context, TasbihProvider provider, {TasbihItem? tasbih}) {
    final nameController = TextEditingController(text: tasbih?.name ?? '');
    final goalController = TextEditingController(text: tasbih?.goal.toString() ?? '33');
    TargetType selectedTargetType = tasbih?.targetType ?? TargetType.none;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tasbih == null ? "Add Tasbih" : "Edit Tasbih"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Tasbih Name (e.g., Darood Sherif)"),
                      autofocus: tasbih == null,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: goalController,
                      decoration: const InputDecoration(labelText: "Goal"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TargetType>(
                      value: selectedTargetType,
                      decoration: const InputDecoration(labelText: "Target Type"),
                      items: const [
                        DropdownMenuItem(value: TargetType.none, child: Text("None")),
                        DropdownMenuItem(value: TargetType.daily, child: Text("Daily")),
                        DropdownMenuItem(value: TargetType.weekly, child: Text("Weekly")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedTargetType = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final goal = int.tryParse(goalController.text) ?? 33;
                    if (name.isEmpty) return;

                    if (tasbih == null) {
                      provider.addTasbih(name, goal, selectedTargetType);
                    } else {
                      provider.updateTasbih(tasbih.id, name, goal, selectedTargetType);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, TasbihProvider provider, TasbihItem tasbih) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Tasbih?"),
          content: Text("Are you sure you want to delete '${tasbih.name}'? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTasbih(tasbih.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
