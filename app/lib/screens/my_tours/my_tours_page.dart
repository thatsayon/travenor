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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Convert BookingRequestModel to BookingModel for display
    final upcomingBookings = _allBookings
        .where((b) => b.status != 'cancelled' && !_isPast(b))
        .map((b) => _bookingService.toBookingModel(b))
        .toList();
    
    final pastBookings = _allBookings
        .where((b) => b.status == 'cancelled' || _isPast(b))
        .map((b) => _bookingService.toBookingModel(b))
        .toList();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
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
            
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryTeal,
                unselectedLabelColor: AppTheme.textLight,
                indicatorColor: AppTheme.primaryTeal,
                indicatorWeight: 3,
                labelStyle: Theme.of(context).textTheme.titleMedium,
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
                  // Upcoming
                  _buildBookingList(upcomingBookings, isUpcoming: true),
                  
                  // Past
                  _buildBookingList(pastBookings, isUpcoming: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPast(BookingRequestModel booking) {
    try {
      final tourDate = DateTime.parse(booking.tour.joinDeadline);
      return tourDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  Widget _buildBookingList(List<dynamic> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return BookingCard(booking: bookings[index]);
        },
      ),
    );
  }
}
