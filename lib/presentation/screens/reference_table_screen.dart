import 'package:flutter/material.dart';

class ReferenceTableScreen extends StatelessWidget {
  const ReferenceTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول المعايير المرجعية'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('العمر (يوم)')),
              DataColumn(label: Text('الأسبوع')),
              DataColumn(label: Text('الوزن (جرام)')),
              DataColumn(label: Text('استهلاك العلف (جرام)')),
              DataColumn(label: Text('وقت الإطلاق (دقيقة)')),
              DataColumn(label: Text('درجة الحرارة')),
            ],
            rows: [
              // بيانات الأسبوع الأول
              _buildDataRow(1, 1, 61, 13, 0, 33.0),
              _buildDataRow(2, 1, 79, 17, 0, 32.7),
              _buildDataRow(3, 1, 99, 21, 0, 32.4),
              _buildDataRow(4, 1, 122, 24, 0, 32.1),
              _buildDataRow(5, 1, 148, 28, 0, 31.8),
              _buildDataRow(6, 1, 176, 32, 0, 31.5),
              _buildDataRow(7, 1, 208, 36, 0, 31.2),
              // بيانات الأسبوع الثاني
              _buildDataRow(8, 2, 242, 40, 30, 30.9),
              _buildDataRow(9, 2, 280, 45, 60, 30.6),
              _buildDataRow(10, 2, 321, 49, 90, 30.3),
              _buildDataRow(11, 2, 366, 54, 120, 30.0),
              _buildDataRow(12, 2, 414, 58, 180, 29.7),
              _buildDataRow(13, 2, 465, 63, 180, 29.4),
              _buildDataRow(14, 2, 519, 69, 180, 29.1),
              // بيانات الأسبوع الثالث
              _buildDataRow(15, 3, 576, 74, 180, 28.8),
              _buildDataRow(16, 3, 637, 79, 180, 28.5),
              _buildDataRow(17, 3, 701, 85, 180, 28.2),
              _buildDataRow(18, 3, 768, 90, 180, 27.9),
              _buildDataRow(19, 3, 837, 96, 180, 27.6),
              _buildDataRow(20, 3, 910, 102, 180, 27.3),
              _buildDataRow(21, 3, 985, 108, 180, 27.0),
              // بيانات الأسبوع الرابع
              _buildDataRow(22, 4, 1062, 114, 180, 26.7),
              _buildDataRow(23, 4, 1142, 120, 180, 26.4),
              _buildDataRow(24, 4, 1225, 125, 180, 26.1),
              _buildDataRow(25, 4, 1309, 131, 180, 25.8),
              _buildDataRow(26, 4, 1395, 137, 180, 25.5),
              _buildDataRow(27, 4, 1483, 143, 180, 25.2),
              _buildDataRow(28, 4, 1573, 149, 180, 24.9),
              // بيانات الأسبوع الخامس
              _buildDataRow(29, 5, 1664, 154, 180, 24.6),
              _buildDataRow(30, 5, 1757, 160, 180, 24.3),
              _buildDataRow(31, 5, 1851, 165, 180, 24.0),
              _buildDataRow(32, 5, 1946, 170, 120, 23.7),
              _buildDataRow(33, 5, 2041, 175, 90, 23.4),
              _buildDataRow(34, 5, 2138, 180, 60, 23.1),
              _buildDataRow(35, 5, 2235, 185, 30, 22.8),
              // بيانات الأسبوع السادس
              _buildDataRow(36, 6, 2332, 189, 0, 22.5),
              _buildDataRow(37, 6, 2430, 194, 0, 22.2),
              _buildDataRow(38, 6, 2527, 198, 0, 21.9),
              _buildDataRow(39, 6, 2625, 202, 0, 21.6),
              _buildDataRow(40, 6, 2723, 206, 0, 21.3),
              _buildDataRow(41, 6, 2821, 209, 0, 21.0),
              _buildDataRow(42, 6, 2918, 213, 0, 20.7),
              // بيانات الأسبوع السابع
              _buildDataRow(43, 7, 3015, 216, 0, 20.4),
              _buildDataRow(44, 7, 3112, 219, 0, 20.1),
              _buildDataRow(45, 7, 3207, 222, 0, 19.8),
              _buildDataRow(46, 7, 3303, 224, 0, 19.5),
              _buildDataRow(47, 7, 3397, 227, 0, 19.2),
              _buildDataRow(48, 7, 3491, 229, 0, 18.9),
              _buildDataRow(49, 7, 3583, 231, 0, 18.6),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(int day, int week, int weight, int feedConsumption, int releaseTime, double temperature) {
    return DataRow(
      cells: [
        DataCell(Text('$day')),
        DataCell(Text('$week')),
        DataCell(Text('$weight')),
        DataCell(Text('$feedConsumption')),
        DataCell(Text('$releaseTime')),
        DataCell(Text('$temperature')),
      ],
    );
  }
}