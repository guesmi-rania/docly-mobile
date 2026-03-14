import 'package:flutter_test/flutter_test.dart';
import 'package:docly/main.dart';

void main() {
  testWidgets('Docly app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DoclyApp());
  });
}