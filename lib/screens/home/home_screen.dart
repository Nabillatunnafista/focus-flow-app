// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<TaskService>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kotak masuk",
                      style:
                          TextStyle(fontSize: 20)),
                  const Icon(Icons.notifications)
                ],
              ),
            ),

            // DEADLINE
            if (service.categories.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: service.categories.length,
                  itemBuilder: (_, i) {
                    final cat = service.categories[i];

                    return ExpansionTile(
                      title: Text(cat.name),
                      children: cat.tasks.map((t) {
                        return ListTile(
                          leading: Checkbox(
                            value: t.isDone,
                            onChanged: (_) {
                              service.toggleTask(
                                  cat.id, t.id);
                            },
                          ),
                          title: Text(t.title),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              service.deleteTask(t.id);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

            // ERROR
            if (service.error != null)
              Text(service.error!,
                  style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),

      // FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ➕ ATAS → FOLDER
          FloatingActionButton(
            heroTag: "folder",
            mini: true,
            onPressed: _showAddFolderDialog,
            child: const Icon(Icons.folder),
          ),

          const SizedBox(height: 10),

          // ➕ BAWAH → TASK
          FloatingActionButton(
            heroTag: "task",
            onPressed: _showAddTaskSheet,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // ================= POPUP FOLDER =================
  void _showAddFolderDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tambah Bagian",
                  style: TextStyle(fontSize: 18)),

              const SizedBox(height: 10),

              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  hintText: "Nama Bagian",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                decoration: const InputDecoration(
                  hintText: "Tambahkan Tag",
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await context
                          .read<TaskService>()
                          .addFolder(name: ctrl.text);

                      Navigator.pop(context);
                    },
                    child: const Text("Ok"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM SHEET TASK =================
  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TaskSheet(),
    );
  }
}

// ================= TASK SHEET =================
class _TaskSheet extends StatefulWidget {
  const _TaskSheet();

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  final ctrl = TextEditingController();
  String? folderId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context)
                .viewInsets
                .bottom +
            16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF6A4CAF),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text("Apa yang ingin kamu lakukan?",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16)),

            const SizedBox(height: 8),

            TextField(
              controller: ctrl,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Deskripsi",
                hintStyle:
                    TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              dropdownColor: Colors.white,
              hint: const Text("Pilih Folder"),
              items: service.categories.map((e) {
                return DropdownMenuItem(
                  value: e.id,
                  child: Text(e.name),
                );
              }).toList(),
              onChanged: (v) {
                folderId = v;
              },
            ),

            const SizedBox(height: 10),

            // CHIPS (1 BARIS)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _Chip(icon: Icons.calendar_today, text: "Date"),
                  _Chip(icon: Icons.attach_file, text: "Attachment"),
                  _Chip(icon: Icons.flag, text: "Priority"),
                  _Chip(icon: Icons.alarm, text: "Reminder"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await context
                      .read<TaskService>()
                      .addTask(
                        title: ctrl.text,
                        categoryId: folderId,
                      );

                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ================= CHIP =================
class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}