import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flock_provider.dart';
import 'flock_details_screen.dart';

class FlockListScreen extends StatelessWidget {
  const FlockListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlockProvider>(
      builder: (context, flockProvider, child) {
        if (flockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (flockProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('حدث خطأ: ${flockProvider.error}'),
                ElevatedButton(
                  onPressed: () => flockProvider.loadFlocks(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (flockProvider.flocks.isEmpty) {
          return const Center(
            child: Text('لا توجد قطعان. أضف قطيعًا جديدًا!'),
          );
        }

        return ListView.builder(
          itemCount: flockProvider.flocks.length,
          itemBuilder: (context, index) {
            final flock = flockProvider.flocks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(flock.name),
                subtitle: Text('رقم الدفعة: ${flock.batchNumber} | الحالة: ${flock.status}'),
                trailing: Text('${flock.birdCount} طائر'),
                leading: CircleAvatar(
                  backgroundColor: flock.status == 'active'
                      ? Colors.green
                      : Colors.grey,
                  child: const Icon(Icons.pets, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlockDetailsScreen(flockId: flock.id!),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}