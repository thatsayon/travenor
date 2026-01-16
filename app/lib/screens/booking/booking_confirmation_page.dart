import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../models/tour_model.dart';
import '../../models/user_profile_model.dart';

import '../../providers/auth_provider.dart';
import '../../services/tour_service.dart';
import '../profile/terms_of_service_page.dart';
import 'thank_you_page.dart';

class BookingConfirmationPage extends ConsumerStatefulWidget {
  final TourModel tour;
  final UserProfileModel userProfile;
  final String bookingId;

  const BookingConfirmationPage({
    super.key,
    required this.tour,
    required this.userProfile,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends ConsumerState<BookingConfirmationPage> {
  // BookingService removed in favor of TourService
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleConfirmBooking() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tourService = ref.read(tourServiceProvider);

      final response = await tourService.confirmBooking(
        bookingId: widget.bookingId,
        acceptedTerms: true,
      );

      if (!mounted) return;

      if (response.success) {
        // Extract connection details with defensive programming
        final details = response.bookingDetails;
        print('🎉 Confirmation Details: $details'); // Debug info

        // Try to find the booking reference in various probable keys
        final String bookingRef = details?['booking_reference']?.toString() ?? 
                                  details?['reference']?.toString() ?? 
                                  details?['booking_code']?.toString() ?? 
                                  details?['booking_id']?.toString() ?? 
                                  widget.bookingId;
                                  
        print('🎫 Final Booking Reference: $bookingRef');

        // Navigate to thank you page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ThankYouPage(
              bookingReference: bookingRef,
              tour: widget.tour,
              tourTitle: details?['tour_title'] ?? details?['tour']?['title'],
              location: details?['location'] ?? details?['tour']?['location'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to confirm booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming booking: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // White status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.white,
          ),
          
          // Scrollable content
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                // Clean header with back button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderGray,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGray,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Confirm Booking',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tour Summary
                        Text(
                          'Tour Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tour.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, 
                                    size: 16, 
                                    color: AppTheme.textSecondary
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.tour.locationText,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, 
                                    size: 16, 
                                    color: AppTheme.textSecondary
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.tour.durationText,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Your Details
                        Text(
                          'Your Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderGray),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Name', widget.userProfile.fullName ?? 'N/A'),
                              const Divider(height: 24),
                              _buildDetailRow('Phone', widget.userProfile.phoneNumber ?? 'N/A'),
                              if (widget.userProfile.email != null && widget.userProfile.email!.isNotEmpty) ...[
                                const Divider(height: 24),
                                _buildDetailRow('Email', widget.userProfile.email!),
                              ],
                              const Divider(height: 24),
                              _buildDetailRow('Emergency Contact', widget.userProfile.emergencyContact ?? 'N/A'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Price Breakdown
                        Text(
                          'Price Summary',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Full Tour Package',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '৳${widget.tour.fullCost}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Upfront Payment',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pay now to confirm booking',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '৳${widget.tour.price}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms checkbox
                        Transform.translate(
                          offset: const Offset(-8.0, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    side: BorderSide(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                                  activeColor: AppTheme.primaryBlue,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2.5),
                                  child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const TermsOfServicePage(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'terms and conditions',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.primaryBlue,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' and refund policy'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          ),
                        ),

                        const SizedBox(height: 80), // Space for button
                      ],
                    ),
                  ),
                ),

                // Bottom button
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    MediaQuery.of(context).padding.bottom + 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleConfirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Confirm Booking',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
