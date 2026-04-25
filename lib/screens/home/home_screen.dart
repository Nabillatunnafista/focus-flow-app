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
        // ── Header AppBar ──────────────────────────────
        SliverToBoxAdapter(child: _Header()),

        // ── Inbox Banner ───────────────────────────────
        SliverToBoxAdapter(child: _InboxBanner()),

        // ── Deadline Hari Ini ──────────────────────────
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

        // ── Daftar Tugas ───────────────────────────────
        SliverToBoxAdapter(
          child: _SectionTitle(
            title: 'Daftar Tugas',
            trailing: GestureDetector(
              onTap: _showAddTaskSheet,
              child: const Icon(Icons.add, color: AppColors.primary, size: 26),
            ),
          ),
        ),

        // ── Task category list ─────────────────────────
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

        // Bottom padding for nav bar
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

// ── Header ──────────────────────────────────────────────
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
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 28,
              ),

            ],
          ),
        ],
      ),
    );
  }
}

// ── Inbox Banner ────────────────────────────────────────
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kotak masuk adalah pusat sementara',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Inspirasi tiba-tiba, tugas yang belum\nterklasifikasi – semuanya dapat dicatat di sini.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ────────────────────────────────────────
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.primary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Deadline Card ────────────────────────────────────────
class _DeadlineCard extends StatelessWidget {
  final DeadlineModel deadline;
  final VoidCallback onDone;
  const _DeadlineCard({required this.deadline, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("EEEE, d MMMM yyyy – HH:mm", "id_ID");
    String deadlineStr;
    try {
      deadlineStr = fmt.format(deadline.deadline);
    } catch (_) {
      deadlineStr = deadline.deadline.toString();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deadline.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'deadline : $deadlineStr',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textGrey,
            ),
          ),
          if (deadline.submission != null)
            Text(
              'pengumpulan : ${deadline.submission}',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textGrey,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: deadline.isDone ? null : onDone,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(96, 36),
                backgroundColor:
                    deadline.isDone ? AppColors.secondary : AppColors.primary,
              ),
              child: Text(
                deadline.isDone ? '✓ Selesai' : 'Selesai',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Task Bottom Sheet ────────────────────────────────
class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tambah Tugas Baru',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Nama tugas...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_ctrl.text.trim().isNotEmpty) {
                // In mock mode this is a no-op; in live mode calls TaskService.addTask
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}