import 'package:broiler_poultry_farm_management_app/presentation/screens/reference_table_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flock_provider.dart';
import 'feed_records_screen.dart';
import 'health_records_screen.dart';
import 'expenses_screen.dart';
import 'daily_records_screen.dart';

class FlockDetailsScreen extends StatefulWidget {
  final int flockId;

  const FlockDetailsScreen({Key? key, required this.flockId}) : super(key: key);

  @override
  _FlockDetailsScreenState createState() => _FlockDetailsScreenState();
}

class _FlockDetailsScreenState extends State<FlockDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Updated to 4 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlockProvider>(
      builder: (context, flockProvider, child) {
        final flock = flockProvider.flocks.firstWhere(
              (f) => f.id == widget.flockId,
          orElse: () => throw Exception('Flock not found'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('تفاصيل القطيع: ${flock.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.table_chart),
                tooltip: 'جدول المعايير المرجعية',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferenceTableScreen(),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'complete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('إنهاء القطيع'),
                        content: const Text('هل أنت متأكد من إنهاء هذا القطيع؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('تأكيد'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await flockProvider.updateFlockStatus(widget.flockId, 'completed');
                      Navigator.pop(context);
                    }
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('حذف القطيع'),
                        content: const Text('هل أنت متأكد من حذف هذا القطيع؟ لا يمكن التراجع عن هذا الإجراء.'),
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
                      await flockProvider.deleteFlock(widget.flockId);
                      Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'complete',
                    child: Text('إنهاء القطيع'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف القطيع'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('رقم الدفعة: ${flock.batchNumber}'),
                            Text('الحالة: ${_getStatusText(flock.status)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('عدد الطيور: ${flock.birdCount}'),
                            Text('النوع: ${flock.birdType}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('تاريخ البدء: ${flock.startDate.day}/${flock.startDate.month}/${flock.startDate.year}'),
                            if (flock.endDate != null)
                              Text('تاريخ الانتهاء: ${flock.endDate!.day}/${flock.endDate!.month}/${flock.endDate!.year}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Daily Records Tab
                    DailyRecordsScreen(flock: flock),
                    // Existing Tabs
                    FeedRecordsScreen(flockId: widget.flockId),
                    HealthRecordsScreen(flockId: widget.flockId),
                    ExpensesScreen(flockId: widget.flockId),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'culled':
        return 'تم التخلص منه';
      default:
        return status;
    }
  }
}