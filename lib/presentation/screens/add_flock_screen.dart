import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flock_provider.dart';

class AddFlockScreen extends StatefulWidget {
  const AddFlockScreen({Key? key}) : super(key: key);

  @override
  _AddFlockScreenState createState() => _AddFlockScreenState();
}

class _AddFlockScreenState extends State<AddFlockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _birdCountController = TextEditingController();
  String _birdType = 'broiler';
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _batchNumberController.dispose();
    _birdCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final flockProvider = Provider.of<FlockProvider>(context, listen: false);

      final success = await flockProvider.addFlock(
        _nameController.text,
        _batchNumberController.text,
        _birdType,
        int.parse(_birdCountController.text),
        _startDate,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة القطيع بنجاح')),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _batchNumberController.clear();
        _birdCountController.clear();
        setState(() {
          _startDate = DateTime.now();
          _birdType = 'broiler';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('فشل في إضافة القطيع: ${flockProvider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'إضافة قطيع جديد',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم القطيع',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم القطيع';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم الدفعة',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الدفعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birdCountController,
              decoration: const InputDecoration(
                labelText: 'عدد الطيور',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال عدد الطيور';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'الرجاء إدخال رقم صحيح موجب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _birdType,
              decoration: const InputDecoration(
                labelText: 'نوع الطيور',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'broiler', child: Text('دجاج لاحم')),
                DropdownMenuItem(value: 'cobb', child: Text('كوب')),
                DropdownMenuItem(value: 'ross', child: Text('روص')),
                DropdownMenuItem(value: 'hubbard', child: Text('هابرد')),
              ],
              onChanged: (value) {
                setState(() {
                  _birdType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ البدء',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
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
                'إضافة القطيع',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}