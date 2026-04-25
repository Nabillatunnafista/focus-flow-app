// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔥 FIX: pakai backend, bukan mock
      context.read<TaskService>().loadDashboard(useMock: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        bottom: false,
        child: taskService.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _buildBody(taskService),
      ),
      bottomNavigationBar: FocusFlowBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        onFabPressed: _showAddTaskSheet,
      ),
    );
  }

  Widget _buildBody(TaskService taskService) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header()),
        SliverToBoxAdapter(child: _InboxBanner()),

        SliverToBoxAdapter(
          child: _SectionTitle(title: 'Deadline Hari Ini'),
        ),

        if (taskService.todayDeadline != null)
          SliverToBoxAdapter(
            child: _DeadlineCard(
              deadline: taskService.todayDeadline!,
              onDone: taskService.markDeadlineDone,
            ),
          ),

        SliverToBoxAdapter(
          child: _SectionTitle(
            title: 'Daftar Tugas',
            trailing: GestureDetector(
              onTap: _showAddTaskSheet,
              child: const Icon(Icons.add, color: AppColors.primary, size: 26),
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final cat = taskService.categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TaskCategoryCard(
                  category: cat,
                  initiallyExpanded: index < 2,
                  onToggleTask: (taskId) =>
                      taskService.toggleTask(cat.id, taskId),
                ),
              );
            },
            childCount: taskService.categories.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTaskSheet(),
    );
  }
}

// ================= HEADER =================
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kotak masuk',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: AppColors.primary,
            ),
          ),
          const Icon(Icons.notifications_outlined,
              color: AppColors.primary, size: 28),
        ],
      ),
    );
  }
}

// ================= BANNER =================
class _InboxBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Inspirasi tiba-tiba, tugas bisa dicatat di sini.',
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    );
  }
}

// ================= TITLE =================
class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 17)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ================= DEADLINE =================
class _DeadlineCard extends StatelessWidget {
  final DeadlineModel deadline;
  final VoidCallback onDone;

  const _DeadlineCard({
    required this.deadline,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(deadline.title),
      subtitle: Text(DateFormat("dd MMM yyyy").format(deadline.deadline)),
      trailing: ElevatedButton(
        onPressed: deadline.isDone ? null : onDone,
        child: Text(deadline.isDone ? "✓" : "Selesai"),
      ),
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
  DateTime? _selectedDate;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<TaskService>();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TITLE
          const Text(
            "Tambah Tugas",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 16),

          // INPUT NAMA
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: "Nama tugas",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // DEADLINE PICKER
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? "Pilih deadline"
                      : DateFormat("dd MMM yyyy")
                          .format(_selectedDate!),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              )
            ],
          ),

          const SizedBox(height: 20),

          // BUTTON SIMPAN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // 🔥 VALIDASI NAMA
                if (_ctrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nama tugas wajib diisi"),
                    ),
                  );
                  return;
                }

                // 🔥 VALIDASI DEADLINE
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Deadline wajib dipilih"),
                    ),
                  );
                  return;
                }

                try {
                  await service.addTask(
                    title: _ctrl.text.trim(),
                    deadline: _selectedDate,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tugas berhasil ditambahkan"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal menambah tugas"),
                    ),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ),
        ],
      ),
    );
  }
}