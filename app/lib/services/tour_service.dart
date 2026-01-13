import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/tour_model.dart';

/// Response model for join tour API
class JoinTourResponse {
  final bool success;
  final String? message;
  final String? bookingId;
  final String? error;

  JoinTourResponse({
    required this.success,
    this.message,
    this.bookingId,
    this.error,
  });

  factory JoinTourResponse.fromJson(Map<String, dynamic> json) {
    return JoinTourResponse(
      success: json['success'] ?? false,
      message: json['message'],
      bookingId: json['booking_id'] ?? json['id'],
      error: json['error']?.toString(),
    );
  }
}

/// Response model for confirm booking API
class ConfirmBookingResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? bookingDetails;
  final String? error;

  ConfirmBookingResponse({
    required this.success,
    this.message,
    this.bookingDetails,
    this.error,
  });

  factory ConfirmBookingResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmBookingResponse(
      success: json['success'] ?? false,
      message: json['message'],
      bookingDetails: json['booking'],
      error: json['error']?.toString(),
    );
  }
}

class TourService {
  final DioClient _dioClient;

  TourService(this._dioClient);

  /// Get list of all available tours
  Future<List<TourModel>> getTourList() async {
    try {
      final response = await _dioClient.dio.get('/tour/list/');
      
      if (response.statusCode == 200) {
        // API returns paginated response: {count, next, previous, results: [...]}
        final data = response.data;
        final List<dynamic> toursJson;
        
        if (data is Map && data['results'] != null) {
          // Paginated response
          toursJson = data['results'] as List;
        } else if (data is List) {
          toursJson = data;
        } else if (data is Map && data['tours'] != null) {
          toursJson = data['tours'] as List;
        } else {
          print('⚠️ Unexpected tour list response format: $data');
          return [];
        }
        
        print('✅ Fetched ${toursJson.length} tours from API');
        return toursJson.map((json) => TourModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ Error fetching tour list: ${e.message}');
      return [];
    }
  }

  /// Get detailed information about a specific tour
  Future<TourModel?> getTourDetail(String slug) async {
    try {
      final response = await _dioClient.dio.get('/tour/detail/$slug/');
      
      if (response.statusCode == 200) {
        return TourModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      print('❌ Error fetching tour detail: ${e.message}');
      return null;
    }
  }

  /// Check if user has already joined a tour (GET)
  Future<Map<String, dynamic>?> checkJoinStatus(String slug) async {
    try {
      final response = await _dioClient.dio.get('/tour/join/$slug/');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      print('❌ Error checking join status: ${e.message}');
      return null;
    }
  }

  /// Join a tour / Create booking (POST)
  Future<JoinTourResponse> joinTour(String slug) async {
    try {
      final response = await _dioClient.dio.post('/tour/join/$slug/');
      return JoinTourResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return JoinTourResponse.fromJson(e.response!.data);
      }
      return JoinTourResponse(
        success: false,
        error: e.message ?? 'Failed to join tour',
      );
    }
  }

  /// Get booking confirmation details (GET)
  Future<Map<String, dynamic>?> getConfirmationDetails(String bookingId) async {
    try {
      final response = await _dioClient.dio.get('/tour/confirm/$bookingId/');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      print('❌ Error fetching confirmation details: ${e.message}');
      return null;
    }
  }

  /// Confirm booking with terms acceptance (POST)
  Future<ConfirmBookingResponse> confirmBooking({
    required String bookingId,
    required bool acceptedTerms,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/tour/confirm/$bookingId/',
        data: {
          'accepted_terms': acceptedTerms,
        },
      );
      return ConfirmBookingResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ConfirmBookingResponse.fromJson(e.response!.data);
      }
      return ConfirmBookingResponse(
        success: false,
        error: e.message ?? 'Failed to confirm booking',
      );
    }
  }

  /// Get user's upcoming tours
  Future<List<TourModel>> getUpcomingTours() async {
    try {
      final response = await _dioClient.dio.get('/tour/upcoming/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> toursJson;
        
        if (data is List) {
          toursJson = data;
        } else if (data is Map && data['tours'] != null) {
          toursJson = data['tours'] as List;
        } else {
          print('⚠️ Unexpected upcoming tours response format');
          return [];
        }
        
        return toursJson.map((json) => TourModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ Error fetching upcoming tours: ${e.message}');
      return [];
    }
  }

  /// Get user's past tours
  Future<List<TourModel>> getPastTours() async {
    try {
      final response = await _dioClient.dio.get('/tour/past/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> toursJson;
        
        if (data is List) {
          toursJson = data;
        } else if (data is Map && data['tours'] != null) {
          toursJson = data['tours'] as List;
        } else {
          print('⚠️ Unexpected past tours response format');
          return [];
        }
        
        return toursJson.map((json) => TourModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ Error fetching past tours: ${e.message}');
      return [];
    }
  }
}
