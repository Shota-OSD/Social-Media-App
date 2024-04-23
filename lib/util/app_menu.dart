import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../main_pages/add_post_page.dart';
import '../main_pages/friends_page.dart';
import '../main_pages/home_screen.dart';
import '../main_pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// global topics page, friends list page, add post page, profile page

class AppTabs extends StatefulWidget {
  const AppTabs({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  late final List<Widget> _screens;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _screens = [
      ClassFlowHome(),
      AddPost(),
      FriendsList(auth: widget.auth),
      ProfilePage(),
    ];
  }

  void _navigateBottomBar(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: GNav(
          color: Colors.deepOrange[200],
          onTabChange: (value) => _navigateBottomBar(value),
          selectedIndex: _selectedIndex,
          activeColor: Colors.deepOrange,
          gap: 8,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'home',
            ),
            GButton(
              icon: Icons.add,
              text: 'add post',
            ),
            GButton(
              icon: Icons.people,
              text: 'friends',
            ),
            GButton(
              icon: Icons.person,
              text: 'my profile',
            ),
          ]),
    );
  }
}
