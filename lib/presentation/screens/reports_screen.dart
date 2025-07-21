import 'package:broiler_poultry_farm_management_app/domain/entities/daily_record.dart';
import 'package:broiler_poultry_farm_management_app/presentation/providers/excel_export_provider.dart';
import 'package:broiler_poultry_farm_management_app/presentation/screens/debug_logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_record_provider.dart';
import '../providers/flock_provider.dart';
import '../providers/feed_record_provider.dart';
import '../providers/health_record_provider.dart';
import '../providers/expense_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int? _selectedFlockId;
  // نقل تعريف المتغير إلى مستوى الكلاس بدلاً من داخل دالة build
  final TextEditingController _sellingPriceController =
      TextEditingController(text: '9.0');
  double sellingPrice = 9.0;

  // إضافة متغيرات للخيارات المتقدمة
  bool _showAdvancedOptions = false;
  final TextEditingController _transportCostController =
      TextEditingController(text: '0.0');
  final TextEditingController _marketingCostController =
      TextEditingController(text: '0.0');
  final TextEditingController _laborCostController =
      TextEditingController(text: '0.0');
  final TextEditingController _utilityRateController =
      TextEditingController(text: '0.0');

  double transportCost = 0.0;
  double marketingCost = 0.0;
  double laborCost = 0.0;
  double utilityRate = 0.0; // نسبة مئوية للمرافق (كهرباء، ماء، إلخ)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // تحديث البيانات إذا كان هناك قطيع محدد
    if (_selectedFlockId != null) {
      // استخدام addPostFrameCallback لتنفيذ الكود بعد اكتمال الإطار الحالي
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFlockData(_selectedFlockId!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initial loading if needed
    _sellingPriceController.addListener(_updateSellingPrice);
    _transportCostController.addListener(_updateTransportCost);
    _marketingCostController.addListener(_updateMarketingCost);
    _laborCostController.addListener(_updateLaborCost);
    _utilityRateController.addListener(_updateUtilityRate);
  }

  @override
  void dispose() {
    _sellingPriceController.removeListener(_updateSellingPrice);
    _transportCostController.removeListener(_updateTransportCost);
    _marketingCostController.removeListener(_updateMarketingCost);
    _laborCostController.removeListener(_updateLaborCost);
    _utilityRateController.removeListener(_updateUtilityRate);

    _sellingPriceController.dispose();
    _transportCostController.dispose();
    _marketingCostController.dispose();
    _laborCostController.dispose();
    _utilityRateController.dispose();
    super.dispose();
  }

  void _updateSellingPrice() {
    setState(() {
      sellingPrice = double.tryParse(_sellingPriceController.text) ?? 9.0;
    });
  }

  void _updateTransportCost() {
    setState(() {
      transportCost = double.tryParse(_transportCostController.text) ?? 0.0;
    });
  }

  void _updateMarketingCost() {
    setState(() {
      marketingCost = double.tryParse(_marketingCostController.text) ?? 0.0;
    });
  }

  void _updateLaborCost() {
    setState(() {
      laborCost = double.tryParse(_laborCostController.text) ?? 0.0;
    });
  }

  void _updateUtilityRate() {
    setState(() {
      utilityRate = double.tryParse(_utilityRateController.text) ?? 0.0;
    });
  }

  // Add this method to handle flock selection and data loading
  void _loadFlockData(int flockId) {
    // Load all data for the selected flock
    Provider.of<FeedRecordProvider>(context, listen: false)
        .loadFeedRecords(flockId);
    Provider.of<HealthRecordProvider>(context, listen: false)
        .loadHealthRecords(flockId);
    Provider.of<ExpenseProvider>(context, listen: false).loadExpenses(flockId);
    Provider.of<DailyRecordProvider>(context, listen: false)
        .loadDailyRecords(flockId);
  }

  @override
  Widget build(BuildContext context) {
    final flockProvider = Provider.of<FlockProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تقارير المزرعة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            value: _selectedFlockId,
            decoration: const InputDecoration(
              labelText: 'اختر القطيع',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('جميع القطعان'),
              ),
              ...flockProvider.flocks.map((flock) => DropdownMenuItem(
                    value: flock.id,
                    child: Text(flock.name),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFlockId = value;
              });

              if (value != null) {
                _loadFlockData(value);
              }
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _selectedFlockId == null
                ? _buildOverallReport(context)
                : _buildFlockReport(context, _selectedFlockId!),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallReport(BuildContext context) {
    final flockProvider = Provider.of<FlockProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص المزرعة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إجمالي القطعان: ${flockProvider.flocks.length}'),
                  const SizedBox(height: 8),
                  Text('القطعان النشطة: ${flockProvider.activeFlocks.length}'),
                  const SizedBox(height: 8),
                  Text(
                      'القطعان المكتملة: ${flockProvider.flocks.where((f) => f.status == 'completed').length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'إحصائيات القطعان',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: flockProvider.flocks.length,
            itemBuilder: (context, index) {
              final flock = flockProvider.flocks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(flock.name),
                  subtitle: Text(
                      'الحالة: ${flock.status} | عدد الطيور: ${flock.birdCount}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        _selectedFlockId = flock.id;
                      });

                      // Load data for the selected flock
                      Provider.of<FeedRecordProvider>(context, listen: false)
                          .loadFeedRecords(flock.id!);
                      Provider.of<HealthRecordProvider>(context, listen: false)
                          .loadHealthRecords(flock.id!);
                      Provider.of<ExpenseProvider>(context, listen: false)
                          .loadExpenses(flock.id!);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlockReport(BuildContext context, int flockId) {
    final flockProvider = Provider.of<FlockProvider>(context);
    final feedProvider = Provider.of<FeedRecordProvider>(context);
    final healthProvider = Provider.of<HealthRecordProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final dailyRecordProvider = Provider.of<DailyRecordProvider>(context);
    final excelExportProvider = Provider.of<ExcelExportProvider>(context);

    // REMOVE this line - don't call loadDailyRecords here
    // dailyRecordProvider.loadDailyRecords(flockId);

    // إضافة إلى _buildFlockReport في reports_screen.dart
    // حساب معدل النمو اليومي
    double avgDailyGrowth = 0;
    if (dailyRecordProvider.records.isNotEmpty &&
        dailyRecordProvider.records.length > 1) {
      final sortedRecords = List<DailyRecord>.from(dailyRecordProvider.records)
        ..sort((a, b) => a.date.compareTo(b.date));

      double totalGrowth = 0;
      int countPairs = 0;

      for (int i = 1; i < sortedRecords.length; i++) {
        if (sortedRecords[i].weight > 0 && sortedRecords[i - 1].weight > 0) {
          int daysDiff = sortedRecords[i]
              .date
              .difference(sortedRecords[i - 1].date)
              .inDays;
          if (daysDiff > 0) {
            double growthRate =
                (sortedRecords[i].weight - sortedRecords[i - 1].weight) /
                    daysDiff;
            totalGrowth += growthRate;
            countPairs++;
          }
        }
      }

      if (countPairs > 0) {
        avgDailyGrowth = totalGrowth / countPairs;
      }
    }

    final flock = flockProvider.flocks.firstWhere(
      (f) => f.id == flockId,
      orElse: () => throw Exception('Flock not found'),
    );

    int totalMortality = 0;

    for (var record in dailyRecordProvider.records) {
      totalMortality += record.mortality;
    }
    double mortalityRate =
        flock.birdCount > 0 ? (totalMortality / flock.birdCount) * 100 : 0;

    // حساب مؤشر كفاءة الإنتاج
    double livability = flock.birdCount > 0
        ? ((flock.birdCount - totalMortality) / flock.birdCount) * 100
        : 0;
    double avgWeight = 0;
    if (dailyRecordProvider.records.isNotEmpty) {
      // نأخذ آخر وزن مسجل
      final latestRecord = dailyRecordProvider.records
          .where((r) => r.weight > 0)
          .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      avgWeight = latestRecord.weight;
    }
    double fcr = feedProvider.getTotalFeedQuantity() > 0 && avgWeight > 0
        ? feedProvider.getTotalFeedQuantity() /
            (avgWeight * (flock.birdCount - totalMortality) / 1000)
        : 0;

    // Calculate days active
    final daysActive = flock.status == 'active'
        ? DateTime.now().difference(flock.startDate).inDays
        : flock.endDate!.difference(flock.startDate).inDays;

    // تأكد من أن daysActive لا يساوي صفر
    final int safeDaysActive = daysActive > 0 ? daysActive : 1;

    // تأكد من أن fcr لا يساوي صفر
    double safeFcr = fcr > 0 ? fcr : 1.0;

    // حساب PEF باستخدام القيم الآمنة
    double pef = livability * avgWeight * 100 / (safeDaysActive * safeFcr);

    // تحديد قيمة معقولة لمؤشر كفاءة الإنتاج (عادة بين 0-500)
    pef = pef.clamp(0, 500);

    // Calculate total costs
    final feedCost = feedProvider.getTotalFeedCost();
    final healthCost = healthProvider.getTotalHealthCost();
    final otherCost = expenseProvider.getTotalExpenseCost();
    final totalCost = feedCost + healthCost + otherCost;

    // Calculate per bird metrics
    final costPerBird = flock.birdCount > 0 ? totalCost / flock.birdCount : 0;
    final feedPerBird = flock.birdCount > 0
        ? feedProvider.getTotalFeedQuantity() / flock.birdCount
        : 0;

    // حساب العائد على الاستثمار
    double totalLiveWeight =
        avgWeight * (flock.birdCount - totalMortality) / 1000; // بالكيلوجرام
    double expectedRevenue = totalLiveWeight * sellingPrice;
    double roi =
        totalCost > 0 ? ((expectedRevenue - totalCost) / totalCost) * 100 : 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // في AppBar أو في مكان مناسب
              IconButton(
                icon: const Icon(Icons.bug_report),
                tooltip: 'سجل الأخطاء',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DebugLogsScreen(),
                    ),
                  );
                },
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             
              Text(
                'تقرير قطيع: ${flock.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // إضافة زر تصدير إلى Excel
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    tooltip: 'تصدير إلى Excel',
                    onPressed: excelExportProvider.isLoading
                        ? null
                        : () async {
                            // إنشاء قاموس لمؤشرات الأداء
                            final performanceMetrics = {
                              'معدل النفوق (%)': mortalityRate,
                              'معدل التحويل الغذائي (FCR)': fcr,
                              'متوسط الوزن (جرام)': avgWeight,
                              'مؤشر كفاءة الإنتاج (PEF)': pef,
                              'معدل النمو اليومي (جرام/يوم)': avgDailyGrowth,
                              'تكلفة الطائر (شيكل)': costPerBird,
                              'استهلاك العلف للطائر (كجم)': feedPerBird,
                              'إجمالي تكلفة العلف (شيكل)': feedCost,
                              'إجمالي تكلفة الصحة (شيكل)': healthCost,
                              'إجمالي التكاليف الأخرى (شيكل)': otherCost,
                              'إجمالي التكاليف (شيكل)': totalCost,
                              'الإيراد المتوقع (شيكل)': expectedRevenue,
                              'العائد على الاستثمار (%)': roi,
                            };

                            final success =
                                await excelExportProvider.exportFlockData(
                              flock: flock,
                              dailyRecords: dailyRecordProvider.records,
                              feedRecords: feedProvider.feedRecords,
                              healthRecords: healthProvider.healthRecords,
                              expenses: expenseProvider.expenses,
                              performanceMetrics: performanceMetrics,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تصدير البيانات بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'فشل في تصدير البيانات: ${excelExportProvider.error}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedFlockId = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('رقم الدفعة: ${flock.batchNumber}'),
                  const SizedBox(height: 8),
                  Text('الحالة: ${flock.status}'),
                  const SizedBox(height: 8),
                  Text('عدد الطيور: ${flock.birdCount}'),
                  const SizedBox(height: 8),
                  Text('النوع: ${flock.birdType}'),
                  const SizedBox(height: 8),
                  Text(
                      'تاريخ البدء: ${flock.startDate.day}/${flock.startDate.month}/${flock.startDate.year}'),
                  const SizedBox(height: 8),
                  if (flock.endDate != null)
                    Text(
                        'تاريخ الانتهاء: ${flock.endDate!.day}/${flock.endDate!.month}/${flock.endDate!.year}'),
                  const SizedBox(height: 8),
                  Text('عدد الأيام: $daysActive'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ملخص التكاليف',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تكلفة العلف: ${feedCost.toStringAsFixed(2)} شيكل'),
                  const SizedBox(height: 8),
                  Text('تكلفة الصحة: ${healthCost.toStringAsFixed(2)} شيكل'),
                  const SizedBox(height: 8),
                  Text('تكاليف أخرى: ${otherCost.toStringAsFixed(2)} شيكل'),
                  const Divider(),
                  Text(
                    'إجمالي التكاليف: ${totalCost.toStringAsFixed(2)} شيكل',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'مؤشرات الأداء',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تكلفة الطائر: ${costPerBird.toStringAsFixed(2)} شيكل'),
                  const SizedBox(height: 8),
                  Text(
                      'استهلاك العلف للطائر: ${feedPerBird.toStringAsFixed(2)} كجم'),
                  const SizedBox(height: 8),
                  Text(
                      'معدل التحويل الغذائي: ${feedProvider.getTotalFeedQuantity() > 0 ? (feedProvider.getTotalFeedQuantity() / flock.birdCount).toStringAsFixed(2) : "غير متوفر"}'),
                  const SizedBox(height: 8),
                  Text(
                      'معدل النمو اليومي: ${avgDailyGrowth.toStringAsFixed(2)} جرام/يوم'),
                  const SizedBox(height: 8),
                  Text('مؤشر كفاءة الإنتاج (PEF): ${pef.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text(
                      'نسبة النفوق التراكمية: ${mortalityRate.toStringAsFixed(2)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sellingPriceController,
                  decoration: const InputDecoration(
                    labelText: 'سعر البيع (شيكل/كجم)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  // يمكن إزالة onChanged لأننا نستخدم المستمع
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // تحديث السعر من النص المدخل
                    sellingPrice =
                        double.tryParse(_sellingPriceController.text) ?? 30.0;
                    // إعادة حساب الإيراد المتوقع
                    double totalLiveWeight =
                        avgWeight * (flock.birdCount - totalMortality) / 1000;
                    expectedRevenue = totalLiveWeight * sellingPrice;
                    // إعادة حساب العائد على الاستثمار
                    roi = totalCost > 0
                        ? ((expectedRevenue - totalCost) / totalCost) * 100
                        : 0;
                  });
                },
                child: const Text('حساب'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('الإيراد المتوقع: ${expectedRevenue.toStringAsFixed(2)} شيكل'),
          const SizedBox(height: 8),
          Text(
            'العائد على الاستثمار: ${roi.toStringAsFixed(2)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: roi >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'مقارنة مع المعايير القياسية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(
                          child: Text('المؤشر',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('القيمة الحالية',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('المعيار القياسي',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const Divider(),
                  _buildComparisonRow(
                      'معدل النفوق',
                      '${mortalityRate.toStringAsFixed(2)}%',
                      '5%',
                      mortalityRate <= 5),
                  _buildComparisonRow('معدل التحويل الغذائي',
                      fcr.toStringAsFixed(2), '1.8', fcr <= 1.8),
                  _buildComparisonRow('متوسط الوزن (جرام)',
                      avgWeight.toStringAsFixed(0), '2200', avgWeight >= 2200),
                  _buildComparisonRow('مؤشر كفاءة الإنتاج',
                      pef.toStringAsFixed(0), '300', pef >= 300),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// إضافة دالة مساعدة لبناء صفوف المقارنة
Widget _buildComparisonRow(
    String indicator, String currentValue, String standardValue, bool isGood) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Expanded(child: Text(indicator)),
        Expanded(
          child: Text(
            currentValue,
            style: TextStyle(
              color: isGood ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Text(standardValue)),
      ],
    ),
  );
}
