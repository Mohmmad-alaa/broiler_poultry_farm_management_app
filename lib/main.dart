import 'package:broiler_poultry_farm_management_app/data/repositories/alert_repository_impl.dart';
import 'package:broiler_poultry_farm_management_app/presentation/providers/alert_provider.dart';
import 'package:broiler_poultry_farm_management_app/presentation/providers/backup_provider.dart';
import 'package:broiler_poultry_farm_management_app/presentation/providers/daily_record_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/repositories/daily_record_repository_impl.dart';
import 'data/repositories/flock_repository_impl.dart';
import 'data/repositories/feed_record_repository_impl.dart';
import 'data/repositories/health_record_repository_impl.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'presentation/providers/flock_provider.dart';
import 'presentation/providers/feed_record_provider.dart';
import 'presentation/providers/health_record_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/providers/excel_export_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FlockProvider(
            FlockRepositoryImpl(dbHelper),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedRecordProvider(
            FeedRecordRepositoryImpl(dbHelper),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthRecordProvider(
            HealthRecordRepositoryImpl(dbHelper),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            ExpenseRepositoryImpl(dbHelper),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DailyRecordProvider(
            DailyRecordRepositoryImpl(dbHelper),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BackupProvider(dbHelper),
        ),
        ChangeNotifierProvider(
          create: (context) => ExcelExportProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertProvider(
            AlertRepositoryImpl(dbHelper),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'إدارة مزرعة الدواجن',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
