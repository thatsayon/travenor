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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryTeal,
                    AppTheme.primaryTealDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tours',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your adventures',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            
            // Tab bar with white background
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.textPrimary,
                unselectedLabelColor: AppTheme.textLight,
                indicatorColor: AppTheme.primaryTeal,
                indicatorWeight: 2,
                labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
            
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
      color: AppTheme.primaryTeal,
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
