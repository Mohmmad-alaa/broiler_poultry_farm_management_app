import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_record_provider.dart';
import 'add_health_record_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  final int flockId;

  const HealthRecordsScreen({Key? key, required this.flockId}) : super(key: key);

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  @override
  void initState() {
    super.initState();
    // Load health records when screen initializes
    Future.microtask(() =>
        Provider.of<HealthRecordProvider>(context, listen: false)
            .loadHealthRecords(widget.flockId)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthRecordProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('حدث خطأ: ${provider.error}'),
                ElevatedButton(
                  onPressed: () => provider.loadHealthRecords(widget.flockId),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'إجمالي تكاليف الصحة: ${provider.getTotalHealthCost().toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: provider.healthRecords.isEmpty
                  ? const Center(
                child: Text('لا توجد سجلات صحية. أضف سجلًا جديدًا!'),
              )
                  : ListView.builder(
                itemCount: provider.healthRecords.length,
                itemBuilder: (context, index) {
                  final record = provider.healthRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('${record.type}: ${record.medication}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التاريخ: ${record.date.day}/${record.date.month}/${record.date.year}',
                          ),
                          Text('الوصف: ${record.description}'),
                        ],
                      ),
                      trailing: Text(
                        '${record.cost} شيكل',
                      ),
                      isThreeLine: true,
                      onLongPress: () => _showDeleteDialog(record.id!, widget.flockId),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddHealthRecordScreen(flockId: widget.flockId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text('إضافة سجل صحي جديد'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(int recordId, int flockId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف سجل'),
        content: const Text('هل أنت متأكد من حذف هذا السجل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<HealthRecordProvider>(context, listen: false);
      await provider.deleteHealthRecord(recordId, flockId);
    }
  }
}