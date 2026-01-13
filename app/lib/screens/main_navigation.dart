import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'home/home_page.dart';
import 'my_tours/my_tours_page.dart';
import 'profile/profile_page.dart';
import '../providers/auth_provider.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Remove splash screen when app is ready
    FlutterNativeSplash.remove();
    
    // Precache profile image after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheProfileImage();
    });
  }

  /// Precache the user's profile photo so it loads faster when they navigate to profile tab
  void _precacheProfileImage() {
    final authState = ref.read(authProvider);
    final photoUrl = authState.user?.photoUrl;
    
    if (photoUrl != null && photoUrl.isNotEmpty && mounted) {
      try {
        precacheImage(NetworkImage(photoUrl), context);
        print('🖼️ Precaching profile image: $photoUrl');
      } catch (e) {
        print('⚠️ Failed to precache image: $e');
      }
    }
  }

  final List<Widget> _pages = const [
    HomePage(),
    MyToursPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'My Tours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
