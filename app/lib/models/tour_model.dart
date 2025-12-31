class TourModel {
  final String id;
  final String title;
  final String location;
  final String division;
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
    required this.title,
    required this.location,
    required this.division,
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
      'title': title,
      'location': location,
      'division': division,
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
    return TourModel(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      division: json['division'],
      durationDays: json['durationDays'],
      durationNights: json['durationNights'],
      price: json['price'],
      fullCost: json['fullCost'] ?? (json['price'] * 2), // Fallback if missing
      rating: json['rating'],
      reviewCount: json['reviewCount'],
      imageUrl: json['imageUrl'],
      isVerifiedLead: json['isVerifiedLead'],
      hasRefundGuarantee: json['hasRefundGuarantee'],
      transportType: json['transportType'],
      transportRating: json['transportRating'],
      stayType: json['stayType'],
      stayRating: json['stayRating'],
      totalSpots: json['totalSpots'],
      spotsJoined: json['spotsJoined'],
      joinDeadline: json['joinDeadline'],
      tourLead: TourLeadModel.fromJson(json['tourLead']),
      itinerary: (json['itinerary'] as List).map((e) => DayItinerary.fromJson(e)).toList(),
      included: List<String>.from(json['included']),
      notIncluded: List<String>.from(json['notIncluded']),
      meetingPoint: MeetingPointModel.fromJson(json['meetingPoint']),
      refundPolicy: RefundPolicyModel.fromJson(json['refundPolicy']),
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

  factory TourLeadModel.fromJson(Map<String, dynamic> json) {
    return TourLeadModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      rating: json['rating'],
      toursLed: json['toursLed'],
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
    return DayItinerary(
      day: json['day'],
      title: json['title'],
      description: json['description'],
      activities: List<String>.from(json['activities']),
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

  factory RefundPolicyModel.fromJson(Map<String, dynamic> json) {
    return RefundPolicyModel(
      description: json['description'],
      minimumGroupSize: json['minimumGroupSize'],
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
