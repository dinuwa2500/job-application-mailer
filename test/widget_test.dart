import 'package:flutter_test/flutter_test.dart';
import 'package:email_sender/main.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApplicationMailerApp());
    expect(find.text('Job Application Mailer'), findsOneWidget);
  });
}
