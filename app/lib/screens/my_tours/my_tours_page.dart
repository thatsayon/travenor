import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../widgets/booking_card.dart';
import '../../providers/auth_provider.dart';
import '../../models/tour_model.dart';

class MyToursPage extends ConsumerStatefulWidget {
  const MyToursPage({super.key});

  @override
  ConsumerState<MyToursPage> createState() => _MyToursPageState();
}

class _MyToursPageState extends ConsumerState<MyToursPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _upcomingTours = [];
  List<BookingModel> _pastTours = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTours();
  }

  Future<void> _loadTours() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tourService = ref.read(tourServiceProvider);
      
      // Load both upcoming and past tours in parallel
      final results = await Future.wait([
        tourService.getUpcomingTours(),
        tourService.getPastTours(),
      ]);

      if (mounted) {
        setState(() {
          _upcomingTours = results[0];
          _pastTours = results[1];
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load tours';
          _isLoading = false;
        });
      }
      print('❌ Error loading tours: $error');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            
            // Tab bar container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  indicatorPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
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
                  labelColor: AppTheme.primaryBlue,
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
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                      ),
                    )
                  : _error != null
                      ? _buildErrorState()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTourList(_upcomingTours, isUpcoming: true),
                            _buildTourList(_pastTours, isUpcoming: false),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTours,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(160, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourList(List<BookingModel> tours, {required bool isUpcoming}) {
    if (tours.isEmpty) {
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
      onRefresh: _loadTours,
      color: AppTheme.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tours.length,
        itemBuilder: (context, index) {
          final booking = tours[index];
          return BookingCard(booking: booking);
        },
      ),
    );
  }
}
