import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<Flight> _myFlights = [];
  bool _isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  static const _passengerName = 'JAMIE DAVIES';

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/flights.json');
      final data = json.decode(response) as Map<String, dynamic>;
      
      if (mounted) {
        setState(() {
          _myFlights = (data['myFlights'] as List)
              .map((e) => Flight.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tickets',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'You have ${_myFlights.length} upcoming trips',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _myFlights.isEmpty
                      ? _buildEmptyState()
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _myFlights.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: _buildBoardingPass(_myFlights[index]),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎫', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No active tickets found',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardingPass(Flight flight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                // Top Airline Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(flight.airlineLogo, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            flight.airline,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        flight.flightNumber,
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Route SIN -> DEST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: [
                      _buildRouteInfo('SIN', 'Singapore', flight.departureTime),
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.flight_takeoff_rounded, color: AppColors.textTertiary, size: 20),
                            const SizedBox(height: 4),
                            Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ],
                        ),
                      ),
                      _buildRouteInfo(
                        flight.destinationCode.isNotEmpty ? flight.destinationCode : 'LHR',
                        flight.destination.split(' ').last,
                        flight.arrivalTime,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Details Grid
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem('GATE', flight.gate),
                            _buildInfoItem('SEAT', '12A'),
                            _buildInfoItem('CLASS', 'Economy'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem('TERMINAL', flight.terminal),
                            _buildInfoItem('BOARDING', flight.boardingIn > 0 ? '${flight.boardingIn}m' : 'NOW'),
                            _buildInfoItem('ZONE', 'Zone 2'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // The "Tear" part
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.symmetric(
                    vertical: BorderSide(color: AppColors.border, width: 0.5),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: List.generate(
                          15,
                          (index) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Container(height: 1, color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Bottom Part (Barcode/QR)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: flight.flightNumber,
                    version: QrVersions.auto,
                    size: 120,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                    errorStateBuilder: (context, error) =>
                        const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'NAME: $_passengerName',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildRouteInfo(String code, String city, String time, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          code,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          city,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.inter(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
