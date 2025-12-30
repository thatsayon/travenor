import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/booking_request_model.dart';
import '../models/tour_model.dart';
import '../models/user_profile_model.dart';

class BookingService {
  static const String _bookingsKey = 'user_bookings';

  // Create booking
  Future<BookingRequestModel> createBooking({
    required String userId,
    required TourModel tour,
    required UserProfileModel userProfile,
  }) async {
    try {
      final booking = BookingRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        tourId: tour.id,
        tour: tour,
        userProfile: userProfile,
        requestDate: DateTime.now(),
        status: 'pending',
        amountPaid: tour.price.toDouble(),
        bookingReference: BookingRequestModel.generateReference(),
      );

      await _saveBooking(booking);
      print('✅ Booking created: ${booking.bookingReference}');
      return booking;
    } catch (error) {
      print('❌ Error creating booking: $error');
      rethrow;
    }
  }

  // Save booking to list
  Future<void> _saveBooking(BookingRequestModel booking) async {
    final bookings = await getAllBookings();
    bookings.add(booking);
    
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_bookingsKey, jsonEncode(bookingsJson));
  }

  // Get all bookings
  Future<List<BookingRequestModel>> getAllBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsString = prefs.getString(_bookingsKey);
      
      if (bookingsString == null) {
        return [];
      }

      final bookingsJson = jsonDecode(bookingsString) as List;
      return bookingsJson
          .map((json) => BookingRequestModel.fromJson(json))
          .toList();
    } catch (error) {
      print('❌ Error getting bookings: $error');
      return [];
    }
  }

  // Get booking by ID
  Future<BookingRequestModel?> getBookingById(String id) async {
    final bookings = await getAllBookings();
    try {
      return bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get bookings by status
  Future<List<BookingRequestModel>> getBookingsByStatus(String status) async {
    final bookings = await getAllBookings();
    return bookings.where((b) => b.status == status).toList();
  }

  // Update booking status (simulates admin confirmation)
  Future<void> updateBookingStatus(String bookingId, String newStatus, {String? adminNotes}) async {
    try {
      final bookings = await getAllBookings();
      final index = bookings.indexWhere((b) => b.id == bookingId);
      
      if (index != -1) {
        final updatedBooking = bookings[index].copyWith(
          status: newStatus,
          adminNotes: adminNotes,
        );
        bookings[index] = updatedBooking;
        
        final prefs = await SharedPreferences.getInstance();
        final bookingsJson = bookings.map((b) => b.toJson()).toList();
        await prefs.setString(_bookingsKey, jsonEncode(bookingsJson));
        
        print('✅ Booking status updated: $bookingId -> $newStatus');
      }
    } catch (error) {
      print('❌ Error updating booking status: $error');
      rethrow;
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
  }

  // Clear all bookings
  Future<void> clearAllBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookingsKey);
      print('✅ All bookings cleared');
    } catch (error) {
      print('❌ Error clearing bookings: $error');
    }
  }

  // Get pending bookings count
  Future<int> getPendingBookingsCount() async {
    final pending = await getBookingsByStatus('pending');
    return pending.length;
  }

  // Get confirmed bookings count
  Future<int> getConfirmedBookingsCount() async {
    final confirmed = await getBookingsByStatus('confirmed');
    return confirmed.length;
  }

  // Convert BookingRequestModel to BookingModel for My Tours display
  BookingModel toBookingModel(BookingRequestModel request) {
    return BookingModel(
      id: request.id,
      tour: request.tour,
      bookingDate: request.requestDate.toIso8601String(),
      status: request.status,
      pricePaid: request.amountPaid.toInt(),
      specialNote: request.adminNotes,
    );
  }
}
