import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  List<Flight> _departures = [];
  List<Flight> _arrivals = [];
  List<Flight> _myFlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFlightsData();
  }

  Future<void> _loadFlightsData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/flights.json');
      final data = json.decode(response) as Map<String, dynamic>;
      
      setState(() {
        _departures = (data['departures'] as List)
            .map((e) => Flight.fromJson(e as Map<String, dynamic>))
            .toList();
        _arrivals = (data['arrivals'] as List)
            .map((e) => Flight.fromJson(e as Map<String, dynamic>))
            .toList();
        _myFlights = (data['myFlights'] as List)
            .map((e) => Flight.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading flights data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildMyFlightsBanner(),
            _buildTabBar(),
            _buildFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _buildFlightList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flight Board',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live · Updated just now',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Search',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyFlightsBanner() {
    if (_myFlights.isEmpty) return const SizedBox.shrink();
    final flight = _myFlights.first;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1845), Color(0xFF141230)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.confirmation_number_outlined,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    '${flight.flightNumber} · ${flight.destination.contains("London") ? "LHR" : "HKG"}',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Gate ${flight.gate} · ${flight.isBoarding ? 'Boards in ${flight.boardingIn} min' : 'On Time'}',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(status: flight.status, label: flight.statusLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
          tabs: const [
            Tab(text: 'Departures'),
            Tab(text: 'Arrivals'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'On Time', 'Boarding', 'Delayed'];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters
              .map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AirportChip(
                      label: f,
                      isSelected: _selectedFilter == f,
                      onTap: () => setState(() => _selectedFilter = f),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFlightList() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFlightListView(_departures),
        _buildFlightListView(_arrivals),
      ],
    );
  }

  Widget _buildFlightListView(List<Flight> flights) {
    final filtered = _selectedFilter == 'All'
        ? flights
        : flights.where((f) {
            switch (_selectedFilter) {
              case 'On Time': return f.status == 'ontime';
              case 'Boarding': return f.status == 'boarding';
              case 'Delayed': return f.status == 'delayed';
              default: return true;
            }
          }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildFlightCard(filtered[index], index),
        );
      },
    );
  }

  Widget _buildFlightCard(Flight flight, int index) {
    return GestureDetector(
      onTap: () => _showFlightDetail(flight),
      child: DarkCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Airline icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(flight.airlineLogo,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                // Flight info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            flight.flightNumber,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            flight.airline,
                            style: GoogleFonts.inter(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flight.destination,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: flight.status, label: flight.statusLabel),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 0.5,
              color: AppColors.divider,
            ),
            const SizedBox(height: 12),
            // Details row
            Row(
              children: [
                _buildFlightDetail(
                    Icons.access_time_rounded, 'Departure', flight.departureTime),
                _buildFlightDetail(
                    Icons.door_front_door_outlined, 'Gate', flight.gate),
                _buildFlightDetail(
                    Icons.business_outlined, 'Terminal', flight.terminal),
                _buildFlightDetail(
                    Icons.timer_outlined, 'Boards in',
                    flight.boardingIn > 0 ? '${flight.boardingIn}m' : '—'),
              ],
            ),
          ],
        ),
      ).animate(delay: (index * 60).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildFlightDetail(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 13),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFlightDetail(Flight flight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FlightDetailSheet(flight: flight),
    );
  }
}

class _FlightDetailSheet extends StatelessWidget {
  final Flight flight;
  const _FlightDetailSheet({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Status badge
          StatusBadge(status: flight.status, label: flight.statusLabel),
          const SizedBox(height: 12),
          Text(
            flight.flightNumber,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            flight.airline,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          // Route
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SIN', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13)),
                      Text(flight.departureTime,
                          style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                      Text('Singapore', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.flight, color: AppColors.primary, size: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('LHR', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13)),
                      Text(flight.arrivalTime,
                          style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                      Text('London', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoTile('Gate', flight.gate),
                  _InfoTile('Terminal', flight.terminal),
                  _InfoTile('Boarding', flight.boardingIn > 0 ? '${flight.boardingIn}m' : 'Now'),
                  _InfoTile('Class', 'Economy'),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Track button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Track Flight',
                          style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.bookmark_border_rounded,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
