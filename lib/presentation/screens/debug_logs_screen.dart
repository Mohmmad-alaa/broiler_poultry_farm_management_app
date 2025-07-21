import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/excel_export_provider.dart';

class DebugLogsScreen extends StatelessWidget {
  const DebugLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الأخطاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<ExcelExportProvider>().clearDebugLogs();
            },
            tooltip: 'مسح السجل',
          ),
        ],
      ),
      body: Consumer<ExcelExportProvider>(
        builder: (context, provider, child) {
          final logs = provider.debugLogs;
          
          if (logs.isEmpty) {
            return const Center(
              child: Text('لا توجد رسائل في السجل'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[logs.length - 1 - index]; // عرض الأحدث أولاً
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    log,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}