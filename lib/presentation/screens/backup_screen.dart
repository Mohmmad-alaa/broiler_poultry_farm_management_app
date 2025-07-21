import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/backup_provider.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي واستعادة البيانات'),
      ),
      body: Consumer<BackupProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النسخ الاحتياطي',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'قم بإنشاء نسخة احتياطية من جميع بيانات التطبيق. يمكنك استخدام هذه النسخة لاستعادة البيانات في حالة فقدانها.',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                            final success = await provider.createBackup();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
                                ),
                              );
                            } else if (provider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل إنشاء النسخة الاحتياطية: ${provider.error}'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.backup),
                          label: const Text('إنشاء نسخة احتياطية'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استعادة البيانات',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'استعادة البيانات من نسخة احتياطية سابقة. سيتم استبدال جميع البيانات الحالية بالبيانات من النسخة الاحتياطية.',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد الاستعادة'),
                                content: const Text(
                                  'سيتم استبدال جميع البيانات الحالية بالبيانات من النسخة الاحتياطية. هل أنت متأكد من المتابعة؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('استعادة'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final success = await provider.restoreBackup();
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم استعادة البيانات بنجاح'),
                                  ),
                                );
                              } else if (provider.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('فشل استعادة البيانات: ${provider.error}'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('استعادة البيانات'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}