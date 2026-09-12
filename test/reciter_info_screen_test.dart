import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/constants/app_constants.dart';
import 'package:rattil/features/reciter/screens/reciter_info_screen.dart';

void main() {
  testWidgets('ReciterInfoScreen renders reciter info and all 5 cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReciterInfoScreen(),
      ),
    );

    // Verify reciter name and bio
    expect(find.text(AppConstants.reciterName), findsWidgets);
    expect(find.text(AppConstants.reciterBio), findsOneWidget);
    expect(find.text('نبذة مختصرة'), findsOneWidget);

    // Verify all 5 cards
    expect(find.text('المنطقة'), findsOneWidget);
    expect(find.text('حضرموت / المكلا / روكب'), findsOneWidget);

    expect(find.text('الجامعة'), findsOneWidget);
    expect(
      find.text('جامعة القرآن الكريم والعلوم الإسلامية بالمكلا'),
      findsOneWidget,
    );

    expect(find.text('التخصص'), findsOneWidget);
    expect(find.text('التجويد التطبيقي للقرآن'), findsOneWidget);

    expect(find.text('المحتوى'), findsOneWidget);
    expect(find.text('جزء عمّ'), findsOneWidget);

    expect(find.text('المركز'), findsOneWidget);
    expect(find.text(AppConstants.reciterCenter), findsOneWidget);
  });
}
