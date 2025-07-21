import 'package:broiler_poultry_farm_management_app/presentation/screens/alerts_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flock_provider.dart';
import 'backup_screen.dart';
import 'flock_list_screen.dart';
import 'add_flock_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FlockListScreen(),
    const AddFlockScreen(),
    const ReportsScreen(),
    const AlertsScreen(),
    const BackupScreen()
  ];

  @override
  void initState() {
    super.initState();
    // Load flocks when app starts
    Future.microtask(
        () => Provider.of<FlockProvider>(context, listen: false).loadFlocks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة مزرعة الدواجن'),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'القطعان',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'إضافة قطيع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'التقارير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'التنبيهات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'نسخة احتياط',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
