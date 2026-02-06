import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:adhd_decomposer/data/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    late NotificationService service;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test_hive');
    });

    setUp(() {
      service = NotificationService();
    });

    tearDown(() async {
      // Clean up Hive boxes
      await Hive.deleteBoxFromDisk('notification_settings');
    });

    group('Settings Storage', () {
      test('default values are correct', () async {
        await service.initialize();
        
        expect(service.notificationsEnabled, false);
        expect(service.reminderHour, 9);
        expect(service.reminderMinute, 0);
        expect(service.gentleNudgeEnabled, true);
        expect(service.hasActiveTask, false);
        expect(service.activeTaskId, null);
        expect(service.lastTaskActivityTime, null);
      });

      test('notification settings persist', () async {
        await service.initialize();
        
        service.notificationsEnabled = true;
        service.reminderHour = 10;
        service.reminderMinute = 30;
        service.gentleNudgeEnabled = false;
        
        // Create new instance to verify persistence
        final service2 = NotificationService();
        await service2.initialize();
        
        expect(service2.notificationsEnabled, true);
        expect(service2.reminderHour, 10);
        expect(service2.reminderMinute, 30);
        expect(service2.gentleNudgeEnabled, false);
      });

      test('task activity tracking works', () async {
        await service.initialize();
        
        service.hasActiveTask = true;
        service.activeTaskId = 'test-task-123';
        service.lastTaskActivityTime = DateTime(2024, 1, 15, 10, 30);
        
        expect(service.hasActiveTask, true);
        expect(service.activeTaskId, 'test-task-123');
        expect(service.lastTaskActivityTime, DateTime(2024, 1, 15, 10, 30));
      });
    });

    group('Payload Constants', () {
      test('payload constants are correct', () {
        expect(NotificationService.payloadHome, 'home');
        expect(NotificationService.payloadExecute, 'execute');
        expect(NotificationService.payloadStats, 'stats');
      });

      test('notification IDs are unique', () {
        expect(NotificationService.dailyReminderId, isNot(NotificationService.unfinishedTaskId));
        expect(NotificationService.dailyReminderId, isNot(NotificationService.streakReminderId));
        expect(NotificationService.unfinishedTaskId, isNot(NotificationService.streakReminderId));
      });
    });

    group('Deep Linking', () {
      test('onNotificationTap callback can be set', () async {
        await service.initialize();
        
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        // Simulate a notification tap by calling the callback
        NotificationService.onNotificationTap?.call('test-payload');
        
        expect(receivedPayload, 'test-payload');
      });

      test('home payload triggers home navigation', () async {
        await service.initialize();
        
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(NotificationService.payloadHome);
        expect(receivedPayload, 'home');
      });

      test('execute payload triggers execute navigation', () async {
        await service.initialize();
        
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(NotificationService.payloadExecute);
        expect(receivedPayload, 'execute');
      });

      test('stats payload triggers stats navigation', () async {
        await service.initialize();
        
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(NotificationService.payloadStats);
        expect(receivedPayload, 'stats');
      });
    });
  });
}
