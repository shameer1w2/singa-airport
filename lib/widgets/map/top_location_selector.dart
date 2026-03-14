import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TopLocationSelector extends StatelessWidget {
  final String destinationName;

  const TopLocationSelector({
    super.key,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationRow('A', 'Your location'),
                Padding(
                  padding: const EdgeInsets.only(left: 11, top: 6, bottom: 6),
                  child: Container(width: 1, height: 14, color: Colors.black12),
                ),
                _buildLocationRow('B', destinationName),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.mediumImpact(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String letter, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ],
    );
  }
}
