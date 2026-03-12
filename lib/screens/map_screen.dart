import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

enum MapRoutingState { viewing, buildingRoute, navigating }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedLevel = 1;
  MapRoutingState _routeState = MapRoutingState.viewing;
  List<MapBlock> _mapBlocks = [];
  List<Offset> _routePoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/map_blocks.json');
      final data = json.decode(response) as Map<String, dynamic>;
      
      setState(() {
        _mapBlocks = (data['blocks'] as List)
            .map((e) => MapBlock.fromJson(e as Map<String, dynamic>))
            .toList();
        _routePoints = (data['route'] as List)
            .map((e) => Offset((e['x'] as num).toDouble(), (e['y'] as num).toDouble()))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading map data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Isometric Map Layer
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(math.pi / 3)
                  ..rotateZ(-math.pi / 4),
                child: CustomPaint(
                  painter: _IsometricMapPainter(
                    isRouteActive: _routeState != MapRoutingState.viewing,
                    blocks: _mapBlocks,
                    routePoints: _routePoints,
                  ),
                  size: const Size(800, 800),
                ),
              ),
            ),
          ),

          // SafeArea overlay for UI controls
          SafeArea(
            child: Stack(
              children: [
                // Top filters
                if (_routeState == MapRoutingState.viewing)
                  Positioned(
                    top: 16,
                    left: 20,
                    right: 20,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Search Button
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.search_rounded, color: AppColors.textDark, size: 24),
                          ),
                          const SizedBox(width: 12),
                          _buildFilterChip(Icons.shopping_bag_outlined, 'Shopping', true),
                          const SizedBox(width: 8),
                          _buildFilterChip(Icons.login_rounded, 'Gates', true),
                          const SizedBox(width: 8),
                          _buildFilterChip(Icons.atm_rounded, 'ATM', true),
                        ],
                      ),
                    ),
                  ),

                // Top Location Selector for building route
                if (_routeState == MapRoutingState.buildingRoute)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildTopLocationSelector(),
                  ),

                // Left Level Selector
                Positioned(
                  left: 20,
                  top: 180,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      children: [
                        _buildLevelBtn(2),
                        const SizedBox(height: 12),
                        _buildLevelBtn(1),
                        const SizedBox(height: 12),
                        _buildLevelBtn(-1),
                      ],
                    ),
                  ),
                ),

                // Right Controls (+ / - / Location)
                Positioned(
                  right: 20,
                  top: 180,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteCard,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Column(
                          children: [
                            GestureDetector(
                              child: const Icon(Icons.add_rounded, color: AppColors.textDark, size: 28),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              height: 1,
                              width: 20,
                              color: AppColors.border,
                            ),
                            GestureDetector(
                              child: const Icon(Icons.remove_rounded, color: AppColors.textDark, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.whiteCard,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.my_location_rounded, color: AppColors.textDark, size: 24),
                      ),
                    ],
                  ),
                ),

                // Bottom Panel
                Positioned(
                  bottom: 110, // above the floating nav bar
                  left: 20,
                  right: 20,
                  child: _buildBottomPanel(),
                ),
                
                // Route navigation top instruction (only if navigating)
                if (_routeState == MapRoutingState.navigating)
                  Positioned(
                    top: 16,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.textDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.turn_left_rounded, color: AppColors.textDark),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '100 m turn left',
                            style: GoogleFonts.inter(
                              color: AppColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, bool isWhite) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWhite ? AppColors.whiteCard : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isWhite ? AppColors.textDark : AppColors.textPrimary, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isWhite ? AppColors.textDark : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBtn(int level) {
    final isSel = _selectedLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = level),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSel ? AppColors.whiteCard : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$level',
            style: GoogleFonts.inter(
              color: isSel ? AppColors.textDark : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopLocationSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('A', style: GoogleFonts.inter(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text('Your location', style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w500)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                  child: Container(width: 1, height: 16, color: AppColors.border),
                ),
                Row(
                  children: [
                    Text('B', style: GoogleFonts.inter(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text('Gate 1C', style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textDark.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_vert_rounded, color: AppColors.textDark, size: 20),
          )
        ],
      ),
    ).animate().slideY(begin: -1.0, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildBottomPanel() {
    switch (_routeState) {
      case MapRoutingState.viewing:
        return _buildGateSheet(isBuildingPreview: false);
      case MapRoutingState.buildingRoute:
        return _buildGateSheet(isBuildingPreview: true);
      case MapRoutingState.navigating:
        return _buildActiveRouteSheet();
    }
  }

  Widget _buildGateSheet({required bool isBuildingPreview}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gate 1C',
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Airport infrastructure',
                    style: GoogleFonts.inter(
                      color: AppColors.textDark.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _routeState = MapRoutingState.viewing),
                child: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isBuildingPreview)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textDark.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.share_outlined, color: AppColors.textDark, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textDark.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bookmark_outline_rounded, color: AppColors.textDark, size: 20),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_walk_rounded, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '15 min on foot - 1.1 km',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (isBuildingPreview) {
                setState(() => _routeState = MapRoutingState.navigating);
              } else {
                setState(() => _routeState = MapRoutingState.buildingRoute);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isBuildingPreview ? 'Let\'s go' : 'Build a route',
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_outward_rounded, color: AppColors.textDark, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildActiveRouteSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRouteStat('10:00', 'Arrival'),
              Container(width: 1, height: 40, color: AppColors.border),
              _buildRouteStat('1 km', 'Distance'),
              Container(width: 1, height: 40, color: AppColors.border),
              _buildRouteStat('5 min', 'On the way'),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _routeState = MapRoutingState.viewing),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.textDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textDark.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _IsometricMapPainter extends CustomPainter {
  final bool isRouteActive;
  final List<MapBlock> blocks;
  final List<Offset> routePoints;

  _IsometricMapPainter({
    required this.isRouteActive,
    required this.blocks,
    required this.routePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.isEmpty) return;

    final bgPaint = Paint()..color = const Color(0xFF141519);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF22232A)
      ..strokeWidth = 2.0;

    // Draw some grid base lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Draw blocks from JSON data
    for (final block in blocks) {
      if (block.id == 'target' && isRouteActive) continue; // Skip target if route is active
      
      final color = Color(int.parse(block.colorHex, radix: 16));
      _drawBlock(
        canvas,
        Rect.fromLTWH(block.x, block.y, block.width, block.height),
        color,
        isElevated: block.isElevated,
        label: block.label,
      );
    }

    if (isRouteActive && routePoints.isNotEmpty) {
      // Draw route line
      final routePaint = Paint()
        ..color = const Color(0xFFF4CE4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(routePoints.first.dx, routePoints.first.dy);
      for (int i = 1; i < routePoints.length; i++) {
        path.lineTo(routePoints[i].dx, routePoints[i].dy);
      }

      canvas.drawPath(path, routePaint);

      // Route end markers
      canvas.drawCircle(routePoints.first, 10, Paint()..color = const Color(0xFFF4CE4F));
      canvas.drawCircle(routePoints.first, 6, Paint()..color = const Color(0xFF141519));

      canvas.drawCircle(routePoints.last, 10, Paint()..color = const Color(0xFFF4CE4F));
    }
  }

  void _drawBlock(Canvas canvas, Rect rect, Color color, {bool isElevated = false, String label = ''}) {
    // Top face
    final fillPaint = Paint()..color = color;
    canvas.drawRect(rect, fillPaint);
    
    // Draw some text/icon to look like shop
    if (!isElevated && label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left + 10, rect.top + 10));
    }

    if (isElevated) {
      // Draw faces manually for a 3D elevated look since coordinate transform handles main tilt
      // But actually the transform handles isometric view, so 3D depth means we just draw an offset rectangle and connect corners
      
      final offset = const Offset(0, -60);
      final topRect = rect.shift(offset);
      
      // Top face
      canvas.drawRect(topRect, Paint()..color = color);
      
      // Side faces (simplified for vertical extrude on transformed plane)
      final pathSide1 = Path()
        ..moveTo(rect.bottomLeft.dx, rect.bottomLeft.dy)
        ..lineTo(topRect.bottomLeft.dx, topRect.bottomLeft.dy)
        ..lineTo(topRect.bottomRight.dx, topRect.bottomRight.dy)
        ..lineTo(rect.bottomRight.dx, rect.bottomRight.dy)
        ..close();
      canvas.drawPath(pathSide1, Paint()..color = color.withOpacity(0.8));

      final pathSide2 = Path()
        ..moveTo(rect.bottomRight.dx, rect.bottomRight.dy)
        ..lineTo(topRect.bottomRight.dx, topRect.bottomRight.dy)
        ..lineTo(topRect.topRight.dx, topRect.topRight.dy)
        ..lineTo(rect.topRight.dx, rect.topRight.dy)
        ..close();
      canvas.drawPath(pathSide2, Paint()..color = color.withOpacity(0.6));
    }
  }

  @override
  bool shouldRepaint(covariant _IsometricMapPainter oldDelegate) =>
      oldDelegate.isRouteActive != isRouteActive;
}
