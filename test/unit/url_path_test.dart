import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/network/urls.dart';

void main() {
  const emulatorBase = 'http://10.0.2.2:8080/';

  test('stripApiBasePrefix removes duplicated emulator host', () {
    const doubled = 'http://10.0.2.2:8080/recycleorigin/v1/driver/route/today';
    expect(
      stripApiBasePrefix(doubled, emulatorBase),
      'recycleorigin/v1/driver/route/today',
    );
  });

  test('stripApiBasePrefix unwraps a host nested in the path', () {
    const nested =
        'http://10.0.2.2:8080/http://10.0.2.2:8080/recycleorigin/v1/driver/route/today';
    expect(
      stripApiBasePrefix(nested, emulatorBase),
      'recycleorigin/v1/driver/route/today',
    );
  });

  test('stripApiBasePrefix leaves Dio-relative route paths unchanged', () {
    expect(
      stripApiBasePrefix(Urls.driverRouteToday, emulatorBase),
      'recycleorigin/v1/driver/route/today',
    );
  });

  test('stripApiBasePrefix keeps a different origin as an absolute URL', () {
    const other = 'https://api.example.com/recycleorigin/v1/driver/route/today';
    expect(stripApiBasePrefix(other, emulatorBase), other);
  });

  test('driver route paths do not include the API host', () {
    expect(Urls.driverRouteToday, isNot(contains('http://')));
    expect(Urls.driverRouteRebuild, isNot(contains('http://')));
    expect(Urls.driverLocation, isNot(contains('http://')));
    expect(
      Urls.driverRouteStopAction(9, 'completed'),
      isNot(contains('http://')),
    );
  });
}
