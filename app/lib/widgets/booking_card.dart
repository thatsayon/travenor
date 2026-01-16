import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/tour_model.dart';
import '../routes/app_routes.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({
    super.key,
    required this.booking,
  });



  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaid = booking.status.toLowerCase() == 'paid';
    final bool isPending = booking.status.toLowerCase() == 'pending';
    
    // Status color logic
    Color statusColor;
    Color statusBgColor;
    Color statusBorderColor;
    String statusText;

    if (isPaid) {
      statusColor = AppTheme.success;
      statusBgColor = AppTheme.success.withValues(alpha: 0.1);
      statusBorderColor = AppTheme.success.withValues(alpha: 0.3);
      statusText = 'Paid';
    } else if (isPending) {
      statusColor = const Color(0xFFF57C00); // Orange
      statusBgColor = const Color(0xFFFFF8E1); // Light yellow
      statusBorderColor = const Color(0xFFFFCC80);
      statusText = 'Pending';
    } else {
      statusColor = Colors.grey;
      statusBgColor = Colors.grey.withValues(alpha: 0.1);
      statusBorderColor = Colors.grey.withValues(alpha: 0.3);
      statusText = booking.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tour Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      booking.tour.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: AppTheme.backgroundGray,
                          child: Icon(Icons.image_outlined, color: AppTheme.textLight),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Status Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              booking.tour.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusBorderColor),
                            ),
                            child: Text(
                              statusText,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Date & Location Row
                      Row(
                        children: [
                          _buildIconText(
                            context,
                            Icons.calendar_today_outlined,
                            _formatDate(booking.bookingDate),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildIconText(
                              context,
                              Icons.location_on_outlined,
                              booking.tour.location,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Price and Details Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price (only show if not pending)
                          if (!isPending)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Paid',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '৳${booking.pricePaid.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            ),
                          
                          const Spacer(),

                          // Details Link
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (booking.tour.slug.isNotEmpty) {
                                  // Navigate to tour details with the full tour object
                                  // Note: Since we only have partial details here (from booking API), 
                                  // TourDetailsPage will fetch the full details using the slug/ID
                                  Navigator.pushNamed(
                                    context, 
                                    AppRoutes.tourDetails,
                                    arguments: booking.tour,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tour details unavailable')),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      'View Details',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryBlue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Helper Message Footer (if message exists)
          if (booking.message != null && booking.message!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: statusBorderColor.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  Icon(
                    isPaid ? Icons.check_circle_outline : Icons.info_outline_rounded,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.message!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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

  Widget _buildIconText(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
