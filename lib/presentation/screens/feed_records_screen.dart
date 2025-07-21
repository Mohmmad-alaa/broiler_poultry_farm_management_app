import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_record_provider.dart';
import 'add_feed_record_screen.dart';

class FeedRecordsScreen extends StatefulWidget {
  final int flockId;

  const FeedRecordsScreen({Key? key, required this.flockId}) : super(key: key);

  @override
  _FeedRecordsScreenState createState() => _FeedRecordsScreenState();
}

class _FeedRecordsScreenState extends State<FeedRecordsScreen> {
  @override
  void initState() {
    super.initState();
    // Load feed records when screen initializes
    Future.microtask(() =>
        Provider.of<FeedRecordProvider>(context, listen: false)
            .loadFeedRecords(widget.flockId)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedRecordProvider>(
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
                  onPressed: () => provider.loadFeedRecords(widget.flockId),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي العلف: ${provider.getTotalFeedQuantity().toStringAsFixed(2)} كجم',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'إجمالي التكلفة: ${provider.getTotalFeedCost().toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.feedRecords.isEmpty
                  ? const Center(
                child: Text('لا توجد سجلات تغذية. أضف سجلًا جديدًا!'),
              )
                  : ListView.builder(
                itemCount: provider.feedRecords.length,
                itemBuilder: (context, index) {
                  final record = provider.feedRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('نوع العلف: ${record.feedType}'),
                      subtitle: Text(
                        'التاريخ: ${record.date.day}/${record.date.month}/${record.date.year}',
                      ),
                      trailing: Text(
                        '${record.quantity} كجم \n ${record.cost} شيكل',
                      ),
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
                      builder: (context) => AddFeedRecordScreen(flockId: widget.flockId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text('إضافة سجل تغذية جديد'),
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
      final provider = Provider.of<FeedRecordProvider>(context, listen: false);
      await provider.deleteFeedRecord(recordId, flockId);
    }
  }
}