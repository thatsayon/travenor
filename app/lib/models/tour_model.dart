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
  if (value is String) {
    // Try parsing as int first
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;
    
    // If that fails, try parsing as double then convert to int (handles "5000.00")
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) return doubleValue.toInt();
    
    return defaultValue;
  }
  return defaultValue;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }
  return defaultValue;
}

class TimeLeft {
  final int days;
  final int hours;
  final int minutes;

  TimeLeft({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  String get formattedShort => '${days}d ${hours}h ${minutes}m';
  String get formattedLong => '${days} days, ${hours} hours, ${minutes} minutes';

  factory TimeLeft.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TimeLeft(days: 0, hours: 0, minutes: 0);
    return TimeLeft(
      days: _parseInt(json['days']),
      hours: _parseInt(json['hours']),
      minutes: _parseInt(json['minutes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'days': days,
    'hours': hours,
    'minutes': minutes,
  };
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
  final bool isBooked;
  final String transportType;
  final double transportRating;
  final String stayType;
  final double stayRating;
  final int totalSpots;
  final int spotsJoined;
  final String joinDeadline; // ISO 8601 format
  final String startDateTime; // Tour start date/time in ISO 8601 format
  final TimeLeft timeLeft; // Time remaining to join
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
    this.isBooked = false,
    required this.transportType,
    required this.transportRating,
    required this.stayType,
    required this.stayRating,
    required this.totalSpots,
    required this.spotsJoined,
    required this.joinDeadline,
    required this.startDateTime,
    required this.timeLeft,
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
      'isBooked': isBooked,
      'transportType': transportType,
      'transportRating': transportRating,
      'stayType': stayType,
      'stayRating': stayRating,
      'totalSpots': totalSpots,
      'spotsJoined': spotsJoined,
      'joinDeadline': joinDeadline,
      'startDateTime': startDateTime,
      'timeLeft': timeLeft.toJson(),
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

    // Parse duration from duration_text if available (e.g., "2 Days, 3 Nights")
    int durationDays = _parseInt(json['duration_days']);
    int durationNights = _parseInt(json['duration_nights']);
    
    final durationText = json['duration_text']?.toString() ?? '';
    if (durationText.isNotEmpty && (durationDays == 0 || durationNights == 0)) {
      // Extract numbers from duration_text using regex
      final daysMatch = RegExp(r'(\d+)\s*Days?', caseSensitive: false).firstMatch(durationText);
      final nightsMatch = RegExp(r'(\d+)\s*Nights?', caseSensitive: false).firstMatch(durationText);
      
      if (daysMatch != null) {
        durationDays = int.tryParse(daysMatch.group(1) ?? '0') ?? durationDays;
      }
      if (nightsMatch != null) {
        durationNights = int.tryParse(nightsMatch.group(1) ?? '0') ?? durationNights;
      }
    }

    // Parse numeric fields safely - use upfront_payment and total_cost from API
    final upcomingPayment = _parseInt(json['upfront_payment'] ?? json['price']);
    final totalCost = _parseInt(json['total_cost'] ?? json['fullCost']);
    
    final model = TourModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      location: locationStr,
      division: divisionStr,
      locationText: locationVal.toString(),
      durationDays: durationDays,
      durationNights: durationNights,
      price: upcomingPayment,
      fullCost: totalCost > 0 ? totalCost : (upcomingPayment * 2),
      rating: _parseDouble(json['rating']),
      reviewCount: _parseInt(json['rating_count']),
      imageUrl: json['featured_image'] ?? json['imageUrl'] ?? '',
      isVerifiedLead: _parseBool(json['is_verified_lead']),
      hasRefundGuarantee: _parseBool(json['has_refund_guarantee'], defaultValue: json['min_group_size'] != null),
      isBooked: _parseBool(json['is_booked']),
      transportType: transport?['name'] ?? json['transportType'] ?? 'Bus',
      transportRating: _parseDouble(transport?['rating'] ?? json['transportRating']),
      stayType: stay?['name'] ?? json['stayType'] ?? 'Hotel',
      stayRating: _parseDouble(stay?['rating'] ?? json['stayRating']),
      totalSpots: _parseInt(json['max_capacity']),
      spotsJoined: _parseInt(json['joined_count'] ?? json['spotsJoined']),
      joinDeadline: json['booking_deadline'] ?? json['start_datetime'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      startDateTime: json['start_datetime'] ?? json['startDateTime'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      timeLeft: TimeLeft.fromJson(json['time_left'] as Map<String, dynamic>?),
      tourLead: () {
        print('🔍 tour_lead raw value: $tourLead (type: ${tourLead.runtimeType})');
        if (tourLead == null) {
          print('⚠️ tour_lead is null, using empty model');
          return TourLeadModel.empty();
        }
        if (tourLead is Map<String, dynamic>) {
          print('✅ Parsing tour_lead from Map');
          return TourLeadModel.fromJson(tourLead);
        }
        print('⚠️ tour_lead is not a Map, using empty model');
        return TourLeadModel.empty();
      }(),
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
    
    print('🔍 Parsed TourModel: ${model.title} - Duration: ${model.durationDays}d/${model.durationNights}n, Price: ${model.price}, Total: ${model.fullCost}, TimeLeft: ${model.timeLeft.formattedShort}');
    
    return model;
  }

  TourModel copyWith({
    String? id,
    String? slug,
    String? title,
    String? location,
    String? division,
    String? locationText,
    int? durationDays,
    int? durationNights,
    int? price,
    int? fullCost,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    bool? isVerifiedLead,
    bool? hasRefundGuarantee,
    bool? isBooked,
    String? transportType,
    double? transportRating,
    String? stayType,
    double? stayRating,
    int? totalSpots,
    int? spotsJoined,
    String? joinDeadline,
    String? startDateTime,
    TimeLeft? timeLeft,
    TourLeadModel? tourLead,
    List<DayItinerary>? itinerary,
    List<String>? included,
    List<String>? notIncluded,
    MeetingPointModel? meetingPoint,
    RefundPolicyModel? refundPolicy,
  }) {
    return TourModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      location: location ?? this.location,
      division: division ?? this.division,
      locationText: locationText ?? this.locationText,
      durationDays: durationDays ?? this.durationDays,
      durationNights: durationNights ?? this.durationNights,
      price: price ?? this.price,
      fullCost: fullCost ?? this.fullCost,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerifiedLead: isVerifiedLead ?? this.isVerifiedLead,
      hasRefundGuarantee: hasRefundGuarantee ?? this.hasRefundGuarantee,
      isBooked: isBooked ?? this.isBooked,
      transportType: transportType ?? this.transportType,
      transportRating: transportRating ?? this.transportRating,
      stayType: stayType ?? this.stayType,
      stayRating: stayRating ?? this.stayRating,
      totalSpots: totalSpots ?? this.totalSpots,
      spotsJoined: spotsJoined ?? this.spotsJoined,
      joinDeadline: joinDeadline ?? this.joinDeadline,
      startDateTime: startDateTime ?? this.startDateTime,
      timeLeft: timeLeft ?? this.timeLeft,
      tourLead: tourLead ?? this.tourLead,
      itinerary: itinerary ?? this.itinerary,
      included: included ?? this.included,
      notIncluded: notIncluded ?? this.notIncluded,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      refundPolicy: refundPolicy ?? this.refundPolicy,
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
    final model = TourLeadModel(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? 'Unknown',
      avatarUrl: json['profile_pic'] ?? json['avatarUrl'] ?? '',
      rating: _parseDouble(json['rating']),
      toursLed: _parseInt(json['tours_completed'] ?? json['toursLed']),
    );
    print('🧑 Parsed TourLead: ${model.name}, Rating: ${model.rating}, Tours: ${model.toursLed}');
    return model;
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

  final String? bookingReference;
  final String? message;

  BookingModel({
    required this.id,
    required this.tour,
    required this.bookingDate,
    required this.status,
    required this.pricePaid,
    this.specialNote,
    this.bookingReference,
    this.message,
  });

  bool get isPast {
    // If status is completed, it's past
    if (status.toLowerCase() == 'completed') return true;
    
    // Otherwise check date
    final tourDate = DateTime.tryParse(tour.startDateTime) ?? DateTime.now().add(const Duration(days: 1));
    return tourDate.isBefore(DateTime.now());
  }

  bool get isUpcoming => !isPast;
  
  factory BookingModel.fromApiJson(Map<String, dynamic> json) {
    // Construct a partial TourModel from the flattened API response
    final tour = TourModel(
      id: '', // Not provided in flattened response
      slug: json['tour_slug'] ?? '', // Updated to parse tour_slug
      title: json['tour_title'] ?? '',
      location: json['location'] ?? '', // Updated to parse location
      division: '',
      locationText: json['location'] ?? '',
      durationDays: 0,
      durationNights: 0,
      price: _parseInt(json['price']),
      fullCost: _parseInt(json['price']), // Assuming just price for now
      rating: 0.0,
      reviewCount: 0,
      imageUrl: json['tour_image'] ?? '',
      isVerifiedLead: false,
      hasRefundGuarantee: false,
      isBooked: true, // Since this is a booking model, the tour is booked
      transportType: 'Bus',
      transportRating: 0.0,
      stayType: 'Hotel',
      stayRating: 0.0,
      totalSpots: 0,
      spotsJoined: 0,
      joinDeadline: json['start_date'] ?? DateTime.now().toIso8601String(),
      startDateTime: json['start_date'] ?? DateTime.now().toIso8601String(),
      timeLeft: TimeLeft(days: 0, hours: 0, minutes: 0),
      tourLead: TourLeadModel.empty(),
      itinerary: [],
      included: [],
      notIncluded: [],
      meetingPoint: MeetingPointModel(location: '', time: ''),
      refundPolicy: RefundPolicyModel.empty(),
    );

    return BookingModel(
      id: json['id']?.toString() ?? '',
      tour: tour,
      bookingDate: json['start_date'] ?? DateTime.now().toIso8601String(), // Start date as proxy
      status: json['status'] ?? 'pending',
      pricePaid: _parseInt(json['price']),
      bookingReference: json['booking_reference'],
      message: json['message'],
    );
  }
}
