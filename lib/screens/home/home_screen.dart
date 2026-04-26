// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/task_service.dart';
import '../../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TaskService>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();

    return Scaffold(
      body: SafeArea(
        child: service.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(service),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TaskService service) {
    return Column(
      children: [
        const SizedBox(height: 10),

        // HEADER
        const Text(
          "Kotak masuk",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        // LIST FOLDER
        Expanded(
          child: ListView.builder(
            itemCount: service.categories.length,
            itemBuilder: (_, i) {
              final cat = service.categories[i];

              return ExpansionTile(
                title: Text(cat.name),
                children: cat.tasks.map((task) {
                  return ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (v) {
                        service.toggleTask(task.id, v!);
                      },
                    ),
                    title: Text(task.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        service.deleteTask(task.id);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= ADD FOLDER =================
  void _showAddFolderDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Bagian"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: "Nama Bagian",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await context.read<TaskService>().addFolder(
                    name: ctrl.text,
                  );
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ================= ADD TASK =================
  void _showAddTaskSheet() {
    final ctrl = TextEditingController();
    String? selectedFolder;

    final service = context.read<TaskService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  const Text(
                    "Apa yang ingin kamu lakukan?",
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      hintText: "Deskripsi",
                    ),
                    maxLines: null,
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    hint: const Text("Pilih Folder"),
                    items: service.categories.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      );
                    }).toList(),
                    onChanged: (v) => selectedFolder = v,
                  ),

                  const SizedBox(height: 10),

                  // CHIP HORIZONTAL
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip(Icons.calendar_today, "Date"),
                        _chip(Icons.attach_file, "Attachment"),
                        _chip(Icons.flag, "Priority"),
                        _chip(Icons.alarm, "Reminder"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      await service.addTask(
                        title: ctrl.text,
                        folderId: selectedFolder!,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Simpan"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}