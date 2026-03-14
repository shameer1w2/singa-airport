import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final Function(String)? onServiceTap;
  final VoidCallback? onFlightsTap;
  final VoidCallback? onTicketsTap;
  final VoidCallback? onCarRentTap;

  const HomeScreen({
    super.key,
    this.onProfileTap,
    this.onServiceTap,
    this.onFlightsTap,
    this.onTicketsTap,
    this.onCarRentTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Flight> _flightBoard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlightsData();
  }

  Future<void> _loadFlightsData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/flights.json');
      final data = json.decode(response) as Map<String, dynamic>;
      
      if (mounted) {
        setState(() {
          _flightBoard = (data['departures'] as List)
              .map((e) => Flight.fromJson(e as Map<String, dynamic>))
              .take(5) // Just show top 5 on home
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading flights on home: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good afternoon!',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Airport map',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onProfileTap?.call();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '👨‍🚀',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              // Grid Section
              Column(
                children: [
                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildGridItem(
                          color: AppColors.primary,
                          icon: Icons.local_taxi_rounded,
                          label: 'Transfer',
                          textColor: AppColors.textDark,
                          iconColor: AppColors.textDark,
                          onTap: () => widget.onServiceTap?.call('transfers'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildGridItem(
                          color: AppColors.whiteCard,
                          icon: Icons.bed_rounded,
                          iconColor: AppColors.textDark,
                          onTap: () => widget.onServiceTap?.call('hotels'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildGridItem(
                          color: AppColors.whiteCard,
                          icon: Icons.luggage_rounded,
                          iconColor: AppColors.textDark,
                          onTap: () => widget.onServiceTap?.call('baggage'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: _buildGridItem(
                          color: AppColors.accentTicket,
                          icon: Icons.airplane_ticket_rounded,
                          label: 'Tickets',
                          textColor: AppColors.textDark,
                          iconColor: AppColors.textDark,
                          onTap: widget.onTicketsTap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildGridItem(
                          color: AppColors.accentCar,
                          icon: Icons.directions_car_filled_rounded,
                          label: 'Car Rent',
                          textColor: AppColors.textDark,
                          iconColor: AppColors.textDark,
                          onTap: widget.onCarRentTap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildGridItem(
                          color: AppColors.whiteCard,
                          icon: Icons.forum_rounded,
                          iconColor: AppColors.textDark,
                          onTap: () => widget.onServiceTap?.call('forum'),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 36),

              // Upcoming departures header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming departures',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onFlightsTap?.call();
                    },
                    child: Row(
                      children: [
                        Text(
                          'View all',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_outward_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 20),

              // Flights List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _flightBoard.length,
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: AppColors.border, height: 1),
                        ),
                        itemBuilder: (context, index) {
                          final flight = _flightBoard[index];
                          return _buildFlightItem(flight);
                        },
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required Color color,
    required IconData icon,
    String? label,
    required Color iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 28),
              if (label != null) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightItem(Flight flight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Singapore - ${flight.destination}',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '27 Aug 2022 ${flight.departureTime}',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          'Gate ${flight.gate}',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

