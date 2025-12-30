import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../main.dart';
import '../../models/tour_model.dart';
import '../../widgets/custom_badge.dart';
import '../../services/profile_service.dart';
import '../profile/complete_profile_page.dart';
import '../booking/booking_confirmation_page.dart';

class TourDetailsPage extends StatefulWidget {
  final TourModel tour;

  const TourDetailsPage({
    super.key,
    required this.tour,
  });

  @override
  State<TourDetailsPage> createState() => _TourDetailsPageState();
}

class _TourDetailsPageState extends State<TourDetailsPage> {
  int _expandedDay = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
                _buildHeaderImage(),
                
                // Tour Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.tour.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Location and Rating
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.tour.location,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.star,
                            size: 18,
                            color: AppTheme.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.tour.rating}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          Text(
                            ' (${widget.tour.reviewCount} reviews)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Duration, Transport, Stay Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.calendar_today,
                              label: 'Duration',
                              value: '${widget.tour.durationDays} Days, ${widget.tour.durationNights}\nNights',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.directions_bus,
                              label: 'Transport',
                              value: widget.tour.transportType,
                              rating: widget.tour.transportRating,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.hotel,
                              label: 'Stay',
                              value: widget.tour.stayType,
                              rating: widget.tour.stayRating,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Booking Progress
                      _buildBookingProgress(),
                      
                      const SizedBox(height: 24),
                      
                      // Tour Lead
                      _buildTourLead(),
                      
                      const SizedBox(height: 24),
                      
                      // Day-by-Day Itinerary
                      _buildItinerary(),
                      
                      const SizedBox(height: 24),
                      
                      // What's Included
                      _buildIncluded(),
                      
                      const SizedBox(height: 24),
                      
                      // Meeting Point
                      _buildMeetingPoint(),
                      
                      const SizedBox(height: 24),
                      
                      // Refund Guarantee
                      _buildRefundGuarantee(),
                      
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                ),
              ),
            ),
          ),
          
          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.tour.imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 300,
            color: AppTheme.backgroundGray,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 300,
            color: AppTheme.backgroundGray,
            child: const Icon(Icons.image_not_supported),
          ),
        ),
        
        // Badges
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.tour.isVerifiedLead)
                CustomBadge(
                  icon: Icons.verified,
                  label: 'Verified Lead',
                ),
              if (widget.tour.hasRefundGuarantee)
                CustomBadge(
                  icon: Icons.currency_exchange,
                  label: 'Refund Guaranteed',
                  backgroundColor: AppTheme.accentOrange,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    double? rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          if (rating != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 14, color: AppTheme.warning),
                const SizedBox(width: 2),
                Text(
                  '$rating',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Join before',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppTheme.accentOrange),
                        const SizedBox(width: 4),
                        Text(
                          '0d 0h left',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.tour.totalSpots - widget.tour.spotsJoined} more needed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.people_outline, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${widget.tour.spotsJoined}/${widget.tour.totalSpots} joined',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.tour.spotsJoined / widget.tour.totalSpots,
              backgroundColor: AppTheme.backgroundGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${widget.tour.spotsRemaining} spots remaining (max ${widget.tour.totalSpots})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTourLead() {
    final lead = widget.tour.tourLead;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your Tour Lead',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Icon(Icons.verified, size: 18, color: AppTheme.primaryTeal),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(lead.avatarUrl),
                backgroundColor: AppTheme.backgroundGray,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: AppTheme.warning),
                        const SizedBox(width: 4),
                        Text(
                          '${lead.rating}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          ' • ${lead.toursLed} tours led',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItinerary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day-by-Day Itinerary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.tour.itinerary.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final day = widget.tour.itinerary[index];
            final isExpanded = _expandedDay == index;
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedDay = isExpanded ? -1 : index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primaryTeal,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  day.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                      
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        ...day.activities.map((activity) => Padding(
                              padding: const EdgeInsets.only(left: 44, bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: AppTheme.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      activity,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIncluded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Included',
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
              ...widget.tour.included.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              
              if (widget.tour.notIncluded.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Not Included',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ...widget.tour.notIncluded.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 18,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingPoint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place, color: AppTheme.primaryTeal, size: 24),
              const SizedBox(width: 8),
              Text(
                'Meeting Point',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.tour.meetingPoint.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                widget.tour.meetingPoint.time,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefundGuarantee() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: AppTheme.success, size: 24),
              const SizedBox(width: 8),
              Text(
                'Refund Guarantee',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.tour.refundPolicy.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reserve with',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${widget.tour.price}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // Check if profile is complete
                final profileService = ProfileService();
                final isComplete = await profileService.isProfileComplete();
                
                if (!mounted) return;
                
                if (isComplete) {
                  // Profile complete, get profile and go to booking confirmation
                  final profile = await profileService.getProfile();
                  if (profile != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmationPage(
                          tour: widget.tour,
                          userProfile: profile,
                        ),
                      ),
                    );
                  }
                } else {
                  // Profile incomplete, go to complete profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompleteProfilePage(tour: widget.tour),
                    ),
                  );
                }
              },
              child: const Text('Join This Tour'),
            ),
          ),
        ],
      ),
    );
  }
}
