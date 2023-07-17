import 'package:chat_app/models/tab.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/widgets/settings_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<TabData> _tabs = [
    TabData(title: 'Chat', widget: const ChatScreen()),
    TabData(title: 'Settings', widget: const SettingsTab()),
  ];

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabs[_currentIndex].title),
        actions: _currentIndex == _tabs.length - 1
            ? [
                IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(
                      Icons.exit_to_app,
                    ))
              ]
            : null,
      ),
      body: _tabs[_currentIndex].widget,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: _selectPage,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
      ),
    );
  }
}
