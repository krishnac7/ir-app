import 'package:flutter_test/flutter_test.dart';
import 'package:ir_app/main.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const IRApp());
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
  });
}
