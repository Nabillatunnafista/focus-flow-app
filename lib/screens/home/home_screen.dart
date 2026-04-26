// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskService>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: service.isLoading
            ? const Center(child: CircularProgressIndicator())
            : service.categories.isEmpty
                ? _buildEmpty()
                : _buildBody(service),
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home),
              Icon(Icons.list),
              SizedBox(width: 40),
              Icon(Icons.calendar_today),
              Icon(Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Belum ada folder",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _showAddFolderDialog,
            child: const Text("Tambah Folder"),
          )
        ],
      ),
    );
  }

  // ================= BODY =================
  Widget _buildBody(TaskService service) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildBanner()),
        SliverToBoxAdapter(child: _buildDeadline(service)),
        SliverToBoxAdapter(child: _buildSectionTitle()),
        _buildFolderList(service),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Kotak masuk",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.notifications_none),
        ],
      ),
    );
  }

  // ================= BANNER =================
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Inspirasi tiba-tiba, tugas bisa dicatat di sini.",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // ================= DEADLINE =================
  Widget _buildDeadline(TaskService service) {
    final d = service.todayDeadline;

    if (d == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(d.title),
        subtitle: Text(
          DateFormat("dd MMM yyyy").format(d.deadline),
        ),
        trailing: ElevatedButton(
          onPressed: service.markDeadlineDone,
          child: const Text("Selesai"),
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Daftar Pelajaran",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddFolderDialog,
          )
        ],
      ),
    );
  }

  // ================= FOLDER LIST =================
  Widget _buildFolderList(TaskService service) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final cat = service.categories[index];

          return Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text("${cat.tasks.length}")
                  ],
                ),

                const SizedBox(height: 8),

                // 🔥 CHIP 1 BARIS
                if (cat.colorTag != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text("#${cat.colorTag}"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        childCount: service.categories.length,
      ),
    );
  }

  // ================= ADD FOLDER =================
  void _showAddFolderDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Folder"),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: "Nama folder"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;

              await context
                  .read<TaskService>()
                  .addFolder(name: ctrl.text);

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
    final service = context.read<TaskService>();

    if (service.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buat folder dulu")),
      );
      return;
    }

    final ctrl = TextEditingController();
    String? selected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Tambah Tugas"),

                TextField(
                  controller: ctrl,
                  decoration:
                      const InputDecoration(hintText: "Task"),
                ),

                DropdownButton<String>(
                  hint: const Text("Pilih Folder"),
                  value: selected,
                  items: service.categories
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => selected = val);
                  },
                ),

                ElevatedButton(
                  onPressed: () {
                    if (selected == null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                            content: Text("Pilih folder")),
                      );
                      return;
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}