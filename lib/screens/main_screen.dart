import 'package:flutter/material.dart';
import '../routes/routes.dart';

class MainScreen extends StatefulWidget {
  final String? initialRoute;
  final dynamic arguments;

  const MainScreen({super.key, this.initialRoute, this.arguments});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            body: _content,
          ),
        ],
      ),
    );
  }
}