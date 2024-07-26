import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/expect.dart';

enum FinderType { byValueKey, byText }

class TestUtils {
  final FlutterDriver driver;

  TestUtils(this.driver);
  final SerializableFinder loadingIcon = find.text('loading...');

  Future<void> wait(int timeout, [String type = 'seconds']) async {
    try {
      switch (type) {
        case 'seconds':
          await Future.delayed(Duration(seconds: timeout));
          break;
        case 'minutes':
          await Future.delayed(Duration(minutes: timeout));
          break;
        default:
          throw Exception('Invalid type. Use "seconds" or "minutes".');
      }
    } catch (e) {
      throw Exception('Error occurred while waiting for $timeout $type');
    }
  }

  Future<void> waitForWidgetToPresent(SerializableFinder finder,
      {Duration timeout = const Duration(seconds: 25)}) async {
    try {
      await driver.waitUntilNoTransientCallbacks();
      await driver.waitFor(finder, timeout: timeout);
    } catch (e) {
      throw Exception('Error: Element not found within the specified timeout.');
    }
  }

  Future<void> waitForWidgetToDisappear(SerializableFinder finder,
      {Duration timeout = const Duration(seconds: 25)}) async {
    try {
      await driver.waitUntilNoTransientCallbacks();
      await driver.waitForAbsent(finder, timeout: timeout);
    } catch (e) {
      throw Exception(
          'Error: Element is still present within the specified timeout.');
    }
  }

  Future<bool> isElementExists(SerializableFinder finder,
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      await driver.waitUntilNoTransientCallbacks();
      await driver.waitFor(finder, timeout: timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> waitForWidgetToBeClickable(SerializableFinder finder,
      {Duration timeout = const Duration(seconds: 25)}) async {
    try {
      await driver.waitForTappable(finder, timeout: timeout);
    } catch (e) {
      throw Exception(
          'Error: Element not clickable within the specified timeout.');
    }
  }

  Future<String> getTextFromWidget(SerializableFinder finder) async {
    try {
      // await waitForWidgetToPresent(finder);
      return await driver.getText(finder);
    } catch (e) {
      throw Exception('Error getting text from element.');
    }
  }

  Future<void> enterTextInField(SerializableFinder finder, String text,
      {bool tap = true}) async {
    try {
      await waitForWidgetToPresent(finder);
      if (tap) await driver.tap(finder);
      await driver.enterText(text);
    } catch (e) {
      throw Exception('Error entering text: $text');
    }
  }

  Future<void> click(SerializableFinder finder) async {
    try {
      await waitForWidgetToPresent(finder);
      await waitForWidgetToBeClickable(finder);
      await driver.tap(finder);
    } catch (e) {
      throw Exception('Error clicking on element.');
    }
  }

  Future<void> scroll(SerializableFinder finder, double dx, double dy,
      Duration duration) async {
    try {
      print('Scrolling on widget...');
      await driver.scroll(finder, dx, dy, duration);
      print('Scroll action completed successfully.');
    } catch (e) {
      print('Error during scroll action: $e');
      throw Exception('Error during scroll action: $e');
    }
  }

  Future<void> clickOnDropdownItem(dynamic item, [dynamic finder]) async {
    final itemFinder = finder != null
        ? (finder is String ? find.byValueKey('$finder$item') : finder)
        : find.text(item);
    try {
      await click(itemFinder);
    } catch (e) {
      throw Exception('Error clicking on Dropdown Item: $item');
    }
  }

  Future<void> clickOnRadioButton(dynamic finder, [String? value]) async {
    final itemFinder = value != null
        ? find.byValueKey('$finder$value')
        : find.byValueKey(finder);
    try {
      await click(itemFinder);
    } catch (e) {
      throw Exception('Error clicking on Radio Button.');
    }
  }

  Future<void> dblClick(SerializableFinder finder) async {
    try {
      await click(finder);
      await Future.delayed(
          const Duration(milliseconds: 100)); // Delay between taps
      await driver.tap(finder);
    } catch (e) {
      throw Exception('Error double clicking on element.');
    }
  }

  Future<int> getLengthOfTheWidget(dynamic finder, int timeout) async {
    int index = 0;
    while (true) {
      try {
        final serializableFinder = getFinder(finder, index);
        await driver.waitFor(serializableFinder,
            timeout: Duration(seconds: timeout));
        index++;
      } catch (_) {
        break;
      }
    }
    return index;
  }

  SerializableFinder getFinder(dynamic finder, int index) {
    if (finder is String) {
      return find.byValueKey('$finder$index');
    } else if (finder is SerializableFinder) {
      return finder;
    } else {
      throw Exception('Invalid finder type');
    }
  }

  Future<void> verifyTextEquals(SerializableFinder finder, String expectedText,
      {bool caseSensitive = false}) async {
    try {
      final actualText = await getTextFromWidget(finder);
      final actualCheckText =
          caseSensitive ? actualText : actualText.toLowerCase();
      final expectedCheckText =
          caseSensitive ? expectedText : expectedText.toLowerCase();
      expect(actualCheckText, expectedCheckText,
          reason:
              'Expected text to ${caseSensitive ? '' : 'case-insensitively '}equals "$expectedText", but found "$actualText"');
    } catch (e) {
      throw Exception('Error verifying text $expectedText from element.');
    }
  }

  Future<void> verifyTextContains(
      SerializableFinder finder, String expectedText,
      {bool caseSensitive = false}) async {
    try {
      final actualText = await getTextFromWidget(finder);
      final actualCheckText =
          caseSensitive ? actualText : actualText.toLowerCase();
      final expectedCheckText =
          caseSensitive ? expectedText : expectedText.toLowerCase();

      expect(actualCheckText, contains(expectedCheckText),
          reason:
              'Expected text to ${caseSensitive ? '' : 'case-insensitively '}contain "$expectedText", but found "$actualText"');
    } catch (e) {
      throw Exception('Error verifying text $expectedText from element.');
    }
  }

  Future<void> verifyTextStartsWith(
      SerializableFinder finder, String expectedPrefix,
      {bool caseSensitive = false}) async {
    try {
      final actualText = await getTextFromWidget(finder);

      final startsWithCheck = caseSensitive
          ? actualText.startsWith(expectedPrefix)
          : actualText.toLowerCase().startsWith(expectedPrefix.toLowerCase());

      expect(
        startsWithCheck,
        isTrue,
        reason:
            'Expected text to ${caseSensitive ? '' : 'case-insensitively '}start with "$expectedPrefix", but found "$actualText"',
      );
    } catch (e) {
      throw Exception('Error verifying text $expectedPrefix from element.');
    }
  }

  Future<void> verifyTextEndsWith(
      SerializableFinder finder, String expectedSuffix,
      {bool caseSensitive = false}) async {
    try {
      final actualText = await getTextFromWidget(finder);

      final endsWithCheck = caseSensitive
          ? actualText.endsWith(expectedSuffix)
          : actualText.toLowerCase().endsWith(expectedSuffix.toLowerCase());

      expect(
        endsWithCheck,
        isTrue,
        reason:
            'Expected text to ${caseSensitive ? '' : 'case-insensitively '}end with "$expectedSuffix", but found "$actualText"',
      );
    } catch (e) {
      throw Exception('Error verifying text $expectedSuffix from element.');
    }
  }

  Future<void> verifyListOfWidgetEquals(String finder, dynamic expectedText,
      {bool caseSensitive = false}) async {
    final widgetLength = expectedText is List
        ? expectedText.length
        : await getLengthOfTheWidget(finder, 5);

    if (widgetLength == 0) {
      throw Exception('Error: No elements found to verify $expectedText');
    }

    try {
      for (var index = 0; index < widgetLength; index++) {
        final textToVerify =
            expectedText is List ? expectedText[index] : expectedText as String;
        final finderToVerify = expectedText is List
            ? '$finder${expectedText[index]}'
            : '$finder$index';
        await verifyTextEquals(find.byValueKey(finderToVerify), textToVerify,
            caseSensitive: caseSensitive);
      }
    } catch (e) {
      throw Exception('Error verifying list of widget equals: $expectedText');
    }
  }

  Future<void> verifyListOfWidgetContains(String finder, String expectedText,
      {bool caseSensitive = false}) async {
    final widgetLength = await getLengthOfTheWidget(finder, 5);
    if (widgetLength == 0) {
      throw Exception('Error: No elements found to verify $expectedText');
    }
    try {
      for (var index = 0; index < widgetLength; index++) {
        await verifyTextContains(find.byValueKey('$finder$index'), expectedText,
            caseSensitive: caseSensitive);
      }
    } catch (e) {
      throw Exception('Error verifying list of widget contains: $expectedText');
    }
  }

  Future<void> verifyListOfWidgetStartsWith(String finder, String expectedText,
      {bool caseSensitive = false}) async {
    final widgetLength = await getLengthOfTheWidget(finder, 5);
    if (widgetLength == 0) {
      throw Exception('Error: No elements found to verify $expectedText');
    }
    try {
      for (var index = 0; index < widgetLength; index++) {
        await verifyTextStartsWith(
            find.byValueKey('$finder$index'), expectedText,
            caseSensitive: caseSensitive);
      }
    } catch (e) {
      throw Exception(
          'Error verifying list of widget starts with: $expectedText');
    }
  }

  Future<void> verifyListOfWidgetEndsWith(String finder, String expectedText,
      {bool caseSensitive = false}) async {
    final widgetLength = await getLengthOfTheWidget(finder, 5);
    if (widgetLength == 0) {
      throw Exception('Error: No elements found to verify $expectedText');
    }
    try {
      for (var index = 0; index < widgetLength; index++) {
        await verifyTextEndsWith(find.byValueKey('$finder$index'), expectedText,
            caseSensitive: caseSensitive);
      }
    } catch (e) {
      throw Exception(
          'Error verifying list of widget ends with: $expectedText');
    }
  }

  Future<void> captureScreenshot(String testName) async {
    try {
      await File('tests/test_suites/test_report/screenshots/$testName.png')
          .writeAsBytes(await driver.screenshot());
    } catch (e) {
      throw Exception('Failed to capture screenshot for the test: $testName');
    }
  }
}
