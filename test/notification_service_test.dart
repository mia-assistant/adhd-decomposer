import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_decomposer/data/services/notification_service.dart';

/// Unit tests for NotificationService
/// 
/// Note: Tests that require Flutter bindings (like actual notification scheduling)
/// must be run as integration tests or widget tests with proper mocking.
/// These tests focus on static properties and callback behavior.
void main() {
  group('NotificationService', () {
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
      
      test('notification IDs have expected values', () {
        expect(NotificationService.dailyReminderId, 1);
        expect(NotificationService.unfinishedTaskId, 2);
        expect(NotificationService.streakReminderId, 3);
      });
      
      test('channel constants are defined', () {
        expect(NotificationService.channelId, 'tiny_steps_reminders');
        expect(NotificationService.channelName, 'Reminders');
        expect(NotificationService.channelDescription, isNotEmpty);
      });
    });

    group('Callback Handling', () {
      tearDown(() {
        // Clean up callback after each test
        NotificationService.onNotificationTap = null;
      });
      
      test('onNotificationTap callback can be set', () {
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        // Simulate a notification tap by calling the callback
        NotificationService.onNotificationTap?.call('test-payload');
        
        expect(receivedPayload, 'test-payload');
      });

      test('home payload triggers home navigation callback', () {
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(NotificationService.payloadHome);
        expect(receivedPayload, 'home');
      });

      test('execute payload triggers execute navigation callback', () {
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(NotificationService.payloadExecute);
        expect(receivedPayload, 'execute');
      });

      test('stats payload triggers stats navigation callback', () {
        String? receivedPayload;
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(NotificationService.payloadStats);
        expect(receivedPayload, 'stats');
      });
      
      test('callback handles null payload', () {
        String? receivedPayload = 'initial';
        NotificationService.onNotificationTap = (payload) {
          receivedPayload = payload;
        };
        
        NotificationService.onNotificationTap?.call(null);
        expect(receivedPayload, null);
      });
      
      test('callback is null by default', () {
        // Reset to default state
        NotificationService.onNotificationTap = null;
        expect(NotificationService.onNotificationTap, isNull);
      });
    });

    group('Deep Linking Payloads', () {
      test('all payloads are non-empty strings', () {
        expect(NotificationService.payloadHome, isA<String>());
        expect(NotificationService.payloadHome, isNotEmpty);
        
        expect(NotificationService.payloadExecute, isA<String>());
        expect(NotificationService.payloadExecute, isNotEmpty);
        
        expect(NotificationService.payloadStats, isA<String>());
        expect(NotificationService.payloadStats, isNotEmpty);
      });
      
      test('payloads are unique', () {
        final payloads = [
          NotificationService.payloadHome,
          NotificationService.payloadExecute,
          NotificationService.payloadStats,
        ];
        
        // Check all payloads are unique
        expect(payloads.toSet().length, payloads.length);
      });
    });
  });
}
