// Helper functions to safely parse string numbers from API
double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class TourModel {
  final String id;
  final String slug; // URL-friendly identifier for API calls
  final String title;
  final String location;
  final String division;
  final String locationText; // Full location text from API (e.g., "Khulna, Khulna, Satkhira")
  final int durationDays;
  final int durationNights;
  final int price; // Upfront payment
  final int fullCost; // Total cost
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isVerifiedLead;
  final bool hasRefundGuarantee;
  final String transportType;
  final double transportRating;
  final String stayType;
  final double stayRating;
  final int totalSpots;
  final int spotsJoined;
  final String joinDeadline; // ISO 8601 format
  final TourLeadModel tourLead;
  final List<DayItinerary> itinerary;
  final List<String> included;
  final List<String> notIncluded;
  final MeetingPointModel meetingPoint;
  final RefundPolicyModel refundPolicy;

  TourModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.location,
    required this.division,
    required this.locationText,
    required this.durationDays,
    required this.durationNights,
    required this.price,
    required this.fullCost,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.isVerifiedLead,
    required this.hasRefundGuarantee,
    required this.transportType,
    required this.transportRating,
    required this.stayType,
    required this.stayRating,
    required this.totalSpots,
    required this.spotsJoined,
    required this.joinDeadline,
    required this.tourLead,
    required this.itinerary,
    required this.included,
    required this.notIncluded,
    required this.meetingPoint,
    required this.refundPolicy,
  });

  int get spotsRemaining => totalSpots - spotsJoined;
  
  double get joinedPercentage => (spotsJoined / totalSpots) * 100;

  String get durationText => '$durationDays Days, $durationNights Nights';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'location': location,
      'division': division,
      'locationText': locationText,
      'durationDays': durationDays,
      'durationNights': durationNights,
      'price': price,
      'fullCost': fullCost,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'isVerifiedLead': isVerifiedLead,
      'hasRefundGuarantee': hasRefundGuarantee,
      'transportType': transportType,
      'transportRating': transportRating,
      'stayType': stayType,
      'stayRating': stayRating,
      'totalSpots': totalSpots,
      'spotsJoined': spotsJoined,
      'joinDeadline': joinDeadline,
      'tourLead': tourLead.toJson(),
      'itinerary': itinerary.map((e) => e.toJson()).toList(),
      'included': included,
      'notIncluded': notIncluded,
      'meetingPoint': meetingPoint.toJson(),
      'refundPolicy': refundPolicy.toJson(),
    };
  }

  factory TourModel.fromJson(Map<String, dynamic> json) {
    // Extract transport and stay info
    final transport = json['transport'] as Map<String, dynamic>?;
    final stay = json['stay'] as Map<String, dynamic>?;
    final tourLead = json['tour_lead']; // Can be Map or String based on API
    
    // Parse location text to derive location and division
    final locationVal = json['location_text'] ?? json['location'] ?? '';
    String locationStr = '';
    String divisionStr = '';
    
    if (locationVal.isNotEmpty) {
      final parts = locationVal.toString().split(',').map((e) => e.trim()).toList();
      locationStr = parts.isNotEmpty ? parts[0] : '';
      divisionStr = parts.length > 1 ? parts[1] : locationStr;
    }

    // Parse numeric fields safely
    final upcomingPayment = _parseInt(json['upfront_payment'] ?? json['price']);
    final totalCost = _parseInt(json['total_cost'] ?? json['fullCost']);
    
    return TourModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      location: locationStr,
      division: divisionStr,
      locationText: locationVal.toString(),
      durationDays: _parseInt(json['duration_days']),
      durationNights: _parseInt(json['duration_nights']),
      price: upcomingPayment,
      fullCost: totalCost > 0 ? totalCost : (upcomingPayment * 2),
      rating: _parseDouble(json['rating']),
      reviewCount: _parseInt(json['rating_count']),
      imageUrl: json['featured_image'] ?? json['imageUrl'] ?? '',
      isVerifiedLead: json['is_verified_lead'] ?? false,
      hasRefundGuarantee: json['has_refund_guarantee'] ?? (json['min_group_size'] != null),
      transportType: transport?['name'] ?? json['transportType'] ?? 'Bus',
      transportRating: _parseDouble(transport?['rating'] ?? json['transportRating']),
      stayType: stay?['name'] ?? json['stayType'] ?? 'Hotel',
      stayRating: _parseDouble(stay?['rating'] ?? json['stayRating']),
      totalSpots: _parseInt(json['max_capacity']),
      spotsJoined: _parseInt(json['joined_count'] ?? json['spotsJoined']),
      joinDeadline: json['booking_deadline'] ?? json['start_datetime'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      tourLead: tourLead != null 
          ? (tourLead is Map<String, dynamic> ? TourLeadModel.fromJson(tourLead) : TourLeadModel.empty())
          : TourLeadModel.empty(),
      itinerary: (json['tour_plan'] as List?)?.map((e) => DayItinerary.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      included: (json['included'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map) return e['title']?.toString() ?? '';
        return e.toString();
      }).toList() ?? [],
      notIncluded: (json['not_included'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map) return e['title']?.toString() ?? '';
        return e.toString();
      }).toList() ?? [],
      meetingPoint: MeetingPointModel(
        location: json['meeting_point'] ?? '',
        time: json['meeting_time'] ?? '',
      ),
      refundPolicy: RefundPolicyModel(
        description: json['refund_policy_description'] ?? 'Full refund if minimum group size not met',
        minimumGroupSize: _parseInt(json['min_group_size'] ?? 10),
      ),
    );
  }
}

class TourLeadModel {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int toursLed;

  TourLeadModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.toursLed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'toursLed': toursLed,
    };
  }

  factory TourLeadModel.empty() {
    return TourLeadModel(
      id: '',
      name: 'Unknown',
      avatarUrl: '',
      rating: 0.0,
      toursLed: 0,
    );
  }

  factory TourLeadModel.fromJson(Map<String, dynamic> json) {
    return TourLeadModel(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? 'Unknown',
      avatarUrl: json['profile_pic'] ?? json['avatarUrl'] ?? '',
      rating: _parseDouble(json['rating']),
      toursLed: _parseInt(json['tours_completed'] ?? json['toursLed']),
    );
  }
}

class DayItinerary {
  final int day;
  final String title;
  final String description;
  final List<String> activities;

  DayItinerary({
    required this.day,
    required this.title,
    required this.description,
    required this.activities,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'description': description,
      'activities': activities,
    };
  }

  factory DayItinerary.fromJson(Map<String, dynamic> json) {
    final activities = json['activities'] as List?;
    return DayItinerary(
      day: _parseInt(json['day_number'] ?? json['day']),
      title: json['title'] ?? '',
      description: json['subtitle'] ?? json['description'] ?? '',
      activities: activities?.map((e) {
        if (e is String) return e;
        if (e is Map) return e['title']?.toString() ?? e.toString();
        return e.toString();
      }).toList() ?? [],
    );
  }
}

class MeetingPointModel {
  final String location;
  final String time;

  MeetingPointModel({
    required this.location,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'time': time,
    };
  }

  factory MeetingPointModel.fromJson(Map<String, dynamic> json) {
    return MeetingPointModel(
      location: json['location'],
      time: json['time'],
    );
  }
}

class RefundPolicyModel {
  final String description;
  final int minimumGroupSize;

  RefundPolicyModel({
    required this.description,
    required this.minimumGroupSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'minimumGroupSize': minimumGroupSize,
    };
  }

  factory RefundPolicyModel.empty() {
    return RefundPolicyModel(
      description: 'Standard refund policy applies',
      minimumGroupSize: 10,
    );
  }

  factory RefundPolicyModel.fromJson(Map<String, dynamic> json) {
    return RefundPolicyModel(
      description: json['description'] ?? '',
      minimumGroupSize: _parseInt(json['minimumGroupSize'] ?? json['minimum_group_size']),
    );
  }
}

class BookingModel {
  final String id;
  final TourModel tour;
  final String bookingDate; // ISO 8601 format
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final int pricePaid;
  final String? specialNote;

  BookingModel({
    required this.id,
    required this.tour,
    required this.bookingDate,
    required this.status,
    required this.pricePaid,
    this.specialNote,
  });

  bool get isPast {
    final tourDate = DateTime.parse(tour.joinDeadline);
    return tourDate.isBefore(DateTime.now());
  }

  bool get isUpcoming => !isPast;
}
