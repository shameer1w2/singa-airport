import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Everything you need at Changi',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTransferSection(context),
                    const SizedBox(height: 28),
                    _buildHotelsSection(),
                    const SizedBox(height: 28),
                    _buildAirportServices(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Airport Transfers', actionLabel: 'See all'),
        const SizedBox(height: 14),
        ...AppData.transfers.asMap().entries.map((e) {
          final option = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildTransferCard(option, e.key).animate(delay: (e.key * 80).ms)
              .fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildTransferCard(BookingOption option, int index) {
    return DarkCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(option.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      option.title,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (option.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.textTertiary, size: 11),
                    const SizedBox(width: 3),
                    Text(
                      option.duration,
                      style: GoogleFonts.inter(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StarRating(rating: option.rating, reviewCount: 0),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                option.price,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Book',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsSection() {
    final hotels = [
      _HotelData('Crowne Plaza Changi', '★ 4.8', 'S\$ 280/night', '5 min', '🏨'),
      _HotelData('Aerotel Singapore', '★ 4.5', 'S\$ 120/night', 'In-terminal', '🛏️'),
      _HotelData('Hilton Singapore', '★ 4.6', 'S\$ 240/night', '15 min', '🏩'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Hotels Nearby', actionLabel: 'See all'),
        const SizedBox(height: 14),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final h = hotels[index];
              return Padding(
                padding: EdgeInsets.only(right: index < hotels.length - 1 ? 12 : 0),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(h.emoji, style: const TextStyle(fontSize: 36)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.name,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  h.rating,
                                  style: GoogleFonts.inter(
                                    color: AppColors.accentYellow,
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  h.distance,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              h.price,
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAirportServices() {
    final services = [
      _ServiceTile('Baggage Storage', '📦', 'S\$ 12/day'),
      _ServiceTile('Luggage Wrap', '🎁', 'S\$ 18'),
      _ServiceTile('Sim Cards', '📱', 'From S\$ 8'),
      _ServiceTile('Money Exchange', '💱', 'Best rates'),
      _ServiceTile('Prayer Room', '🕌', 'Free'),
      _ServiceTile('Shower Facilities', '🚿', 'S\$ 18'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Airport Services'),
        const SizedBox(height: 14),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final s = services[index];
            return GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: DarkCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(
                      s.name,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.price,
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
            );
          },
        ),
      ],
    );
  }
}

class _HotelData {
  final String name;
  final String rating;
  final String price;
  final String distance;
  final String emoji;
  const _HotelData(this.name, this.rating, this.price, this.distance, this.emoji);
}

class _ServiceTile {
  final String name;
  final String emoji;
  final String price;
  const _ServiceTile(this.name, this.emoji, this.price);
}
