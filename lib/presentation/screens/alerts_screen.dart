import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../providers/flock_provider.dart';
import '../../domain/entities/alert.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AlertProvider>(context, listen: false).loadAllActiveAlerts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات'),
        centerTitle: true,
      ),
      body: Consumer<AlertProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text('خطأ: ${provider.error}'));
          }

          if (provider.alerts.isEmpty) {
            return const Center(child: Text('لا توجد تنبيهات'));
          }

          return ListView.builder(
            itemCount: provider.alerts.length,
            itemBuilder: (context, index) {
              final alert = provider.alerts[index];
              return _buildAlertCard(context, alert);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlertDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert) {
    Color priorityColor;
    switch (alert.priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          child: const Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(alert.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description),
            const SizedBox(height: 4),
            Text(
              'تاريخ الاستحقاق: ${DateFormat('yyyy-MM-dd').format(alert.dueDate)}',
              style: TextStyle(
                color: alert.dueDate.isBefore(DateTime.now()) && !alert.isCompleted
                    ? Colors.red
                    : null,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                alert.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: alert.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                if (!alert.isCompleted) {
                  Provider.of<AlertProvider>(context, listen: false)
                      .markAlertAsCompleted(alert.id!);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteAlert(context, alert.id!),
            ),
          ],
        ),
        onTap: () => _showEditAlertDialog(context, alert),
      ),
    );
  }

  void _confirmDeleteAlert(BuildContext context, int alertId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا التنبيه؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AlertProvider>(context, listen: false).deleteAlert(alertId);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddAlertDialog(BuildContext context) {
    final flockProvider = Provider.of<FlockProvider>(context, listen: false);
    final activeFlocks = flockProvider.activeFlocks;
    int? selectedFlockId = activeFlocks.isNotEmpty ? activeFlocks.first.id : null;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedPriority = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة تنبيه جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'القطيع'),
                  value: selectedFlockId,
                  items: activeFlocks.map((flock) {
                    return DropdownMenuItem<int>(
                      value: flock.id,
                      child: Text(flock.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFlockId = value;
                    });
                  },
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('تاريخ الاستحقاق: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الأولوية'),
                  value: selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('عالية')),
                    DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                    DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    selectedFlockId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                  );
                  return;
                }

                Provider.of<AlertProvider>(context, listen: false).addAlert(
                  selectedFlockId!,
                  titleController.text,
                  descriptionController.text,
                  selectedDate,
                  selectedPriority,
                );

                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAlertDialog(BuildContext context, Alert alert) {
    final titleController = TextEditingController(text: alert.title);
    final descriptionController = TextEditingController(text: alert.description);
    DateTime selectedDate = alert.dueDate;
    String selectedPriority = alert.priority;
    bool isCompleted = alert.isCompleted;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل التنبيه'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('تاريخ الاستحقاق: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الأولوية'),
                  value: selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('عالية')),
                    DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                    DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('مكتمل'),
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                  );
                  return;
                }

                Provider.of<AlertProvider>(context, listen: false).updateAlert(
                  alert.id!,
                  alert.flockId,
                  titleController.text,
                  descriptionController.text,
                  selectedDate,
                  isCompleted,
                  selectedPriority,
                );

                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}