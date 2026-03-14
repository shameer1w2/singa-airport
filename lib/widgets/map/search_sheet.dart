import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class SearchSheet extends StatefulWidget {
  final List<Place> places;
  final ValueChanged<Place> onPlaceSelected;
  final VoidCallback onClose;

  const SearchSheet({
    super.key,
    required this.places,
    required this.onPlaceSelected,
    required this.onClose,
  });

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? widget.places
        : widget.places
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
                    widget.onClose();
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
      onTap: () => widget.onPlaceSelected(place),
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
