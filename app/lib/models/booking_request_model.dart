import 'tour_model.dart';
import 'user_profile_model.dart';

class BookingRequestModel {
  final String id;
  final String userId;
  final String tourId;
  final TourModel tour;
  final UserProfileModel userProfile;
  final DateTime requestDate;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final double amountPaid;
  final String? bookingReference;
  final String? adminNotes;

  BookingRequestModel({
    required this.id,
    required this.userId,
    required this.tourId,
    required this.tour,
    required this.userProfile,
    required this.requestDate,
    required this.status,
    required this.amountPaid,
    this.bookingReference,
    this.adminNotes,
  });

  // Generate booking reference
  static String generateReference() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    return 'TVN-$timestamp';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tourId': tourId,
      'tour': tour.toJson(),
      'userProfile': userProfile.toJson(),
      'requestDate': requestDate.toIso8601String(),
      'status': status,
      'amountPaid': amountPaid,
      'bookingReference': bookingReference,
      'adminNotes': adminNotes,
    };
  }

  // Create from JSON
  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'],
      userId: json['userId'],
      tourId: json['tourId'],
      tour: TourModel.fromJson(json['tour']),
      userProfile: UserProfileModel.fromJson(json['userProfile']),
      requestDate: DateTime.parse(json['requestDate']),
      status: json['status'],
      amountPaid: json['amountPaid'],
      bookingReference: json['bookingReference'],
      adminNotes: json['adminNotes'],
    );
  }

  // Copy with method
  BookingRequestModel copyWith({
    String? id,
    String? userId,
    String? tourId,
    TourModel? tour,
    UserProfileModel? userProfile,
    DateTime? requestDate,
    String? status,
    double? amountPaid,
    String? bookingReference,
    String? adminNotes,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tourId: tourId ?? this.tourId,
      tour: tour ?? this.tour,
      userProfile: userProfile ?? this.userProfile,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      bookingReference: bookingReference ?? this.bookingReference,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() {
    return 'BookingRequestModel(id: $id, tour: ${tour.title}, status: $status, reference: $bookingReference)';
  }
}
