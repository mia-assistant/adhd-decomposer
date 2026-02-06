import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_decomposer/data/services/ai_service.dart';

void main() {
  group('AIService', () {
    late AIService service;

    setUp(() {
      service = AIService();
    });

    group('DecompositionStyle', () {
      test('mock decomposition works with standard style', () async {
        final task = await service.decomposeTask(
          'Clean the kitchen',
          style: DecompositionStyle.standard,
        );

        expect(task.title, 'Clean the kitchen');
        expect(task.steps.length, greaterThanOrEqualTo(3));
        expect(task.steps.length, lessThanOrEqualTo(12));
      });

      test('mock decomposition works with quick style', () async {
        final task = await service.decomposeTask(
          'Clean the kitchen',
          style: DecompositionStyle.quick,
        );

        expect(task.title, 'Clean the kitchen');
        expect(task.steps.length, lessThanOrEqualTo(5));
      });

      test('mock decomposition works with gentle style', () async {
        final task = await service.decomposeTask(
          'Clean the kitchen',
          style: DecompositionStyle.gentle,
        );

        expect(task.title, 'Clean the kitchen');
        // Gentle mode should have encouraging emojis
        final hasEmoji = task.steps.any((step) => 
          step.action.contains('💭') || 
          step.action.contains('🌟') ||
          step.action.contains('✨') ||
          step.action.contains('🎉')
        );
        expect(hasEmoji, true);
      });
    });

    group('Task Type Detection', () {
      test('detects cleaning tasks', () async {
        final task = await service.decomposeTask('clean my room');
        expect(task.steps.isNotEmpty, true);
      });

      test('detects laundry tasks', () async {
        final task = await service.decomposeTask('do laundry');
        expect(task.steps.isNotEmpty, true);
        // Should have laundry-specific steps
        final hasLaundryStep = task.steps.any((s) => 
          s.action.toLowerCase().contains('wash') ||
          s.action.toLowerCase().contains('basket') ||
          s.action.toLowerCase().contains('dryer')
        );
        expect(hasLaundryStep, true);
      });

      test('detects email tasks', () async {
        final task = await service.decomposeTask('check my email inbox');
        expect(task.steps.isNotEmpty, true);
      });
    });

    group('getSubSteps', () {
      test('returns grounding steps when stuck', () async {
        final steps = await service.getSubSteps('Clean the counter', null);
        
        expect(steps.isNotEmpty, true);
        // Should start with grounding/easy steps
        final firstStep = steps.first.action.toLowerCase();
        expect(
          firstStep.contains('breath') || 
          firstStep.contains('look') ||
          firstStep.contains('stand'),
          true,
        );
      });
    });

    group('Time-aware context', () {
      test('accepts currentHour parameter', () async {
        // Morning hour
        final morningTask = await service.decomposeTask(
          'generic task',
          currentHour: 7,
        );
        expect(morningTask.steps.isNotEmpty, true);

        // Evening hour
        final eveningTask = await service.decomposeTask(
          'generic task',
          currentHour: 20,
        );
        expect(eveningTask.steps.isNotEmpty, true);
      });
    });
  });
}
