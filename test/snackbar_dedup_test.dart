import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GlobalScaffold.showSnackBar replaces previous snackbar without queueing multiple bars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: messengerKey,
        home: const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
    );

    // Fire 4 rapid SnackBars in quick succession
    GlobalScaffold.showSnackBar('Alert 1');
    GlobalScaffold.showSnackBar('Alert 2');
    GlobalScaffold.showSnackBar('Alert 3');
    GlobalScaffold.showSnackBar('Alert 4');

    await tester.pump();

    // Verify only the latest SnackBar is active on screen
    expect(find.text('Alert 4'), findsOneWidget);
    expect(find.text('Alert 1'), findsNothing);
    expect(find.text('Alert 2'), findsNothing);
    expect(find.text('Alert 3'), findsNothing);
  });
}
