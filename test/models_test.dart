import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/data/models/task_model.dart';

void main() {
  group('Freezed TaskModel Tests', () {
    test('instantiates with defaults and converts to/from JSON correctly', () {
      const task = TaskModel(
        jobId: 'job_001',
        location: '123 Test St',
        faultReason: 'Broken pipe',
        toolsRequired: ['Wrench', 'Pliers'],
        rectifySteps: ['Shut off valve', 'Replace seal'],
        checklistItems: ['Check leaks'],
        timeSpent: Duration(minutes: 45),
        customerId: 'cust_999',
        locationType: 'home',
        latitude: 12.9716,
        longitude: 77.5946,
      );

      final json = task.toJson();
      expect(json['jobId'], equals('job_001'));
      expect(json['timeSpentSeconds'], equals(2700));

      final fromJson = TaskModel.fromJson(json);
      expect(fromJson.jobId, equals('job_001'));
      expect(fromJson.timeSpent, equals(const Duration(minutes: 45)));
      expect(fromJson.toolsRequired, contains('Wrench'));
      expect(fromJson.latitude, equals(12.9716));
    });

    test('copyWith updates fields immutably', () {
      const task = TaskModel(
        jobId: 'job_001',
        location: 'Location A',
        faultReason: 'Reason A',
      );

      final updated = task.copyWith(location: 'Location B');
      expect(updated.location, equals('Location B'));
      expect(updated.jobId, equals('job_001'));
      expect(task.location, equals('Location A'));
    });
  });

  group('Freezed Job Model Tests', () {
    test('fromJson handles flat standard JSON', () {
      final json = {
        'id': 'job_123',
        'title': 'AC Servicing',
        'description': 'Deep cleaning needed',
        'location': 'Koramangala, Bangalore',
        'status': 'pending',
        'totalAmount': 599.0,
        'createdAt': '2026-08-30T10:00:00.000Z',
      };

      final job = Job.fromJson(json);
      expect(job.id, equals('job_123'));
      expect(job.title, equals('AC Servicing'));
      expect(job.totalAmount, equals(599.0));
      expect(job.status, equals('pending'));
      expect(job.isExclusive, isFalse);
    });

    test('fromJson normalizes complex nested backend responses', () {
      final complexBackendJson = {
        'bookingId': {
          '_id': 'booking_999',
          'serviceName': 'Plumbing Repair',
          'description': 'Fix kitchen sink leak',
          'bookingStatus': 'confirmed',
          'totalAmount': '750.50',
          'addressSnapshot': {
            'name': 'John Doe',
            'phone': '+919876543210',
            'addressLine': 'Flat 402, Sunshine Heights',
            'city': 'Bengaluru',
            'state': 'Karnataka',
            'pincode': '560034',
          },
          'location': {
            'coordinates': [77.5946, 12.9716],
          },
        },
        'createdAt': '2026-08-30T12:00:00.000Z',
      };

      final job = Job.fromJson(complexBackendJson);
      expect(job.id, equals('booking_999'));
      expect(job.title, equals('Plumbing Repair'));
      expect(job.customerName, equals('John Doe'));
      expect(job.customerPhone, equals('+919876543210'));
      expect(job.location, contains('Flat 402'));
      expect(job.location, contains('Bengaluru'));
      expect(job.longitude, equals(77.5946));
      expect(job.latitude, equals(12.9716));
      expect(job.totalAmount, equals(750.50));
      expect(job.status, equals('confirmed'));
    });

    test('toJson produces expected structure and copyWith updates correctly', () {
      final job = Job(
        id: 'job_456',
        title: 'Electrical Repair',
        description: 'Wiring check',
        location: 'Indiranagar',
        status: 'in_progress',
        createdAt: DateTime.parse('2026-08-30T10:00:00.000Z'),
      );

      final json = job.toJson();
      expect(json['id'], equals('job_456'));
      expect(json['title'], equals('Electrical Repair'));

      final completed = job.copyWith(status: 'completed');
      expect(completed.status, equals('completed'));
      expect(job.status, equals('in_progress'));
    });
  });
}
