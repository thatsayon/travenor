import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../models/tour_model.dart';
import '../screens/tour/tour_details_page.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  Color _getStatusColor() {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'cancelled':
        return AppTheme.error;
      case 'completed':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textLight;
    }
  }

  String _getStatusLabel() {
    return booking.status[0].toUpperCase() + booking.status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final tour = booking.tour;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailsPage(tour: tour),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: tour.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 120,
                  color: AppTheme.backgroundGray,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 120,
                  color: AppTheme.backgroundGray,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            tour.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusLabel(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.bookingDate.split('T')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tour.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price and Details button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Paid',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '৳${booking.pricePaid}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.primaryTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TourDetailsPage(tour: tour),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Details',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryTeal,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: AppTheme.primaryTeal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Special note
                    if (booking.specialNote != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppTheme.warning,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.specialNote!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
