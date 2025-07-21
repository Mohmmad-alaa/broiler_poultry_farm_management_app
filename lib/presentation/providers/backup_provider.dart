import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/datasources/database_helper.dart';

class BackupProvider with ChangeNotifier {
  final DatabaseHelper dbHelper;
  bool _isLoading = false;
  String? _error;

  BackupProvider(this.dbHelper);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createBackup() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // الحصول على مسار قاعدة البيانات
      final dbPath = await dbHelper.getDatabasePath();
      final dbFile = File(dbPath);

      // التحقق من وجود قاعدة البيانات
      if (!await dbFile.exists()) {
        _error = 'قاعدة البيانات غير موجودة';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // إنشاء مجلد النسخ الاحتياطي
      final appDir = await getExternalStorageDirectory();
      final backupDir = Directory('${appDir!.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // إنشاء اسم ملف النسخة الاحتياطية مع التاريخ والوقت
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final backupPath = '${backupDir.path}/poultry_farm_$timestamp.db';

      // نسخ قاعدة البيانات
      await dbFile.copy(backupPath);

      // مشاركة النسخة الاحتياطية
      await Share.shareFiles([backupPath], text: 'نسخة احتياطية من تطبيق إدارة المزرعة');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // اختيار ملف النسخة الاحتياطية
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // الحصول على مسار الملف المختار
      final backupPath = result.files.single.path!;
      final backupFile = File(backupPath);

      // التحقق من وجود ملف النسخة الاحتياطية
      if (!await backupFile.exists()) {
        _error = 'ملف النسخة الاحتياطية غير موجود';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // إغلاق قاعدة البيانات الحالية
      await dbHelper.closeDatabase();

      // الحصول على مسار قاعدة البيانات
      final dbPath = await dbHelper.getDatabasePath();
      final dbFile = File(dbPath);

      // نسخ ملف النسخة الاحتياطية إلى مسار قاعدة البيانات
      await backupFile.copy(dbPath);

      // إعادة فتح قاعدة البيانات
      await dbHelper.initDatabase();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}