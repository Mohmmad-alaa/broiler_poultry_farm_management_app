import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/flock.dart';
import '../../domain/entities/daily_record.dart';
import '../../domain/entities/feed_record.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/entities/expense.dart';

class ExcelExportProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<String> _debugLogs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get debugLogs => _debugLogs;

  void _addDebugLog(String message) {
    final timestamp = DateTime.now().toString();
    final logMessage = '[$timestamp] $message';
    _debugLogs.add(logMessage);

    if (kDebugMode) {
      print('ExcelExport Debug: $logMessage');
    }

    if (_debugLogs.length > 50) {
      _debugLogs.removeAt(0);
    }
  }

  void clearDebugLogs() {
    _debugLogs.clear();
    notifyListeners();
  }

  Future<bool> exportFlockData({
    required Flock flock,
    required List<DailyRecord> dailyRecords,
    required List<FeedRecord> feedRecords,
    required List<HealthRecord> healthRecords,
    required List<Expense> expenses,
    Map<String, dynamic>? performanceMetrics,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _addDebugLog('بدء عملية تصدير البيانات للقطيع: ${flock.name}');
      notifyListeners();

      final excel = Excel.createExcel();

      excel.delete('Sheet1');
      _addDebugLog('تم حذف الورقة الافتراضية');

      final flockSheet = excel['معلومات القطيع'];

      flockSheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('تقرير القطيع: ${flock.name}');
      flockSheet.cell(CellIndex.indexByString('A3')).value =
          TextCellValue('معرف القطيع');
      flockSheet.cell(CellIndex.indexByString('B3')).value =
          TextCellValue((flock.id ?? 0).toString());

      flockSheet.cell(CellIndex.indexByString('A4')).value =
          TextCellValue('اسم القطيع');
      flockSheet.cell(CellIndex.indexByString('B4')).value =
          TextCellValue(flock.name);

      flockSheet.cell(CellIndex.indexByString('A5')).value =
          TextCellValue('رقم الدفعة');
      flockSheet.cell(CellIndex.indexByString('B5')).value =
          TextCellValue(flock.batchNumber);

      flockSheet.cell(CellIndex.indexByString('A6')).value =
          TextCellValue('تاريخ البدء');
      flockSheet.cell(CellIndex.indexByString('B6')).value =
          TextCellValue('${flock.startDate.day}/${flock.startDate.month}/${flock.startDate.year}');

      flockSheet.cell(CellIndex.indexByString('A7')).value =
          TextCellValue('عدد الطيور');
      flockSheet.cell(CellIndex.indexByString('B7')).value =
          TextCellValue(flock.birdCount.toString());

      flockSheet.cell(CellIndex.indexByString('A8')).value =
          TextCellValue('نوع الطيور');
      flockSheet.cell(CellIndex.indexByString('B8')).value =
          TextCellValue(flock.birdType);

      flockSheet.cell(CellIndex.indexByString('A9')).value =
          TextCellValue('الحالة');
      flockSheet.cell(CellIndex.indexByString('B9')).value =
          TextCellValue(flock.status);

      if (flock.endDate != null) {
        flockSheet.cell(CellIndex.indexByString('A10')).value =
            TextCellValue('تاريخ الانتهاء');
        flockSheet.cell(CellIndex.indexByString('B10')).value = TextCellValue(
            '${flock.endDate!.day}/${flock.endDate!.month}/${flock.endDate!.year}');
      }

      if (performanceMetrics != null && performanceMetrics.isNotEmpty) {
        flockSheet.cell(CellIndex.indexByString('A12')).value =
            TextCellValue('مؤشرات الأداء');

        int row = 13;
        performanceMetrics.forEach((key, value) {
          flockSheet.cell(CellIndex.indexByString('A$row')).value =
              TextCellValue(key);
          flockSheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(value.toString());
          row++;
        });
      }

      if (dailyRecords.isNotEmpty) {
        final dailySheet = excel['السجلات اليومية'];

        dailySheet.cell(CellIndex.indexByString('A1')).value =
            TextCellValue('التاريخ');
        dailySheet.cell(CellIndex.indexByString('B1')).value =
            TextCellValue('النفوق');
        dailySheet.cell(CellIndex.indexByString('C1')).value =
            TextCellValue('الوزن (جرام)');
        dailySheet.cell(CellIndex.indexByString('D1')).value =
            TextCellValue('استهلاك العلف (كجم)');
        dailySheet.cell(CellIndex.indexByString('E1')).value =
            TextCellValue('ملاحظات');

        for (int i = 0; i < dailyRecords.length; i++) {
          final record = dailyRecords[i];
          final rowIndex = i + 2;

          dailySheet.cell(CellIndex.indexByString('A$rowIndex')).value =
              TextCellValue('${record.date.day}/${record.date.month}/${record.date.year}');
          dailySheet.cell(CellIndex.indexByString('B$rowIndex')).value =
              TextCellValue(record.mortality.toString());
          dailySheet.cell(CellIndex.indexByString('C$rowIndex')).value =
              TextCellValue(record.weight.toString());
          dailySheet.cell(CellIndex.indexByString('D$rowIndex')).value =
              TextCellValue(record.feedConsumption.toString());
          dailySheet.cell(CellIndex.indexByString('E$rowIndex')).value =
              TextCellValue(record.notes);
        }
      }

      if (feedRecords.isNotEmpty) {
        final feedSheet = excel['سجلات العلف'];

        feedSheet.cell(CellIndex.indexByString('A1')).value =
            TextCellValue('التاريخ');
        feedSheet.cell(CellIndex.indexByString('B1')).value =
            TextCellValue('نوع العلف');
        feedSheet.cell(CellIndex.indexByString('C1')).value =
            TextCellValue('الكمية (كجم)');
        feedSheet.cell(CellIndex.indexByString('D1')).value =
            TextCellValue('التكلفة (شيكل)');

        for (int i = 0; i < feedRecords.length; i++) {
          final record = feedRecords[i];
          final rowIndex = i + 2;

          feedSheet.cell(CellIndex.indexByString('A$rowIndex')).value =
              TextCellValue('${record.date.day}/${record.date.month}/${record.date.year}');
          feedSheet.cell(CellIndex.indexByString('B$rowIndex')).value =
              TextCellValue(record.feedType);
          feedSheet.cell(CellIndex.indexByString('C$rowIndex')).value =
              TextCellValue(record.quantity.toString());
          feedSheet.cell(CellIndex.indexByString('D$rowIndex')).value =
              TextCellValue(record.cost.toString());
        }
      }

      if (healthRecords.isNotEmpty) {
        final healthSheet = excel['السجلات الصحية'];

        healthSheet.cell(CellIndex.indexByString('A1')).value =
            TextCellValue('التاريخ');
        healthSheet.cell(CellIndex.indexByString('B1')).value =
            TextCellValue('نوع العلاج');
        healthSheet.cell(CellIndex.indexByString('C1')).value =
            TextCellValue('التكلفة (شيكل)');
        healthSheet.cell(CellIndex.indexByString('D1')).value =
            TextCellValue('ملاحظات');

        for (int i = 0; i < healthRecords.length; i++) {
          final record = healthRecords[i];
          final rowIndex = i + 2;

          healthSheet.cell(CellIndex.indexByString('A$rowIndex')).value =
              TextCellValue('${record.date.day}/${record.date.month}/${record.date.year}');
          healthSheet.cell(CellIndex.indexByString('B$rowIndex')).value =
              TextCellValue(record.type);
          healthSheet.cell(CellIndex.indexByString('C$rowIndex')).value =
              TextCellValue(record.cost.toString());
          healthSheet.cell(CellIndex.indexByString('D$rowIndex')).value =
              TextCellValue(record.description);
        }
      }

      if (expenses.isNotEmpty) {
        final expenseSheet = excel['المصاريف'];

        expenseSheet.cell(CellIndex.indexByString('A1')).value =
            TextCellValue('التاريخ');
        expenseSheet.cell(CellIndex.indexByString('B1')).value =
            TextCellValue('الوصف');
        expenseSheet.cell(CellIndex.indexByString('C1')).value =
            TextCellValue('المبلغ (شيكل)');
        expenseSheet.cell(CellIndex.indexByString('D1')).value =
            TextCellValue('الفئة');

        for (int i = 0; i < expenses.length; i++) {
          final expense = expenses[i];
          final rowIndex = i + 2;

          expenseSheet.cell(CellIndex.indexByString('A$rowIndex')).value =
              TextCellValue('${expense.date.day}/${expense.date.month}/${expense.date.year}');
          expenseSheet.cell(CellIndex.indexByString('B$rowIndex')).value =
              TextCellValue(expense.description);
          expenseSheet.cell(CellIndex.indexByString('C$rowIndex')).value =
              TextCellValue(expense.amount.toString());
          expenseSheet.cell(CellIndex.indexByString('D$rowIndex')).value =
              TextCellValue(expense.category);
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/flock_report_${flock.id}.xlsx';
      final fileBytes = excel.encode();

      if (fileBytes != null) {
        final file = File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        _addDebugLog('تم حفظ الملف بنجاح في: $filePath');

        await Share.shareFiles([filePath], text: 'تقرير القطيع: ${flock.name}');
        _addDebugLog('تم مشاركة الملف بنجاح');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _error = e.toString();
      _addDebugLog('خطأ أثناء تصدير البيانات: $_error');
      _addDebugLog('Stack Trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}