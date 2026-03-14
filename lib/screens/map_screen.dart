import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/isometric_map_painter.dart';

enum MapRoutingState { idle, viewing, buildingRoute, navigating }

class MapScreen extends StatefulWidget {
  final ValueChanged<bool>? onNavigatingChanged;
  const MapScreen({super.key, this.onNavigatingChanged});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapRoutingState _routeState = MapRoutingState.idle;
  bool _isSearchSheetOpen = false;
  Place? _selectedDestination;
  List<Place> _allPlaces = [];
  List<Place> _recentSearches = [];
  List<MapBlock> _allMapBlocks = [];
  List<MapBlock> _mapBlocks = [];
  List<Offset> _routePoints = [];
  bool _isLoading = true;
  final TransformationController _transformController = TransformationController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadMapData();
    // Start at a comfortable zoom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformController.value = Matrix4.diagonal3Values(0.9, 0.9, 1.0);
    });
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == null) {
        _mapBlocks = _allMapBlocks;
      } else {
        // Find place IDs that match this category
        final matchingPlaceIds = _allPlaces
            .where((p) => p.category == _selectedFilter)
            .map((p) => p.id)
            .toSet();


        _mapBlocks = _allMapBlocks.where((block) {
          // 1. Check category match if filter is active
          bool matchesCategory = matchingPlaceIds.contains(block.id) ||
              (_selectedFilter == 'Gates' && block.label.toLowerCase().contains('gate')) ||
              (_selectedFilter == 'Shopping' && (block.label.toLowerCase().contains('duty free') || block.label.toLowerCase().contains('dfs'))) ||
              (_selectedFilter == 'ATM' && block.label.toLowerCase().contains('atm'));

          // 2. Base structural blocks always visible
          if (block.id.startsWith('m') || block.id == 'bottom_bar') return true;

          // 3. If a category filter is active, only show matches
          if (_selectedFilter != null) {
            return matchesCategory;
          }

          // 4. Default: Show ALL items (no more level filtering by default)
          return true;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final Matrix4 current = _transformController.value.clone();
    
    current.translate(center.dx, center.dy);
    current.multiply(Matrix4.diagonal3Values(factor, factor, 1.0));
    current.translate(-center.dx, -center.dy);
    
    _transformController.value = current;
  }

  // ── Per-destination passage routes ───────────────────────────────────────
  // Passages:
  //   horiz top corridor: y = -85  (gap between c1-c5 bottom and m1/m2 top)
  //   vert center: x = 25         (gap between m1 right=0 and m2 left=50)
  //   horiz mid corridor: y = 75  (gap between m1/m2 bottom and b-row top)
  //   vert left of b3: x = -30    (gap between b rows and b3)
  //   vert right of b3: x = 185   (gap between b3 right and b4 row)
  static const Map<String, List<Offset>> _predefinedRoutes = {
    '1': [Offset(0, 0), Offset(25, 0), Offset(25, -85), Offset(-170, -85), Offset(-210, -120)],
    '2': [Offset(0, 0), Offset(25, 0), Offset(25, -85), Offset(-110, -85), Offset(-110, -120)],
    'c3': [Offset(0, 0), Offset(25, 0), Offset(25, -85), Offset(-10, -85), Offset(-10, -120)],
    '3': [Offset(0, 0), Offset(25, 0), Offset(25, -85), Offset(90, -85), Offset(90, -120)],
    '5': [Offset(0, 0), Offset(25, 0), Offset(25, -85), Offset(185, -85), Offset(185, -120)],
    '6': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(-300, 75), Offset(-300, 100)],
    '7': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(-220, 75), Offset(-220, 100)],
    '8': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(-60, 75), Offset(-60, 100)],
    '4': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(80, 75), Offset(80, 100)],
    '9': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(-20, 75), Offset(-20, 180), Offset(-60, 180)],
    '10': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(185, 75), Offset(185, 130), Offset(200, 130)],
    '11': [Offset(0, 0), Offset(25, 0), Offset(25, 75), Offset(185, 75), Offset(185, 210), Offset(210, 210)],
  };

  List<Offset> _generateRoute(Place place) {
    // All routes start at (0, 0) — the yellow circle.
    // Then travel the main vertical corridor x=25 to reach horizontal corridors.
    return _predefinedRoutes[place.id] ?? const [
      Offset(0, 0),
      Offset(25, 0),
      Offset(25, -85),
    ];
  }

  Future<void> _loadMapData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/map_blocks.json');
      final data = json.decode(response) as Map<String, dynamic>;

      _allMapBlocks = (data['blocks'] as List)
          .map((e) => MapBlock.fromJson(e as Map<String, dynamic>))
          .toList();
      _routePoints = (data['route'] as List)
          .map((e) => Offset((e['x'] as num).toDouble(), (e['y'] as num).toDouble()))
          .toList();

      final String placesResponse = await rootBundle.loadString('assets/data/places.json');
      final placesData = json.decode(placesResponse) as Map<String, dynamic>;
      final loadedPlaces = (placesData['places'] as List)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _allPlaces = loadedPlaces;
        _recentSearches = loadedPlaces;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12141C),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                // ── Isometric Map ──────────────────────────────────
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.3,
                    maxScale: 5.0,
                    child: CustomPaint(
                      painter: IsometricMapPainter(
                        isRouteActive: _routeState == MapRoutingState.buildingRoute ||
                             _routeState == MapRoutingState.navigating,
                         blockOpacity: (_routeState == MapRoutingState.buildingRoute ||
                             _routeState == MapRoutingState.navigating) ? 0.35 : 1.0,
                         blocks: _mapBlocks,
                         routePoints: _routePoints,
                         selectedBlockId: _selectedDestination?.id,
                       ),
                      size: Size.infinite,
                    ),
                  ),
                ),

                // ── Safe Area UI Layer ──────────────────────────────
                SafeArea(
                  child: Stack(
                    children: [
                      // Top Filter Bar
                      if (_routeState == MapRoutingState.idle || _routeState == MapRoutingState.viewing)
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: _buildTopBar(),
                        ),

                      // Direction pop up (when navigating)
                      if (_routeState == MapRoutingState.navigating)
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: _buildDirectionPopup(),
                        ),


                      // Zoom + Location Controls
                      Positioned(
                        right: 20,
                        top: 140,
                        child: _buildMapControls(),
                      ),

                      // Route top bar (when building route only)
                      if (_routeState == MapRoutingState.buildingRoute)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _buildTopLocationSelector(),
                        ),

                      // Bottom Panel
                      if (_routeState != MapRoutingState.idle)
                        Positioned(
                          bottom: 80,
                          left: 16,
                          right: 16,
                          child: _buildBottomPanel(),
                        ),

                      // Search overlay
                      if (_isSearchSheetOpen)
                        Positioned.fill(child: _buildSearchSheet()),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Top Bar
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      children: [
        // Search Button – plain white square, no glow ring
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedFilter = null;
              _applyFilter();
              _isSearchSheetOpen = true;
            });
          },
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.textDark, size: 26),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip(Icons.shopping_bag_outlined, 'Shopping'),
                const SizedBox(width: 8),
                _buildFilterChip(Icons.login_rounded, 'Gates'),
                const SizedBox(width: 8),
                _buildFilterChip(Icons.credit_card_rounded, 'ATM'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(IconData icon, String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFilter == label) {
            _selectedFilter = null;
          } else {
            _selectedFilter = label;
          }
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.black : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ────────────────────────────────────────────────────────────────────────────
  // Right – Zoom / Location Controls
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildMapControls() {
    return Column(
      children: [
        _buildControlPill(),
        const SizedBox(height: 8),
        _buildIconButton(Icons.my_location_rounded),
      ],
    );
  }

  Widget _buildControlPill() {
    return Container(
      width: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _zoom(1.3),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: const Icon(Icons.add_rounded, color: Colors.black87, size: 24),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          GestureDetector(
            onTap: () => _zoom(0.77),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: const Icon(Icons.remove_rounded, color: Colors.black87, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {bool white = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: white ? Colors.white : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: white ? Colors.black87 : Colors.white, size: 24),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Route Building – Top Selector
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildTopLocationSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: Text('A', style: GoogleFonts.inter(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Text('Your location', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 15)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11, top: 6, bottom: 6),
                  child: Container(width: 1, height: 14, color: Colors.black12),
                ),
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: Text('B', style: GoogleFonts.inter(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Text(_selectedDestination?.name ?? 'Target Location',
                        style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Bottom Panel
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildBottomPanel() {
    switch (_routeState) {
      case MapRoutingState.viewing:
        return _buildGateSheet(isBuildingPreview: false);
      case MapRoutingState.buildingRoute:
        return _buildGateSheet(isBuildingPreview: true);
      case MapRoutingState.navigating:
        return _buildActiveRouteSheet();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGateSheet({required bool isBuildingPreview}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDestination?.name ?? 'Gate 1C',
                      style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _selectedDestination?.category ?? 'Airport infrastructure',
                      style: GoogleFonts.inter(color: AppColors.textDark.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildCompactActionButton(Icons.share_outlined),
                  const SizedBox(width: 8),
                  _buildCompactActionButton(Icons.bookmark_outline_rounded),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() {
                      _routeState = MapRoutingState.idle;
                      _selectedDestination = null;
                    }),
                    child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 20),
                  ),
                ],
              ),
            ],
          ),
          if (isBuildingPreview) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_walk_rounded, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text('15 min • 1.1 km',
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              if (isBuildingPreview) {
                setState(() => _routeState = MapRoutingState.navigating);
                widget.onNavigatingChanged?.call(true);
              } else {
                setState(() => _routeState = MapRoutingState.buildingRoute);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isBuildingPreview ? "Let's go" : 'Build a route',
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_outward_rounded, color: Colors.black, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildCompactActionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.textDark.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.textDark, size: 18),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textDark.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textDark, size: 20),
          if (label.isNotEmpty) ...[const SizedBox(width: 6), Text(label)],
        ],
      ),
    );
  }

  Widget _buildActiveRouteSheet() {
    return Container(
      decoration: BoxDecoration(color: AppColors.whiteCard, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRouteStat('10:00', 'Arrival'),
              Container(width: 1, height: 32, color: AppColors.border),
              _buildRouteStat('1 km', 'Distance'),
              Container(width: 1, height: 32, color: AppColors.border),
              _buildRouteStat('5 min', 'Walking'),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _routeState = MapRoutingState.idle;
                _selectedDestination = null;
              });
              widget.onNavigatingChanged?.call(false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Cancel Navigation',
                      style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(Icons.close_rounded, color: AppColors.textDark, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildRouteStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.inter(color: AppColors.textDark.withValues(alpha: 0.6), fontSize: 11)),
      ],
    );
  }

  Widget _buildDirectionPopup() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4CE4F), // Yellow color from screenshot
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Dark color for icon bg
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.turn_left_rounded, 
              color: Colors.white, 
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '100 m turn left',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -1.0, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Search Sheet
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildSearchSheet() {
    final filtered = _searchQuery.isEmpty
        ? _allPlaces
        : _allPlaces
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Container(
      color: AppColors.background.withValues(alpha: 0.98),
      child: Column(
        children: [
          // Search input row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Where do you want to go?',
                      hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearchSheetOpen = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.whiteCard, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded, color: AppColors.textDark, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
              decoration: BoxDecoration(color: AppColors.whiteCard, borderRadius: BorderRadius.circular(24)),
              child: filtered.isEmpty
                  ? Center(
                      child: Text('No results found',
                          style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 15)),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          _searchQuery.isEmpty ? 'Recently viewed' : 'Results',
                          style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ...filtered.map((place) => _buildRecentItem(place)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildRecentItem(Place place) {
    final mockDistance = (place.name.length * 100) + 100;
    return InkWell(
      onTap: () {
        final route = _generateRoute(place);
        _searchController.clear();
        setState(() {
          _selectedDestination = place;
          _routePoints = route;
          _searchQuery = '';
          _isSearchSheetOpen = false;
          _routeState = MapRoutingState.viewing;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name,
                      style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('$mockDistance m away from you',
                      style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_outward_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// End of MapScreen
