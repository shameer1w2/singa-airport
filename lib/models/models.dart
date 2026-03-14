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
  final String destinationCode;
  final String originCity;

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
    this.destinationCode = '',
    this.originCity = 'Singapore',
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
      destinationCode: json['destinationCode'] as String? ?? '',
      originCity: json['originCity'] as String? ?? 'Singapore',
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
  final double elevation;
  final String label;

  const MapBlock({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.colorHex,
    required this.elevation,
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
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
      label: json['label'] as String? ?? '',
    );
  }
}


class Car {
  final String name;
  final String category;
  final String price;
  final double rating;
  final String emoji;
  final String colorHex;
  final List<String> features;

  const Car({
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.emoji,
    required this.colorHex,
    required this.features,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as String,
      rating: (json['rating'] as num).toDouble(),
      emoji: json['emoji'] as String,
      colorHex: json['colorHex'] as String,
      features: (json['features'] as List).map((e) => e as String).toList(),
    );
  }
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


class AppData {
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
