import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/map_screen.dart';
import 'screens/flights_screen.dart';
import 'screens/services_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/rent_car_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AirportApp());
}

class AirportApp extends StatelessWidget {
  const AirportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Singa Airport',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(), // ← goes straight to app, native splash handles it
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Main Navigation
// ════════════════════════════════════════════════════════════════════

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMapNavigating = false;
  late AnimationController _fabController;
  String? _targetServiceSection;

  // Cache stateless screens to avoid re-instantiation on every setState
  late final ExploreScreen _exploreScreen;
  late final FlightsScreen _flightsScreen;
  late final ProfileScreen _profileScreen;
  late final TicketScreen _ticketScreen;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove(); // ← removes splash when app is ready
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _exploreScreen = const ExploreScreen();
    _flightsScreen = const FlightsScreen();
    _profileScreen = const ProfileScreen();
    _ticketScreen = const TicketScreen();
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        onProfileTap: () => setState(() => _currentIndex = 5),
        onServiceTap: (section) {
          setState(() {
            _targetServiceSection = section;
            _currentIndex = 4;
          });
        },
        onFlightsTap: () => setState(() => _currentIndex = 3),
        onTicketsTap: () => setState(() => _currentIndex = 6),
        onCarRentTap: () => setState(() => _currentIndex = 7),
      ),
      MapScreen(
        onNavigatingChanged: (isNavigating) {
          setState(() => _isMapNavigating = isNavigating);
        },
      ),
      _exploreScreen,
      _flightsScreen,
      ServicesScreen(initialSection: _targetServiceSection),
      _profileScreen,
      _ticketScreen,
      RentCarScreen(onBack: () => setState(() => _currentIndex = 0)),
    ];
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isMapNavigating ? 0 : 120,
        child: ClipRect(
          child: Wrap(
            children: [_buildBottomNav()],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 48, bottom: 32),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded,           Icons.home_outlined),
            _buildNavItem(1, Icons.map_rounded,            Icons.map_outlined),
            _buildNavItem(2, Icons.calendar_month_rounded, Icons.calendar_today_outlined),
            _buildNavItem(3, Icons.grid_view_rounded,      Icons.grid_view_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected
              ? AppColors.textDark
              : AppColors.textDark.withValues(alpha: 0.6),
          size: 26,
        ),
      ),
    );
  }
}