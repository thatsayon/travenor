import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/booking_service.dart';
import '../../models/booking_request_model.dart';
import '../../widgets/booking_card.dart';

class MyToursPage extends StatefulWidget {
  const MyToursPage({super.key});

  @override
  State<MyToursPage> createState() => _MyToursPageState();
}

class _MyToursPageState extends State<MyToursPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bookingService = BookingService();
  List<BookingRequestModel> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _bookingService.getAllBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isPast(BookingRequestModel booking) {
    try {
      // Use join deadline as a proxy for tour date
      final tourDate = DateTime.parse(booking.tour.joinDeadline);
      return tourDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final upcomingBookings = _allBookings
        .where((b) => b.status != 'cancelled' && !_isPast(b))
        .map((b) => _bookingService.toBookingModel(b))
        .toList();
    
    final pastBookings = _allBookings
        .where((b) => b.status == 'cancelled' || _isPast(b))
        .map((b) => _bookingService.toBookingModel(b))
        .toList();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title
            // Header with title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'My Tours',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
              ),
            ),
            
            // Tab bar container overlapping the header slightly or just below
            // Tab bar container
            Transform.translate(
              offset: const Offset(0, 0), // No overlap needed
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // Moved background color here
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300), // Reduced to grey 300 for subtler look
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  height: 48, // Slightly increased height for better touch targets
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.all(4), // Padding around the entire tab bar content
                      indicatorPadding: EdgeInsets.zero, // The indicator fills the "tab" space, which is already constrained by the padding above
                      dividerColor: Colors.transparent, // Ensure no divider line
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      labelColor: AppTheme.primaryBlue, // Selected text color
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Past'),
                      ],
                    ),
                  ),
                ),
              ),

            
            // Fix spacing for tab bar transform
            // Adjusted spacing after tab bar
            const SizedBox(height: 0),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(upcomingBookings, isUpcoming: true),
                  _buildBookingList(pastBookings, isUpcoming: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUpcoming ? Icons.calendar_today_outlined : Icons.history,
                size: 64,
                color: AppTheme.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                isUpcoming ? 'No upcoming tours' : 'No past tours',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                isUpcoming 
                    ? 'Browse and join exciting tours!' 
                    : 'Your tour history will appear here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppTheme.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return BookingCard(booking: bookings[index]);
        },
      ),
    );
  }
}
