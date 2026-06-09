// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/task_service.dart';
import '../../widgets/bottom_nav.dart';
import '../calendar/calendar_screen.dart';
import '../deadlines/all_deadlines_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/task_list_screen.dart';
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
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskService>().loadDashboard();
    });
  }

  /// Hitung apakah ada notifikasi aktif (deadline hari ini / terlewat)
  bool _computeHasNotifications(TaskService provider) {
    final now = DateTime.now();
    for (final folder in provider.folders) {
      for (final task in folder.tasks) {
        if (task.deadline == null || task.isDone) continue;
        final diff = task.deadline!.difference(now);
        if (diff.isNegative || diff.inHours < 24) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE9F6),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _navIndex,
          children: [
            _buildHomeBody(),
            const TaskListScreen(),
            const CalendarScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: FocusFlowBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        showFab: true,
        onFabPressed: () => _showQuickAddTaskSheet(context),
      ),
    );
  }

  // ─── HOME BODY ────────────────────────────────────────────────
  Widget _buildHomeBody() {
    return Consumer<TaskService>(
      builder: (context, provider, _) {
        final deadlines = [...provider.todayDeadlines];
        deadlines.sort(
          (a, b) => (a.task.deadline ?? DateTime(2100))
              .compareTo(b.task.deadline ?? DateTime(2100)),
        );

        final visibleDeadlines = deadlines.take(3).toList();

        final filteredFolders = provider.folders
            .where((folder) => folder.name != 'Belum Dikelompokkan')
            .toList();

        if (provider.isLoading && provider.folders.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Deadline Terdekat',
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllDeadlinesScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            if (visibleDeadlines.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: visibleDeadlines.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DeadlineCard(
                        folderName: item.folderName,
                        task: item.task,
                        onDone: () {
                          provider.markTaskDoneById(item.task.id);
                        },
                      ),
                    );
                  }).toList(),
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

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Daftar Pelajaran',
                trailing: GestureDetector(
                  onTap: () => _showAddFolderDialog(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

            if (filteredFolders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 48,
                          color: AppColors.primary.withOpacity(0.35),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada pelajaran',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tekan tombol + untuk menambahkan\nfolder pelajaran pertamamu',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final folder = filteredFolders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: FolderCard(
                        folder: folder,
                        initiallyExpanded: index < 2,
                        onToggleTask: (taskId) {
                          provider.toggleTask(folder.id, taskId);
                        },
                        onAddTask: () =>
                            _showAddTaskSheet(context, folderId: folder.id),
                      ),
                    );
                  },
                  childCount: filteredFolders.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Hari ini',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: AppColors.primary,
              ),
            ),
          ),
          Consumer<TaskService>(
            builder: (context, provider, _) {
              final hasNotif = _computeHasNotifications(provider);
              if (hasNotif && !_hasUnread) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => _hasUnread = true));
              } else if (!hasNotif && _hasUnread) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => _hasUnread = false));
              }
              return GestureDetector(
                onTap: () async {
                  setState(() => _hasUnread = false);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: AppColors.primary, size: 28),
                    if (_hasUnread)
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
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── SECTION TITLE (FIKS RESPONSIF OVERFLOW) ─────────────────
  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FIKS UTAMA: Membungkus judul teks dengan Expanded agar ukurannya otomatis fleksibel dan tidak menabrak tombol samping
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
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