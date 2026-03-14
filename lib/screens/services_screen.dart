import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class ServicesScreen extends StatefulWidget {
  final String? initialSection;
  const ServicesScreen({super.key, this.initialSection});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _transfersKey = GlobalKey();
  final GlobalKey _hotelsKey = GlobalKey();
  final GlobalKey _baggageKey = GlobalKey();
  final GlobalKey _forumKey = GlobalKey();

  late final Map<String, GlobalKey> _sectionKeys;

  static const _hotels = [
    _HotelData('Crowne Plaza Changi', '★ 4.8', 'S\$ 280/night', '5 min', '🏨'),
    _HotelData('Aerotel Singapore', '★ 4.5', 'S\$ 120/night', 'In-terminal', '🛏️'),
    _HotelData('Hilton Singapore', '★ 4.6', 'S\$ 240/night', '15 min', '🏩'),
  ];

  static const _services = [
    _ServiceTile('Baggage Storage', '📦', 'S\$ 12/day'),
    _ServiceTile('Luggage Wrap', '🎁', 'S\$ 18'),
    _ServiceTile('Sim Cards', '📱', 'From S\$ 8'),
    _ServiceTile('Money Exchange', '💱', 'Best rates'),
    _ServiceTile('Prayer Room', '🕌', 'Free'),
    _ServiceTile('Shower Facilities', '🚿', 'S\$ 18'),
  ];

  @override
  void initState() {
    super.initState();
    _sectionKeys = {
      'transfers': _transfersKey,
      'hotels': _hotelsKey,
      'baggage': _baggageKey,
      'forum': _forumKey,
    };
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(widget.initialSection!);
      });
    }
  }

  @override
  void didUpdateWidget(ServicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != null && widget.initialSection != oldWidget.initialSection) {
      _scrollToSection(widget.initialSection!);
    }
  }

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
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
                      'Everything you need at Singa Airport',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionWrapper(_transfersKey, _buildTransferSection(context)),
                    const SizedBox(height: 28),
                    _buildSectionWrapper(_hotelsKey, _buildHotelsSection()),
                    const SizedBox(height: 28),
                    _buildSectionWrapper(_baggageKey, _buildAirportServices()),
                    const SizedBox(height: 28),
                    _buildSectionWrapper(_forumKey, _buildForumSection()),
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

  Widget _buildSectionWrapper(Key key, Widget child) {
    return Container(
      key: key,
      child: child,
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
                          color: AppColors.accent.withValues(alpha: 0.15),
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
            itemCount: _hotels.length,
            itemBuilder: (context, index) {
              final h = _hotels[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _hotels.length - 1 ? 12 : 0),
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
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                                    color: AppColors.primary,
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
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final s = _services[index];
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
  Widget _buildForumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Airport Forum', actionLabel: 'Join Discussion'),
        const SizedBox(height: 14),
        DarkCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('✈️', style: TextStyle(fontSize: 14))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Thread',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '"Best lounge for a 4h layover?"',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '1,240 active travelers',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '24 new posts',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
