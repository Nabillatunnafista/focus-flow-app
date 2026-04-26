// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/task_service.dart';
import 'widgets/folder_card.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/add_folder_dialog.dart';

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
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddFolderDialog(),
              );
            },
          ),
        ],
      ),

      body: service.isLoading
          ? const Center(child: CircularProgressIndicator())
          : service.folders.isEmpty
              ? const Center(child: Text("Belum ada folder"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: service.folders.length,
                  itemBuilder: (context, index) {
                    final folder = service.folders[index];
                    return FolderCard(folder: folder);
                  },
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTaskSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}