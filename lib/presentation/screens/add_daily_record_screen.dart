import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/flock.dart';
import '../providers/daily_record_provider.dart';

class AddDailyRecordScreen extends StatefulWidget {
  final Flock flock;

  const AddDailyRecordScreen({Key? key, required this.flock}) : super(key: key);

  @override
  State<AddDailyRecordScreen> createState() => _AddDailyRecordScreenState();
}

class _AddDailyRecordScreenState extends State<AddDailyRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mortalityController = TextEditingController();
  final _weightController = TextEditingController();
  final _feedConsumptionController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _mortalityController.dispose();
    _weightController.dispose();
    _feedConsumptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.flock.startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DailyRecordProvider>(context, listen: false);

      final success = await provider.addDailyRecord(
        widget.flock.id!,
        _date,
        int.parse(_mortalityController.text),
        double.parse(_weightController.text),
        double.parse(_feedConsumptionController.text),
        _notesController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة السجل اليومي بنجاح')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة السجل: ${provider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سجل يومي'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'التاريخ',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
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
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
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
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'الرجاء إدخال رقم صحيح موجب';
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
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'الرجاء إدخال رقم صحيح موجب';
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
                  'إضافة سجل',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}