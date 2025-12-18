import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../routes/routes.dart';

class MainScreen extends StatefulWidget {
  final String? initialRoute;
  final dynamic arguments;

  const MainScreen({super.key, this.initialRoute, this.arguments});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late Widget _content;

  @override
  void initState() {
    super.initState();

    _setContent(widget.initialRoute ?? '/dashboard');
  }

 void _setContent(String route, {dynamic arguments}) {
    setState(() {
      _content = getPageForRoute(
        context, 
        route,
        arguments: arguments, 
        onNavigate: _setContent,
      );
      
      if (route == '/dashboard') _selectedIndex = 0;
      if (route == '/profile') _selectedIndex = 1;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onSidebarItemTapped(String route) {
    setState(() {
      _setContent(route);
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      _onSidebarItemTapped('/dashboard');
    } else if (index == 2) {
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
        _onSidebarItemTapped('/profile');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            body: _content,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onBottomNavTapped,
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
              selectedItemColor:
                  theme.bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor:
                  theme.bottomNavigationBarTheme.unselectedItemColor,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Icon(Icons.home),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Icon(Icons.person),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Icon(Icons.exit_to_app),
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}