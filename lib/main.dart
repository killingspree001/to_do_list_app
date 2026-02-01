import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/task_priority.dart';
import 'package:to_do_list/theme/app_theme.dart';
import 'package:to_do_list/providers/theme_provider.dart';
import 'package:to_do_list/screens/main_navigation_screen.dart';
import 'package:to_do_list/models/task_repeat.dart';
import 'package:to_do_list/services/notification_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await NotificationService.init();
  
  // Register Adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskRepeatAdapter());
  
  runApp(
    const ProviderScope(
      child: TodoApp(),
    ),
  );
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'To Do List',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const MainNavigationScreen(),
    );
  }
}


