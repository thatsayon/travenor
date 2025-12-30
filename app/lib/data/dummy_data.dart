import '../models/tour_model.dart';

class DummyData {
  // Tour Leads
  static final rafiqAhmed = TourLeadModel(
    id: 'lead_1',
    name: 'Rafiq Ahmed',
    avatarUrl: 'https://ui-avatars.com/api/?name=Rafiq+Ahmed&background=0F766E&color=fff',
    rating: 4.9,
    toursLed: 47,
  );

  static final nasrinBegum = TourLeadModel(
    id: 'lead_2',
    name: 'Nasrin Begum',
    avatarUrl: 'https://ui-avatars.com/api/?name=Nasrin+Begum&background=0F766E&color=fff',
    rating: 4.8,
    toursLed: 32,
  );

  static final kamalHossain = TourLeadModel(
    id: 'lead_3',
    name: 'Kamal Hossain',
    avatarUrl: 'https://ui-avatars.com/api/?name=Kamal+Hossain&background=0F766E&color=fff',
    rating: 4.7,
    toursLed: 28,
  );

  // Tours
  static final sundarbansExplorer = TourModel(
    id: 'tour_1',
    title: 'Sundarbans Explorer',
    location: 'Khulna Division',
    division: 'Khulna',
    durationDays: 4,
    durationNights: 3,
    price: 2500,
    rating: 4.8,
    reviewCount: 124,
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=80',
    isVerifiedLead: true,
    hasRefundGuarantee: true,
    transportType: 'AC Bus',
    transportRating: 4.5,
    stayType: 'Resort',
    stayRating: 4.2,
    totalSpots: 16,
    spotsJoined: 8,
    joinDeadline: '2024-02-15T00:00:00.000Z',
    tourLead: rafiqAhmed,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Journey to the Mangroves',
        description: 'Depart Dhaka early morning',
        activities: [
          'AC bus from Dhaka',
          'Lunch at Khulna',
          'Board the boat',
          'Evening cruise',
        ],
      ),
      DayItinerary(
        day: 2,
        title: 'Deep Forest Exploration',
        description: 'Full day wildlife safari',
        activities: [
          'Early morning bird watching',
          'Wildlife spotting cruise',
          'Visit Kochikhali watchtower',
          'Sunset photography',
        ],
      ),
      DayItinerary(
        day: 3,
        title: 'Village & Culture',
        description: 'Local community experience',
        activities: [
          'Visit local fishing village',
          'Traditional honey collection demo',
          'Cultural performance',
          'Local cuisine dinner',
        ],
      ),
      DayItinerary(
        day: 4,
        title: 'Return Journey',
        description: 'Head back with memories',
        activities: [
          'Morning leisure',
          'Return boat ride',
          'Lunch on the way',
          'Arrive Dhaka evening',
        ],
      ),
    ],
    included: [
      'AC Transport from Dhaka',
      '3 nights accommodation',
      'All meals',
      'Boat safari',
      'Guide fees',
      'Forest entry permits',
    ],
    notIncluded: [
      'Personal expenses',
      'Tips',
      'Travel insurance',
    ],
    meetingPoint: MeetingPointModel(
      location: 'Kamalapur Railway Station, Gate 3',
      time: '5:30 AM',
    ),
    refundPolicy: RefundPolicyModel(
      description: 'If the minimum group size (12 travelers) isn\'t reached by the deadline, you\'ll receive a full refund of your upfront payment within 3-5 business days.',
      minimumGroupSize: 12,
    ),
  );

  static final coxsBazarAdventure = TourModel(
    id: 'tour_2',
    title: 'Cox\'s Bazar Beach Paradise',
    location: 'Chittagong Division',
    division: 'Chittagong',
    durationDays: 3,
    durationNights: 2,
    price: 3200,
    rating: 4.6,
    reviewCount: 89,
    imageUrl: 'https://images.unsplash.com/photo-1559664651-be3b9e1e5238?w=800&q=80',
    isVerifiedLead: true,
    hasRefundGuarantee: true,
    transportType: 'AC Bus',
    transportRating: 4.3,
    stayType: 'Beach Resort',
    stayRating: 4.7,
    totalSpots: 20,
    spotsJoined: 15,
    joinDeadline: '2024-03-01T00:00:00.000Z',
    tourLead: nasrinBegum,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Beach Welcome',
        description: 'Arrive at the longest beach',
        activities: [
          'Departure from Dhaka',
          'Check-in at resort',
          'Beach exploration',
          'Sunset viewing',
        ],
      ),
      DayItinerary(
        day: 2,
        title: 'Island Hopping',
        description: 'Explore nearby attractions',
        activities: [
          'Saint Martin Island trip',
          'Snorkeling session',
          'Seafood lunch',
          'Beach bonfire',
        ],
      ),
      DayItinerary(
        day: 3,
        title: 'Local Culture & Return',
        description: 'Experience local life',
        activities: [
          'Visit fishing village',
          'Shopping at local market',
          'Lunch break',
          'Return to Dhaka',
        ],
      ),
    ],
    included: [
      'AC Transport from Dhaka',
      '2 nights beach resort stay',
      'All meals',
      'Island boat trip',
      'Guide fees',
      'Snorkeling equipment',
    ],
    notIncluded: [
      'Personal expenses',
      'Tips',
      'Travel insurance',
      'Water sports activities',
    ],
    meetingPoint: MeetingPointModel(
      location: 'Abdullahpur Bus Terminal',
      time: '6:00 AM',
    ),
    refundPolicy: RefundPolicyModel(
      description: 'If the minimum group size (15 travelers) isn\'t reached by the deadline, you\'ll receive a full refund of your upfront payment within 3-5 business days.',
      minimumGroupSize: 15,
    ),
  );

  static final sylhetTeaGardens = TourModel(
    id: 'tour_3',
    title: 'Sylhet Tea Garden Escape',
    location: 'Sylhet Division',
    division: 'Sylhet',
    durationDays: 3,
    durationNights: 2,
    price: 2800,
    rating: 4.7,
    reviewCount: 67,
    imageUrl: 'https://images.unsplash.com/photo-1563296374-c3e8ee801fc0?w=800&q=80',
    isVerifiedLead: true,
    hasRefundGuarantee: false,
    transportType: 'AC Bus',
    transportRating: 4.4,
    stayType: 'Tea Estate Bungalow',
    stayRating: 4.6,
    totalSpots: 12,
    spotsJoined: 9,
    joinDeadline: '2024-02-28T00:00:00.000Z',
    tourLead: kamalHossain,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Journey to Green Hills',
        description: 'Travel to the land of two leaves and a bud',
        activities: [
          'Early morning departure',
          'Scenic drive through hills',
          'Check-in at tea estate',
          'Evening tea garden walk',
        ],
      ),
      DayItinerary(
        day: 2,
        title: 'Nature & Waterfalls',
        description: 'Explore natural beauty',
        activities: [
          'Visit Ratargul Swamp Forest',
          'Boat ride in swamp',
          'Jaflong stone collection visit',
          'Tamabil border visit',
        ],
      ),
      DayItinerary(
        day: 3,
        title: 'Tea & Culture',
        description: 'Learn about tea culture',
        activities: [
          'Tea factory tour',
          'Tea tasting session',
          'Local tribal village visit',
          'Return journey',
        ],
      ),
    ],
    included: [
      'AC Transport from Dhaka',
      '2 nights tea estate accommodation',
      'All meals with special tea',
      'Boat rides',
      'Guide fees',
      'Entry permits',
    ],
    notIncluded: [
      'Personal expenses',
      'Tips',
      'Travel insurance',
    ],
    meetingPoint: MeetingPointModel(
      location: 'Mohakhali Bus Terminal',
      time: '7:00 AM',
    ),
    refundPolicy: RefundPolicyModel(
      description: 'Partial refund available up to 7 days before departure. No refund after that.',
      minimumGroupSize: 8,
    ),
  );

  // Get all tours
  static List<TourModel> get allTours => [
        sundarbansExplorer,
        coxsBazarAdventure,
        sylhetTeaGardens,
      ];

  // Get sample bookings for the current user
  static List<BookingModel> get userBookings => [
        BookingModel(
          id: 'booking_1',
          tour: sundarbansExplorer,
          bookingDate: '2024-02-15T00:00:00.000Z',
          status: 'pending',
          pricePaid: 2500,
          specialNote: 'Waiting for minimum group size to be reached',
        ),
      ];
}
