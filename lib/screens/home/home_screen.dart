// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/bottom_nav.dart';
import 'widgets/add_folder_dialog.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/deadline_card.dart';
import 'widgets/folder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _deadlineIndex = 0; // which deadline card is showing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE9F6),
      body: SafeArea(
        bottom: false,
        child: _buildBody(),
      ),
      bottomNavigationBar: FocusFlowBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        onFabPressed: () => _showQuickAddTaskSheet(context),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final deadlines = provider.todayDeadlines;

        return CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Deadline Section ────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionTitle('Deadline Hari Ini'),
            ),

            if (deadlines.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DeadlineCard(
                    folderName: deadlines[_deadlineIndex % deadlines.length]
                        .folderName,
                    task: deadlines[_deadlineIndex % deadlines.length].task,
                    onDone: () {
                      final item =
                          deadlines[_deadlineIndex % deadlines.length];
                      // find folder id
                      final folderId = provider.folders
                          .firstWhere((f) => f.name == item.folderName)
                          .id;
                      provider.markTaskDone(folderId, item.task.id);
                    },
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Tidak ada deadline hari ini 🎉',
                      style: GoogleFonts.poppins(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Daftar Pelajaran Title ───────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Daftar Pelajaran',
                trailing: GestureDetector(
                  onTap: () => _showAddFolderDialog(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

            // ── Folder List ──────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final folder = provider.folders[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: FolderCard(
                      folder: folder,
                      initiallyExpanded: index < 2,
                      onToggleTask: (taskId) =>
                          provider.toggleTask(folder.id, taskId),
                      onAddTask: () =>
                          _showAddTaskSheet(context, folderId: folder.id),
                    ),
                  );
                },
                childCount: provider.folders.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hari ini',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: AppColors.primary,
            ),
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_outlined,
                  color: AppColors.primary, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SECTION TITLE ───────────────────────────────────────────
  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ─── SHOW ADD FOLDER DIALOG ──────────────────────────────────
  void _showAddFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddFolderDialog(),
    );
  }

  // ─── SHOW ADD TASK SHEET (from folder) ───────────────────────
  void _showAddTaskSheet(BuildContext context, {required String folderId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(preselectedFolderId: folderId),
    );
  }

  // ─── SHOW QUICK ADD TASK SHEET (from FAB) ────────────────────
  void _showQuickAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }
}