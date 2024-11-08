import 'package:flutter/material.dart';
import 'package:tradingview/tradingview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TVPage(),
    );
  }
}

class TVPage extends StatefulWidget {
  const TVPage({super.key});

  @override
  State<TVPage> createState() => _TVPageState();
}

class _TVPageState extends State<TVPage> {
  String symbol = 'BBCA';
  bool darkMode = false;
  String locale = 'id';
  bool hideSideToolbar = false;

  loadChart() {
    ChartManager.update(
      symbol: symbol,
      theme: darkMode ? 'dark' : 'light',
      hideSideToolbar: hideSideToolbar,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TradingView by Appsworkspace'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                hideSideToolbar = !hideSideToolbar;
              });
              loadChart();
            },
            icon: Icon(
              hideSideToolbar
                  ? Icons.view_sidebar_outlined
                  : Icons.view_sidebar_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                darkMode = !darkMode;
              });
              loadChart();
            },
            icon: Icon(darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Tradingview(
        symbol: symbol,
        theme: darkMode ? 'dark' : 'light',
        locale: locale,
        hideSideToolbar: hideSideToolbar,
      ),
    );
  }
}
