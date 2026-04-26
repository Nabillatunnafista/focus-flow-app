// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../services/task_service.dart';
import '../../models/task_model.dart';
import '../../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int selectedIndex = 0; // 🔥 chip aktif

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: service.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(service),
      ),
      bottomNavigationBar: FocusFlowBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        onFabPressed: _openAddTask,
      ),
    );
  }

  Widget _buildBody(TaskService service) {
    final categories = service.categories;

    if (categories.isEmpty) {
      return const Center(child: Text("Belum ada data"));
    }

    final selectedCategory = categories[selectedIndex];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // HEADER
        Text(
          "Kotak masuk",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 10),

        // BANNER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Inspirasi tiba-tiba, tugas bisa dicatat di sini.",
            style: TextStyle(color: Colors.white),
          ),
        ),

        const SizedBox(height: 20),

        // TITLE + ADD FOLDER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daftar Tugas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openAddFolder,
            )
          ],
        ),

        const SizedBox(height: 10),

        // 🔥 CHIP HORIZONTAL
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isActive = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // 🔥 TASK LIST SESUAI CHIP
        ...selectedCategory.tasks.map(
          (task) => _TaskItem(
            task: task,
            categoryId: selectedCategory.id,
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddTaskSheet(),
    );
  }

  void _openAddFolder() {
    showDialog(
      context: context,
      builder: (_) => const _AddFolderDialog(),
    );
  }
}

// ================= TASK ITEM =================
class _TaskItem extends StatelessWidget {
  final TaskModel task;
  final String categoryId;

  const _TaskItem({
    required this.task,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: (_) =>
            service.toggleTask(categoryId, task.id),
      ),
      title: Text(task.title),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => service.deleteTask(task.id),
      ),
    );
  }
}

// ================= ADD FOLDER =================
class _AddFolderDialog extends StatefulWidget {
  const _AddFolderDialog();

  @override
  State<_AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends State<_AddFolderDialog> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return AlertDialog(
      title: const Text("Tambah Bagian"),
      content: TextField(
        controller: _ctrl,
        decoration: const InputDecoration(
          hintText: "Nama bagian",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        TextButton(
          onPressed: () async {
            if (_ctrl.text.isEmpty) return;

            await service.addFolder(_ctrl.text);

            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

// ================= ADD TASK =================
class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _ctrl = TextEditingController();
  String? selectedFolder;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Apa yang ingin kamu lakukan?"),

          const SizedBox(height: 10),

          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: "Deskripsi",
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            hint: const Text("Pilih Folder"),
            value: selectedFolder,
            items: service.categories.map((cat) {
              return DropdownMenuItem(
                value: cat.id,
                child: Text(cat.name),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedFolder = val),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              if (_ctrl.text.isEmpty || selectedFolder == null) return;

              await service.addTask(
                title: _ctrl.text,
                matkulId: selectedFolder!,
              );

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }
}