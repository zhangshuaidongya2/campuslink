import 'package:campuslink/src/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the main campus workflow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('campuslink/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getCurrentDevice') {
            return <String, dynamic>{
              'deviceName': 'Test iPhone',
              'model': 'iPhone',
              'localizedModel': 'iPhone',
              'systemName': 'iOS',
              'systemVersion': '18.0',
              'machineIdentifier': 'iPhone16,2',
              'vendorIdentifier': 'TEST-DEVICE-0001',
              'isManaged': false,
              'managedConfiguration': <String, dynamic>{},
            };
          }
          return null;
        });

    await tester.pumpWidget(const CampusLinkApp());
    await tester.pumpAndSettle();

    expect(find.text('目前設備尚未納管'), findsOneWidget);
    expect(find.text('查看課程表'), findsOneWidget);

    await tester.tap(find.text('IT 服務'));
    await tester.pumpAndSettle();

    expect(find.text('設備報修與 IT 支援'), findsOneWidget);
    expect(find.text('接入管理后可提交'), findsOneWidget);

    await tester.tap(find.text('隱私政策'));
    await tester.pumpAndSettle();

    expect(find.text('隱私政策與資料邊界'), findsOneWidget);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
