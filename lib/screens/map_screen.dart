import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/isometric_map_painter.dart';
import '../widgets/map/direction_popup.dart';
import '../widgets/map/map_bottom_sheet.dart';
import '../widgets/map/map_controls.dart';
import '../widgets/map/search_sheet.dart';
import '../widgets/map/top_bar.dart';
import '../widgets/map/top_location_selector.dart';

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
  List<MapBlock> _allMapBlocks = [];
  List<MapBlock> _mapBlocks = [];
  List<Offset> _routePoints = [];
  bool _isLoading = true;
  final TransformationController _transformController = TransformationController();
  final TextEditingController _searchController = TextEditingController();
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
    current.multiply(Matrix4.translationValues(center.dx, center.dy, 0.0));
    current.multiply(Matrix4.diagonal3Values(factor, factor, 1.0));
    current.multiply(Matrix4.translationValues(-center.dx, -center.dy, 0.0));
    
    _transformController.value = current;
  }

  // ── Per-destination passage routes ───────────────────────────────────────
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

                SafeArea(
                  child: Stack(
                    children: [
                      if (_routeState == MapRoutingState.idle || _routeState == MapRoutingState.viewing)
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: MapTopBar(
                            onSearchPressed: () {
                              setState(() {
                                _selectedFilter = null;
                                _applyFilter();
                                _isSearchSheetOpen = true;
                              });
                            },
                            selectedFilter: _selectedFilter,
                            onFilterChanged: (filter) {
                              setState(() {
                                if (_selectedFilter == filter) {
                                  _selectedFilter = null;
                                } else {
                                  _selectedFilter = filter;
                                }
                                _applyFilter();
                              });
                            },
                          ),
                        ),

                      if (_routeState == MapRoutingState.navigating)
                        const Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: DirectionPopup(),
                        ),

                      Positioned(
                        right: 20,
                        top: 140,
                        child: MapControls(
                          onZoomIn: () => _zoom(1.3),
                          onZoomOut: () => _zoom(0.77),
                          onMyLocation: () {},
                        ),
                      ),

                      if (_routeState == MapRoutingState.buildingRoute)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: TopLocationSelector(
                            destinationName: _selectedDestination?.name ?? 'Target Location',
                          ),
                        ),

                      if (_routeState != MapRoutingState.idle)
                        Positioned(
                          bottom: 80,
                          left: 16,
                          right: 16,
                          child: MapBottomSheet(
                            routeState: _routeState,
                            destination: _selectedDestination,
                            onStartNavigation: () {
                              setState(() => _routeState = MapRoutingState.navigating);
                              widget.onNavigatingChanged?.call(true);
                            },
                            onCancel: () {
                              setState(() {
                                _routeState = MapRoutingState.idle;
                                _selectedDestination = null;
                              });
                              widget.onNavigatingChanged?.call(false);
                            },
                            onBuildRoute: () {
                              setState(() => _routeState = MapRoutingState.buildingRoute);
                            },
                            onCloseView: () {
                              setState(() {
                                _routeState = MapRoutingState.idle;
                                _selectedDestination = null;
                              });
                            },
                          ),
                        ),

                      if (_isSearchSheetOpen)
                        Positioned.fill(
                          child: SearchSheet(
                            places: _allPlaces,
                            onPlaceSelected: (place) {
                              final route = _generateRoute(place);
                              setState(() {
                                _selectedDestination = place;
                                _routePoints = route;
                                _isSearchSheetOpen = false;
                                _routeState = MapRoutingState.viewing;
                              });
                            },
                            onClose: () {
                              setState(() {
                                _isSearchSheetOpen = false;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
