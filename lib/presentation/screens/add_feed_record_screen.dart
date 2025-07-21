import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_record_provider.dart';

class AddFeedRecordScreen extends StatefulWidget {
  final int flockId;

  const AddFeedRecordScreen({Key? key, required this.flockId}) : super(key: key);

  @override
  _AddFeedRecordScreenState createState() => _AddFeedRecordScreenState();
}

class _AddFeedRecordScreenState extends State<AddFeedRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  String _feedType = 'starter';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
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
      final provider = Provider.of<FeedRecordProvider>(context, listen: false);

      final success = await provider.addFeedRecord(
        widget.flockId,
        _date,
        _feedType,
        double.parse(_quantityController.text),
        double.parse(_costController.text),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة سجل التغذية بنجاح')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة سجل التغذية: ${provider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سجل تغذية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _feedType,
                decoration: const InputDecoration(
                  labelText: 'نوع العلف',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'starter', child: Text('بادئ')),
                  DropdownMenuItem(value: 'grower', child: Text('نامي')),
                  DropdownMenuItem(value: 'finisher', child: Text('ناهي')),
                  DropdownMenuItem(value: 'other', child: Text('آخر')),
                ],
                onChanged: (value) {
                  setState(() {
                    _feedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'الكمية (كجم)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الكمية';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'الرجاء إدخال رقم موجب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'التكلفة',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال التكلفة';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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