import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Tradingview extends StatelessWidget {
  const Tradingview(
      {super.key,
      required this.symbol,
      required this.theme,
      required this.locale,
      required this.hideSideToolbar});
  final String symbol;
  final String theme;
  final String locale;
  final bool hideSideToolbar;
  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'tradingview',
      creationParams: {
        'symbol': symbol,
        'theme': theme,
        'locale': locale,
        'hide_side_toolbar': hideSideToolbar,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class ChartManager {
  static Future<void> update({
    required String symbol,
    required String theme,
    required bool hideSideToolbar,
    required String locale,
  }) async {
    const platform = MethodChannel('tradingview');
    await platform.invokeMethod('updateChart', {
      'symbol': symbol,
      'theme': theme,
      'hide_side_toolbar': hideSideToolbar,
      'locale': locale,
      'viewId': 0,
    });
  }
}
