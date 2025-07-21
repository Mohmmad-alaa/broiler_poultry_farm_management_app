import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/daily_record.dart';
import '../../domain/entities/flock.dart';
import '../providers/daily_record_provider.dart';
import '../../data/models/daily_record_model.dart';

class EditDailyRecordScreen extends StatefulWidget {
  final Flock flock;
  final DailyRecord record;

  const EditDailyRecordScreen({
    Key? key,
    required this.flock,
    required this.record,
  }) : super(key: key);

  @override
  State<EditDailyRecordScreen> createState() => _EditDailyRecordScreenState();
}

class _EditDailyRecordScreenState extends State<EditDailyRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mortalityController = TextEditingController();
  final _weightController = TextEditingController();
  final _feedConsumptionController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات الحالية في النموذج
    _mortalityController.text = widget.record.mortality.toString();
    _weightController.text = widget.record.weight.toString();
    _feedConsumptionController.text = widget.record.feedConsumption.toString();
    _notesController.text = widget.record.notes;
    _date = widget.record.date;
  }

  @override
  void dispose() {
    _mortalityController.dispose();
    _weightController.dispose();
    _feedConsumptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DailyRecordProvider>(context, listen: false);

      // إنشاء نموذج السجل المحدث
      final updatedRecord = DailyRecordModel(
        id: widget.record.id,
        flockId: widget.flock.id!,
        date: _date,
        mortality: int.parse(_mortalityController.text),
        weight: double.parse(_weightController.text),
        feedConsumption: double.parse(_feedConsumptionController.text),
        notes: _notesController.text,
      );

      final success = await provider.updateDailyRecord(updatedRecord);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث السجل بنجاح')),
        );
        Navigator.pop(context);
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث السجل: ${provider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل السجل اليومي'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'التاريخ',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_date.year}/${_date.month}/${_date.day}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _date = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mortalityController,
                  decoration: const InputDecoration(
                    labelText: 'عدد النفوق',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عدد النفوق';
                    }
                    if (int.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'متوسط الوزن (جرام)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال متوسط الوزن';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _feedConsumptionController,
                  decoration: const InputDecoration(
                    labelText: 'استهلاك العلف (كجم)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال استهلاك العلف';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'حفظ التغييرات',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}