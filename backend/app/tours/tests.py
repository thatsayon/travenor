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
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check if results exist
        self.assertTrue(len(response.data['results']) > 0)
        tour_data = next(t for t in response.data['results'] if t['id'] == self.tour.id)
        self.assertFalse(tour_data.get('is_booked'))

        response = self.client.get(self.tour_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data.get('is_booked'))

    def test_is_booked_true_when_booked(self):
        TourBooking.objects.create(
            tour=self.tour,
            user=self.user,
            status='paid',
            seats=1
        )
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        tour_data = next(t for t in response.data['results'] if t['id'] == self.tour.id)
        self.assertTrue(tour_data.get('is_booked'))

        response = self.client.get(self.tour_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get('is_booked'))

    def test_is_booked_false_for_anonymous_users(self):
        self.client.logout()
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        tour_data = next(t for t in response.data['results'] if t['id'] == self.tour.id)
        # Should be absent or False
        self.assertFalse(tour_data.get('is_booked', False))

        response = self.client.get(self.tour_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data.get('is_booked', False))


class UpcomingToursTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='test2@example.com', password='pw')
        self.client.force_authenticate(user=self.user)
        self.division = Division.objects.create(name="Div")
        self.tour = Tour.objects.create(
            title="Future Tour",
            slug="future-tour",
            division=self.division,
            transport=Transport.objects.create(name="Bus"),
            stay=Stay.objects.create(name="H"),
            duration_days=1, duration_nights=0,
            total_cost=100, upfront_payment=50,
            start_datetime=timezone.now() + timedelta(days=5),
            booking_deadline=timezone.now() + timedelta(days=2),
            meeting_point="P", meeting_time="10:00",
            min_group_size=5
        )
        self.booking = TourBooking.objects.create(
            tour=self.tour, user=self.user, status='paid', seats=2
        )
        self.url = reverse('upcoming-tours')

    def test_upcoming_tour_fields(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data['results']), 1)
        
        data = response.data['results'][0]
        self.assertEqual(data['tour_slug'], self.tour.slug)
        self.assertEqual(data['min_group_size'], 5)
        self.assertIn("Waiting for 3 more people", data['message'])

    def test_pending_message(self):
        self.booking.status = 'pending'
        self.booking.save()
        response = self.client.get(self.url)
        data = response.data['results'][0]
        self.assertEqual(data['message'], "Your booking is pending approval.")
