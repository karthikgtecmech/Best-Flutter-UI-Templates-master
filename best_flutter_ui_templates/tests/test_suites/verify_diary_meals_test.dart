import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'test_utils/testUtils.dart';

late FlutterDriver driver;
final testUtils = TestUtils(driver);

void main() {
  group('E2E Tests', () {
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test('Verify Diary Page - Meals', () async {
      try {
        await testUtils.scroll(
          find.byType('GridView'),
          0.0,
          -300.0,
          const Duration(milliseconds: 500),
        );
        await testUtils
            .click(find.byValueKey('assets/fitness_app/fitness_app.png'));

        await testUtils.verifyTextEquals(
            find.text('Mediterranean diet'), 'Mediterranean diet');
        await testUtils.verifyTextEquals(
            find.text('Body measurement'), 'Body measurement');
        await testUtils.verifyTextEquals(find.text('1127'), '1127');
        await testUtils.verifyTextEquals(find.text('102'), '102');
        await testUtils.verifyTextEquals(find.text('1503'), '1503');

        print('Diary Page Meals verified successfully');
      } catch (e) {
        await testUtils.captureScreenshot('Diary_Meals_Test');
        rethrow;
      }
    });
  });
}
