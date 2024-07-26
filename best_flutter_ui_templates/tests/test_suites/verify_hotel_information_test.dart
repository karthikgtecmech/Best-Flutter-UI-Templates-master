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

    test('Verify Hotel Information', () async {
      try {
        await testUtils
            .click(find.byValueKey('assets/hotel/hotel_booking.png'));

        await testUtils.scroll(
          find.byType('HotelListView'),
          0.0,
          -3000.0,
          const Duration(milliseconds: 500),
        );
        await testUtils.verifyTextEquals(
            find.text('Queen Hotel'), 'Queen Hotel');
        await testUtils.verifyTextEquals(
            find.text('7.0 km to city'), '7.0 km to city');

        await testUtils.verifyTextEquals(
            find.text('Grand Royal Hotel'), 'Grand Royal Hotel');
        await testUtils.verifyTextEquals(
            find.text(' 240 Reviews'), ' 240 Reviews');

        print('Hotel Information verified successfully');
      } catch (e) {
        await testUtils.captureScreenshot('Hotel_Information_Test');
        rethrow;
      }
    });
  });
}
