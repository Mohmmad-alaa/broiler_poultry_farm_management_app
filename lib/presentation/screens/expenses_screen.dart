import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final int flockId;

  const ExpensesScreen({Key? key, required this.flockId}) : super(key: key);

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    // Load expenses when screen initializes
    Future.microtask(() =>
        Provider.of<ExpenseProvider>(context, listen: false)
            .loadExpenses(widget.flockId)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('حدث خطأ: ${provider.error}'),
                ElevatedButton(
                  onPressed: () => provider.loadExpenses(widget.flockId),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final expensesByCategory = provider.getExpensesByCategory();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'إجمالي المصاريف: ${provider.getTotalExpenseCost().toStringAsFixed(2)} شيكل',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (expensesByCategory.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'المصاريف حسب الفئة:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: expensesByCategory.length,
                  itemBuilder: (context, index) {
                    final category = expensesByCategory.keys.elementAt(index);
                    final amount = expensesByCategory[category]!;
                    return Card(
                      color: Colors.green.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('${amount.toStringAsFixed(2)} شيكل'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Expanded(
              child: provider.expenses.isEmpty
                  ? const Center(
                child: Text('لا توجد مصاريف. أضف مصروفًا جديدًا!'),
              )
                  : ListView.builder(
                itemCount: provider.expenses.length,
                itemBuilder: (context, index) {
                  final expense = provider.expenses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('${expense.category}: ${expense.description}'),
                      subtitle: Text(
                        'التاريخ: ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                      ),
                      trailing: Text(
                        '${expense.amount} شيكل',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      onLongPress: () => _showDeleteDialog(expense.id!, widget.flockId),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(flockId: widget.flockId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text('إضافة مصروف جديد'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(int expenseId, int flockId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مصروف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.deleteExpense(expenseId, flockId);
    }
  }
}