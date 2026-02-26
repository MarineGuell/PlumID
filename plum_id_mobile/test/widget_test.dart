import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plum_id_mobile/main.dart';
import 'package:plum_id_mobile/presentation/providers/providers.dart';

void main() {
  testWidgets('App compiles and runs without crashing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
        child: PlumIDApp(prefs: prefs),
      ),
    );

    // Verify app renders
    expect(find.byType(PlumIDApp), findsOneWidget);
  });
}
