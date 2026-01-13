import 'dart:convert';
import 'package:dio/dio.dart';
import 'dio_client.dart';

/// Model for notification preferences
class NotificationPreference {
  final bool newTourNotifications;
  final bool bookingUpdates;
  final bool tourReminders;
  final bool marketingEmails;
  final bool marketingNotifications;

  NotificationPreference({
    required this.newTourNotifications,
    required this.bookingUpdates,
    required this.tourReminders,
    required this.marketingEmails,
    required this.marketingNotifications,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      newTourNotifications: json['new_tour_notifications'] ?? true,
      bookingUpdates: json['booking_updates'] ?? true,
      tourReminders: json['tour_reminders'] ?? true,
      marketingEmails: json['marketing_emails'] ?? false,
      marketingNotifications: json['marketing_notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_tour_notifications': newTourNotifications,
      'booking_updates': bookingUpdates,
      'tour_reminders': tourReminders,
      'marketing_emails': marketingEmails,
      'marketing_notifications': marketingNotifications,
    };
  }
}

/// Response model for notification preference operations
class NotificationPreferenceResponse {
  final bool success;
  final String? message;
  final NotificationPreference? preferences;
  final String? error;

  NotificationPreferenceResponse({
    required this.success,
    this.message,
    this.preferences,
    this.error,
  });

  factory NotificationPreferenceResponse.fromJson(Map<String, dynamic> json) {
    // Check if the JSON itself looks like the preferences object (flat structure)
    // or if it's nested under a 'preferences' key
    NotificationPreference? prefs;
    
    if (json.containsKey('preferences') && json['preferences'] != null) {
      prefs = NotificationPreference.fromJson(json['preferences']);
    } else if (json.containsKey('new_tour_notifications') || 
               json.containsKey('marketing_emails')) {
      // It seems the response IS the preferences object
      prefs = NotificationPreference.fromJson(json);
    }

    return NotificationPreferenceResponse(
      success: json['success'] ?? true,
      message: json['message'],
      preferences: prefs,
      error: json['error']?.toString(),
    );
  }
}

class NotificationService {
  final DioClient _dioClient;

  NotificationService(this._dioClient);

  /// Get current notification preferences
  Future<NotificationPreferenceResponse> getNotificationPreference() async {
    try {
      final response = await _dioClient.dio.get('/notification/preference/');
      
      // Parse response data (handle both Map and String)
      Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = response.data as Map<String, dynamic>;
      }
      
      return NotificationPreferenceResponse.fromJson(data);
    } on DioException catch (e) {
      return NotificationPreferenceResponse(
        success: false,
        error: e.message ?? 'Failed to fetch notification preferences',
      );
    } catch (e) {
      return NotificationPreferenceResponse(
        success: false,
        error: 'Failed to parse notification preferences',
      );
    }
  }

  /// Update notification preferences
  Future<NotificationPreferenceResponse> updateNotificationPreference({
    bool? newTourNotifications,
    bool? bookingUpdates,
    bool? tourReminders,
    bool? marketingEmails,
    bool? marketingNotifications,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (newTourNotifications != null) data['new_tour_notifications'] = newTourNotifications;
      if (bookingUpdates != null) data['booking_updates'] = bookingUpdates;
      if (tourReminders != null) data['tour_reminders'] = tourReminders;
      if (marketingEmails != null) data['marketing_emails'] = marketingEmails;
      if (marketingNotifications != null) data['marketing_notifications'] = marketingNotifications;

      final response = await _dioClient.dio.patch(
        '/notification/preference/',
        data: data,
      );
      
      // Parse response data (handle both Map and String)
      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data);
      } else {
        responseData = response.data as Map<String, dynamic>;
      }
      
      return NotificationPreferenceResponse.fromJson(responseData);
    } on DioException catch (e) {
      return NotificationPreferenceResponse(
        success: false,
        error: e.message ?? 'Failed to update notification preferences',
      );
    } catch (e) {
      return NotificationPreferenceResponse(
        success: false,
        error: 'Failed to parse update response',
      );
    }
  }
}
