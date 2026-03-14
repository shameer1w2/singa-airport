import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControlPill(),
        const SizedBox(height: 8),
        _buildIconButton(Icons.my_location_rounded, onMyLocation),
      ],
    );
  }

  Widget _buildControlPill() {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildPillButton(Icons.add_rounded, onZoomIn),
          const Divider(height: 1, color: Colors.black12),
          _buildPillButton(Icons.remove_rounded, onZoomOut),
        ],
      ),
    );
  }

  Widget _buildPillButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {bool white = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: white ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, color: white ? Colors.black87 : Colors.white, size: 24),
      ),
    );
  }
}
