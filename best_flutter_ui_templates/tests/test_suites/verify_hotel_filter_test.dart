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

    test('Verify Hotel Filter', () async {
      try {
        await testUtils
            .click(find.byValueKey('assets/hotel/hotel_booking.png'));

        await testUtils.click(find.text('Filter'));
        await testUtils.click(find.text('Free Breakfast'));
        await testUtils.click(find.text('Free Parking'));
        await testUtils.click(find.text('Apply'));

        await testUtils.verifyTextEquals(
            find.text('Grand Royal Hotel'), 'Grand Royal Hotel');

        print('Hotel Filter verified successfully');
      } catch (e) {
        await testUtils.captureScreenshot('Hotel_Filter');
        rethrow;
      }
    });
  });
}
