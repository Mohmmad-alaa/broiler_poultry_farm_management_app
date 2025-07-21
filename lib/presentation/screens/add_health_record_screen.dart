import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_record_provider.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final int flockId;

  const AddHealthRecordScreen({Key? key, required this.flockId}) : super(key: key);

  @override
  _AddHealthRecordScreenState createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _medicationController = TextEditingController();
  final _costController = TextEditingController();
  String _type = 'vaccination';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _medicationController.dispose();
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
      final provider = Provider.of<HealthRecordProvider>(context, listen: false);

      final success = await provider.addHealthRecord(
        widget.flockId,
        _date,
        _type,
        _descriptionController.text,
        _medicationController.text,
        double.parse(_costController.text),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة السجل الصحي بنجاح')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة السجل الصحي: ${provider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('إضافة سجل صحي'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: [
    DropdownButtonFormField<String>(
    value: _type,
    decoration: const InputDecoration(
    labelText: 'النوع',
    border: OutlineInputBorder(),
    ),
    items: const [
    DropdownMenuItem(value: 'vaccination', child: Text('تطعيم')),
    DropdownMenuItem(value: 'medication', child: Text('علاج')),
    DropdownMenuItem(value: 'observation', child: Text('ملاحظة')),
    ],
    onChanged: (value) {
    setState(() {
    _type = value!;
    });
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _descriptionController,
    decoration: const InputDecoration(
    labelText: 'الوصف',
    border: OutlineInputBorder(),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'الرجاء إدخال وصف';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _medicationController,
      decoration: const InputDecoration(
        labelText: 'الدواء / اللقاح',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال اسم الدواء أو اللقاح';
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