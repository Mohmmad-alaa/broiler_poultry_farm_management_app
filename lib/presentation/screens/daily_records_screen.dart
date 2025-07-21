import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/flock.dart';
import '../providers/daily_record_provider.dart';
import 'add_daily_record_screen.dart';
import 'edit_daily_record_screen.dart';

class DailyRecordsScreen extends StatefulWidget {
  final Flock flock;

  const DailyRecordsScreen({Key? key, required this.flock}) : super(key: key);

  @override
  State<DailyRecordsScreen> createState() => _DailyRecordsScreenState();
}

class _DailyRecordsScreenState extends State<DailyRecordsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DailyRecordProvider>(context, listen: false)
          .loadDailyRecords(widget.flock.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجلات اليومية'),
      ),
      body: Consumer<DailyRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('حدث خطأ: ${provider.error}'));
          }

          if (provider.records.isEmpty) {
            return const Center(
              child: Text('لا توجد سجلات يومية بعد. أضف سجلًا جديدًا.'),
            );
          }

          // ترتيب السجلات حسب التاريخ (الأحدث أولاً)
          final sortedRecords = [...provider.records]
            ..sort((a, b) => b.date.compareTo(a.date));

          // حساب عمر القطيع لكل سجل (بالأيام)
          final Map<int, int> recordAges = {};
          for (var record in sortedRecords) {
            recordAges[record.id!] = record.date
                .difference(widget.flock.startDate)
                .inDays + 1; // +1 لأن اليوم الأول يعتبر يوم 1 وليس 0
          }

          // حساب الأسبوع لكل سجل
          final Map<int, int> recordWeeks = {};
          for (var record in sortedRecords) {
            recordWeeks[record.id!] = ((recordAges[record.id!] ?? 0) / 7).ceil();
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('العمر (يوم)')),
                  //  DataColumn(label: Text('الأسبوع')),
                  DataColumn(label: Text('النفوق')),
                  DataColumn(label: Text('الوزن (جرام)')),
                  DataColumn(label: Text('استهلاك العلف (جرام)')),
                  DataColumn(label: Text('التاريخ')),
                //  DataColumn(label: Text('درجة الحرارة')),
                  DataColumn(label: Text('ملاحظات')),
                  DataColumn(label: Text('إجراءات')),
                ],
                rows: sortedRecords.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${recordAges[record.id]}')),
                      //  DataCell(Text('${recordWeeks[record.id]}')),
                      DataCell(Text('${record.mortality}')),
                      DataCell(Text('${record.weight.toStringAsFixed(1)}')),
                      DataCell(Text('${record.feedConsumption.toStringAsFixed(1)}')),
                      DataCell(Text(DateFormatter.formatDate(record.date))),
                      //  DataCell(Text('--')), // يمكن إضافة درجة الحرارة لاحقًا
                      DataCell(Text(record.notes)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditDailyRecordScreen(
                                      flock: widget.flock,
                                      record: record,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                _showDeleteConfirmation(record.id!, record.flockId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDailyRecordScreen(flock: widget.flock),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(int recordId, int flockId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السجل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<DailyRecordProvider>(context, listen: false)
                  .deleteDailyRecord(recordId, flockId);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}