class Flight {
  final String flightNumber;
  final String airline;
  final String airlineLogo;
  final String destination;
  final String origin;
  final String departureTime;
  final String arrivalTime;
  final String gate;
  final String terminal;
  final String status;
  final String statusLabel;
  final int boardingIn; // minutes
  final bool isBoarding;

  const Flight({
    required this.flightNumber,
    required this.airline,
    required this.airlineLogo,
    required this.destination,
    required this.origin,
    required this.departureTime,
    required this.arrivalTime,
    required this.gate,
    required this.terminal,
    required this.status,
    required this.statusLabel,
    required this.boardingIn,
    required this.isBoarding,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightNumber: json['flightNumber'] as String,
      airline: json['airline'] as String,
      airlineLogo: json['airlineLogo'] as String,
      destination: json['destination'] as String,
      origin: json['origin'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      gate: json['gate'] as String,
      terminal: json['terminal'] as String,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      boardingIn: json['boardingIn'] as int,
      isBoarding: json['isBoarding'] as bool,
    );
  }
}

class Place {
  final String id;
  final String name;
  final String category;
  final String terminal;
  final String level;
  final double rating;
  final int reviewCount;
  final String priceRange;
  final String walkTime;
  final String imageEmoji;
  final bool isOpen;
  final String description;
  final List<String> tags;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.terminal,
    required this.level,
    required this.rating,
    required this.reviewCount,
    required this.priceRange,
    required this.walkTime,
    required this.imageEmoji,
    required this.isOpen,
    required this.description,
    required this.tags,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      terminal: json['terminal'] as String,
      level: json['level'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      priceRange: json['priceRange'] as String,
      walkTime: json['walkTime'] as String,
      imageEmoji: json['imageEmoji'] as String,
      isOpen: json['isOpen'] as bool,
      description: json['description'] as String,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
    );
  }
}

class MapBlock {
  final String id;
  final double x;
  final double y;
  final double width;
  final double height;
  final String colorHex;
  final bool isElevated;
  final String label;

  const MapBlock({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.colorHex,
    required this.isElevated,
    required this.label,
  });

  factory MapBlock.fromJson(Map<String, dynamic> json) {
    return MapBlock(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      colorHex: json['colorHex'] as String,
      isElevated: json['isElevated'] ?? false,
      label: json['label'] as String? ?? '',
    );
  }
}

class ServiceItem {
  final String title;
  final String subtitle;
  final String icon;
  final List<int> gradientColors;
  final String route;

  const ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.route,
  });
}

class BookingOption {
  final String type;
  final String title;
  final String price;
  final String duration;
  final String icon;
  final double rating;
  final bool isPopular;

  const BookingOption({
    required this.type,
    required this.title,
    required this.price,
    required this.duration,
    required this.icon,
    required this.rating,
    required this.isPopular,
  });
}

// ─── Sample Data ────────────────────────────────────────────────────────────

class AppData {
  static const List<Flight> myFlights = [
    Flight(
      flightNumber: 'SQ 321',
      airline: 'Singapore Airlines',
      airlineLogo: '✈️',
      destination: 'London Heathrow',
      origin: 'Singapore Changi',
      departureTime: '22:45',
      arrivalTime: '05:30+1',
      gate: 'E21',
      terminal: 'Terminal 3',
      status: 'boarding',
      statusLabel: 'Boarding',
      boardingIn: 12,
      isBoarding: true,
    ),
    Flight(
      flightNumber: 'CX 715',
      airline: 'Cathay Pacific',
      airlineLogo: '✈️',
      destination: 'Hong Kong',
      origin: 'Singapore Changi',
      departureTime: '14:20',
      arrivalTime: '18:05',
      gate: 'B14',
      terminal: 'Terminal 1',
      status: 'ontime',
      statusLabel: 'On Time',
      boardingIn: 95,
      isBoarding: false,
    ),
  ];

  static const List<Flight> flightBoard = [
    Flight(
      flightNumber: 'SQ 322',
      airline: 'Singapore Airlines',
      airlineLogo: '✈️',
      destination: 'London',
      origin: 'SIN',
      departureTime: '22:45',
      arrivalTime: '05:30',
      gate: 'E21',
      terminal: 'T3',
      status: 'boarding',
      statusLabel: 'Boarding',
      boardingIn: 12,
      isBoarding: true,
    ),
    Flight(
      flightNumber: 'EK 431',
      airline: 'Emirates',
      airlineLogo: '✈️',
      destination: 'Dubai',
      origin: 'SIN',
      departureTime: '23:15',
      arrivalTime: '04:45',
      gate: 'F32',
      terminal: 'T2',
      status: 'ontime',
      statusLabel: 'On Time',
      boardingIn: 45,
      isBoarding: false,
    ),
    Flight(
      flightNumber: 'QF 80',
      airline: 'Qantas',
      airlineLogo: '✈️',
      destination: 'Sydney',
      origin: 'SIN',
      departureTime: '23:55',
      arrivalTime: '09:10',
      gate: 'C07',
      terminal: 'T1',
      status: 'delayed',
      statusLabel: 'Delayed',
      boardingIn: 120,
      isBoarding: false,
    ),
    Flight(
      flightNumber: 'BA 011',
      airline: 'British Airways',
      airlineLogo: '✈️',
      destination: 'London',
      origin: 'SIN',
      departureTime: '23:59',
      arrivalTime: '06:15',
      gate: 'E18',
      terminal: 'T3',
      status: 'ontime',
      statusLabel: 'On Time',
      boardingIn: 130,
      isBoarding: false,
    ),
    Flight(
      flightNumber: 'JL 038',
      airline: 'Japan Airlines',
      airlineLogo: '✈️',
      destination: 'Tokyo',
      origin: 'SIN',
      departureTime: '00:25',
      arrivalTime: '07:55',
      gate: 'D11',
      terminal: 'T2',
      status: 'ontime',
      statusLabel: 'On Time',
      boardingIn: 160,
      isBoarding: false,
    ),
  ];

  static const List<Place> places = [
    Place(
      id: '1',
      name: "Crystal Jade Kitchen",
      category: "Restaurant",
      terminal: "Terminal 3",
      level: "B2",
      rating: 4.7,
      reviewCount: 1243,
      priceRange: "\$\$",
      walkTime: "4 min",
      imageEmoji: "🍜",
      isOpen: true,
      description: "Authentic Chinese cuisine with dim sum and wok specialties",
      tags: ["Chinese", "Dim Sum", "Noodles"],
    ),
    Place(
      id: '2',
      name: "Starbucks Reserve",
      category: "Café",
      terminal: "Terminal 1",
      level: "L2",
      rating: 4.5,
      reviewCount: 876,
      priceRange: "\$\$",
      walkTime: "2 min",
      imageEmoji: "☕",
      isOpen: true,
      description: "Premium roastery experience with exclusive Reserve beverages",
      tags: ["Coffee", "Pastries", "Wifi"],
    ),
    Place(
      id: '3',
      name: "DFS Galleria",
      category: "Duty Free",
      terminal: "Terminal 2",
      level: "L3",
      rating: 4.6,
      reviewCount: 2105,
      priceRange: "\$\$\$",
      walkTime: "7 min",
      imageEmoji: "🛍️",
      isOpen: true,
      description: "World's largest duty-free collection of luxury brands",
      tags: ["Luxury", "Cosmetics", "Fashion"],
    ),
    Place(
      id: '4',
      name: "IMAX Cinema",
      category: "Entertainment",
      terminal: "Jewel",
      level: "L5",
      rating: 4.8,
      reviewCount: 543,
      priceRange: "\$\$",
      walkTime: "10 min",
      imageEmoji: "🎬",
      isOpen: true,
      description: "State-of-the-art IMAX theatre with the latest blockbusters",
      tags: ["Movies", "IMAX", "Entertainment"],
    ),
    Place(
      id: '5',
      name: "DNATA Lounge",
      category: "Lounge",
      terminal: "Terminal 1",
      level: "L3",
      rating: 4.4,
      reviewCount: 789,
      priceRange: "\$\$\$",
      walkTime: "5 min",
      imageEmoji: "🛋️",
      isOpen: true,
      description: "Premium lounge with shower facilities and gourmet buffet",
      tags: ["Lounge", "Shower", "Food"],
    ),
    Place(
      id: '6',
      name: "Guardian Pharmacy",
      category: "Health",
      terminal: "Terminal 3",
      level: "B1",
      rating: 4.3,
      reviewCount: 345,
      priceRange: "\$",
      walkTime: "3 min",
      imageEmoji: "💊",
      isOpen: true,
      description: "Full-service pharmacy with health and wellness products",
      tags: ["Pharmacy", "Health", "Wellness"],
    ),
  ];

  static const List<ServiceItem> quickServices = [
    ServiceItem(
      title: "Navigation",
      subtitle: "Find your gate",
      icon: "🗺️",
      gradientColors: [0xFF6C63FF, 0xFF9D4EDD],
      route: "/map",
    ),
    ServiceItem(
      title: "Flights",
      subtitle: "Live board",
      icon: "✈️",
      gradientColors: [0xFF00D9C0, 0xFF48CAE4],
      route: "/flights",
    ),
    ServiceItem(
      title: "Transfer",
      subtitle: "Book a ride",
      icon: "🚗",
      gradientColors: [0xFFFF7043, 0xFFFF9A76],
      route: "/transfer",
    ),
    ServiceItem(
      title: "Hotels",
      subtitle: "Stay nearby",
      icon: "🏨",
      gradientColors: [0xFFFFD166, 0xFFFF9A3C],
      route: "/hotels",
    ),
    ServiceItem(
      title: "Lounges",
      subtitle: "Relax & dine",
      icon: "🛋️",
      gradientColors: [0xFF3DDC84, 0xFF00B4D8],
      route: "/lounges",
    ),
    ServiceItem(
      title: "Parking",
      subtitle: "Find a spot",
      icon: "🅿️",
      gradientColors: [0xFF9D4EDD, 0xFFE040FB],
      route: "/parking",
    ),
  ];

  static const List<BookingOption> transfers = [
    BookingOption(
      type: "taxi",
      title: "Standard Taxi",
      price: "S\$ 28–35",
      duration: "35 min to city",
      icon: "🚕",
      rating: 4.2,
      isPopular: false,
    ),
    BookingOption(
      type: "grab",
      title: "Grab Premium",
      price: "S\$ 24–30",
      duration: "35 min to city",
      icon: "🚗",
      rating: 4.7,
      isPopular: true,
    ),
    BookingOption(
      type: "mrt",
      title: "MRT Express",
      price: "S\$ 1.80",
      duration: "30 min to city",
      icon: "🚇",
      rating: 4.9,
      isPopular: false,
    ),
    BookingOption(
      type: "shuttle",
      title: "Airport Shuttle",
      price: "S\$ 9.00",
      duration: "45 min to city",
      icon: "🚌",
      rating: 4.4,
      isPopular: false,
    ),
  ];
}
