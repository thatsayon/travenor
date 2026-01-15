from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from app.tours.models import Tour, TourBooking, Division, Transport, Stay
from django.utils import timezone
from datetime import timedelta

User = get_user_model()

class TourIsBookedTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@example.com',
            password='password123',
            full_name='Test User'
        )
        self.client.force_authenticate(user=self.user)

        self.division = Division.objects.create(name="Test Division")
        self.transport = Transport.objects.create(name="Bus")
        self.stay = Stay.objects.create(name="Hotel")

        self.tour = Tour.objects.create(
            title="Test Tour",
            slug="test-tour",
            division=self.division,
            transport=self.transport,
            stay=self.stay,
            duration_days=2,
            duration_nights=1,
            total_cost=1000,
            upfront_payment=500,
            start_datetime=timezone.now() + timedelta(days=10),
            booking_deadline=timezone.now() + timedelta(days=5),
            meeting_point="Test Point",
            meeting_time="10:00:00",
        )

        self.tour_url = reverse('tour-detail', kwargs={'slug': self.tour.slug})
        self.list_url = reverse('tour-list')

    def test_is_booked_false_when_not_booked(self):
        # List view
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # assuming the tour is in the list
        tour_data = next(t for t in response.data['results'] if t['id'] == self.tour.id)
        self.assertFalse(tour_data['is_booked'])

        # Detail view
        response = self.client.get(self.tour_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['is_booked'])

    def test_is_booked_true_when_booked(self):
        TourBooking.objects.create(
            tour=self.tour,
            user=self.user,
            status='paid',
            seats=1
        )

        # List view
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        tour_data = next(t for t in response.data['results'] if t['id'] == self.tour.id)
        self.assertTrue(tour_data['is_booked'])

        # Detail view
        response = self.client.get(self.tour_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['is_booked'])

    def test_is_booked_false_for_anonymous_users(self):
        self.client.logout()

        # List view
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        tour_data = next(t for t in response.data['results'] if t['id'] == self.tour.id)
        self.assertFalse(tour_data['is_booked'])

        # Detail view
        response = self.client.get(self.tour_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['is_booked'])
