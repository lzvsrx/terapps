import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tera_assistente/main.dart';
import 'package:tera_assistente/state/app_state.dart';

void main() {
  testWidgets('app renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const TeraApp(),
      ),
    );
    expect(find.text('Entrar'), findsOneWidget);
  });
}
