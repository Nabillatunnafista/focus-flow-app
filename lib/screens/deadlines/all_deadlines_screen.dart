// lib/screens/deadlines/all_deadlines_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/task_service.dart';
import '../home/widgets/deadline_card.dart';

class AllDeadlinesScreen extends StatefulWidget {
  const AllDeadlinesScreen({super.key});

  @override
  State<AllDeadlinesScreen> createState() => _AllDeadlinesScreenState();
}

class _AllDeadlinesScreenState extends State<AllDeadlinesScreen> {
  @override
  void initState() {
    super.initState();
    // Me-refresh data beranda agar list tugas diperbarui dari backend Go
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskService>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Semua Tenggat',
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TaskService>(
          builder: (context, taskService, child) {
            // FIX 1: Menggunakan list todayDeadlines bawaan dari TaskService asli kamu
            final allDeadlines = [...taskService.todayDeadlines];

            // Urutkan ulang berdasarkan waktu deadline terdekat
            allDeadlines.sort(
              (a, b) => (a.task.deadline ?? DateTime(2100))
                  .compareTo(b.task.deadline ?? DateTime(2100)),
            );

            // Tampilan jika data tugas kosong
            if (allDeadlines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 64,
                      color: AppColors.textGrey.withOpacity(0.35),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada tenggat tugas terdekat',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: allDeadlines.length,
              itemBuilder: (context, index) {
                final deadlineItem = allDeadlines[index];
                final folderName = deadlineItem.folderName; // Ambil nama mata kuliah langsung dari objek wrapper

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DeadlineCard(
                    folderName: folderName,
                    task: deadlineItem.task, // Masukkan model task-nya
                    onDone: () async {
                      try {
                        // FIX 2: Menembak fungsi penyelesaian tugas asli yang ada di TaskService kamu
                        await taskService.markTaskDoneById(deadlineItem.task.id);
                        if (!context.mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status tugas berhasil diperbarui!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal memperbarui status tugas',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}