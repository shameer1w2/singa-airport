import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/map_screen.dart';
import 'compact_action_button.dart';

class MapBottomSheet extends StatelessWidget {
  final MapRoutingState routeState;
  final Place? destination;
  final VoidCallback onStartNavigation;
  final VoidCallback onCancel;
  final VoidCallback onBuildRoute;
  final VoidCallback onCloseView;

  const MapBottomSheet({
    super.key,
    required this.routeState,
    required this.destination,
    required this.onStartNavigation,
    required this.onCancel,
    required this.onBuildRoute,
    required this.onCloseView,
  });

  @override
  Widget build(BuildContext context) {
    switch (routeState) {
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
                      destination?.name ?? 'Gate 1C',
                      style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      destination?.category ?? 'Airport infrastructure',
                      style: GoogleFonts.inter(color: AppColors.textDark.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  CompactActionButton(icon: Icons.share_outlined, onTap: () {}),
                  const SizedBox(width: 8),
                  CompactActionButton(icon: Icons.bookmark_outline_rounded, onTap: () {}),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onCloseView();
                    },
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
              HapticFeedback.heavyImpact();
              isBuildingPreview ? onStartNavigation() : onBuildRoute();
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
              HapticFeedback.mediumImpact();
              onCancel();
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
}
