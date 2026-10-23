import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/screens/job_map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('JobMapScreen initializes and disposes cleanly without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: JobMapScreen(
          latitude: 12.9716,
          longitude: 77.5946,
          title: 'AC Service Map',
        ),
      ),
    );

    expect(find.text('AC Service Map'), findsOneWidget);
    expect(find.text('Start Navigation'), findsOneWidget);

    // Unmount widget immediately to verify clean dispose without controller exceptions
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Next Screen'))));
    expect(find.text('Next Screen'), findsOneWidget);
    expect(find.text('AC Service Map'), findsNothing);
  });
}
