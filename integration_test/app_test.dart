import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tests the main user flow: registration, lesson quiz, budget, profile, and home navigation.
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (tester.any(finder)) {
      return;
    }
  }

  expect(finder, findsOneWidget);
}

Future<void> _tapWhenFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  await _pumpUntilFound(tester, finder, timeout: timeout);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can complete the main app flow', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final randomPhone =
        '9${(DateTime.now().millisecondsSinceEpoch % 1000000000).toString().padLeft(9, '0')}';

    app.main();
    await _pumpUntilFound(tester, find.text('Enter your phone number'));

    await tester.enterText(find.byKey(const Key('phoneField')), randomPhone);
    await tester.tap(find.byKey(const Key('continueButton')));

    await _pumpUntilFound(tester, find.text('What is a Budget?'));
    await _tapWhenFound(tester, find.text('What is a Budget?'));

    await _pumpUntilFound(tester, find.text('Choose your response'));

    final dialogueChoices = [
      "I have no money left and it's only the 20th!",
      'No, I just buy what we need',
      'Around 8,000 Rs',
      'About 5,500 Rs I think',
      "I can't believe I never did this before!",
    ];

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));

      final startQuizButton = find.textContaining('Start Quiz');
      if (tester.any(startQuizButton)) {
        break;
      }

      for (final choice in dialogueChoices) {
        final choiceFinder = find.text(choice);
        if (tester.any(choiceFinder)) {
          await tester.tap(choiceFinder);
          await tester.pump(const Duration(milliseconds: 900));
          break;
        }
      }
    }

    await _tapWhenFound(tester, find.textContaining('Start Quiz'));
    await _pumpUntilFound(tester, find.textContaining('Q1.'));

    for (var question = 0; question < 3; question++) {
      await _tapWhenFound(tester, find.text('A'));
      await _tapWhenFound(tester, find.text('Check Answer'));

      if (question == 2) {
        await _tapWhenFound(tester, find.text('Finish Quiz'));
      } else {
        await _tapWhenFound(tester, find.text('Continue'));
      }
    }

    await _pumpUntilFound(tester, find.text('Congratulations!'));
    await _tapWhenFound(tester, find.text('Back to Roadmap'));

    await _pumpUntilFound(tester, find.text('FinLit India'));

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await _pumpUntilFound(tester, find.text('Budget Management'));
    expect(find.textContaining('Monthly Income'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await _pumpUntilFound(tester, find.text('My Profile'));
    expect(find.text(randomPhone), findsOneWidget);
    expect(find.text('Lessons Completed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await _pumpUntilFound(tester, find.text('FinLit India'));
  });
}
