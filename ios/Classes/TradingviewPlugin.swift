import Flutter
import WebKit

class TradingviewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var views: [Int64: Tradingview] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let view = Tradingview(frame: frame, viewId: viewId, args: args, messenger: messenger)
        views[viewId] = view
        return view
    }

    func getView(forId viewId: Int64) -> Tradingview? {
        return views[viewId]
    }
}

class Tradingview: NSObject, FlutterPlatformView, WKNavigationDelegate {
    private var webView: WKWebView
    private var loadingIndicator: UIActivityIndicatorView
    private var symbol: String
    private var theme: String
    private var hideSideToolbar: Bool
    private var locale: String

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        webView = WKWebView(frame: frame)
        if #available(iOS 13.0, *) {
            loadingIndicator = UIActivityIndicatorView(style: .large)
        } else {
            loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        symbol = (args as? [String: Any])?["symbol"] as? String ?? "AAPL"
        theme = (args as? [String: Any])?["theme"] as? String ?? "light"
        hideSideToolbar = (args as? [String: Any])?["hide_side_toolbar"] as? Bool ?? false
        locale = (args as? [String: Any])?["locale"] as? String ?? "en"
        super.init()
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])

        loadChart()
    }

    func view() -> UIView {
        return webView
    }

    private func loadChart() {
        let htmlContent = """
        <!-- TradingView Widget BEGIN -->
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1.0">
            <title>TradingView</title>
            <style>
                html, body, .tradingview-widget-container {
                    width: 100%;
                    height: 100%;
                    margin: 0;
                    padding: 0;
                }
            </style>
        </head>
        <body>
            <div class="tradingview-widget-container">
                <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
                <script type="text/javascript">
                new TradingView.widget({
                    "autosize": true,
                    "symbol": "\(symbol)",
                    "interval": "D",
                    "timezone": "exchange",
                    "theme": "\(theme)",
                    "style": "1",
                    "hide_side_toolbar": \(hideSideToolbar),
                    "allow_symbol_change": false,
                    "save_image": false,
                    "show_popup_button": false,
                    "locale": "\(locale)",
                    "overrides": {
                        "paneProperties.background": "rgba(0, 0, 0, 0)",
                    }
                });
                </script>
            </div>
        </body>
        </html>
        <!-- TradingView Widget END -->
        """

        webView.loadHTMLString(htmlContent, baseURL: nil)
    }

    func updateChart(symbol: String?, theme: String?, hideSideToolbar: Bool?, locale: String?) {
        if let symbol = symbol {
            self.symbol = symbol
        }
        if let theme = theme {
            self.theme = theme
        }
        if let hideSideToolbar = hideSideToolbar {
            self.hideSideToolbar = hideSideToolbar
        }
        if let locale = locale {
            self.locale = locale
        }
        loadChart()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }
}

public class TradingviewPlugin: NSObject, FlutterPlugin {
    private var registrar: FlutterPluginRegistrar
    private var factory: TradingviewFactory

    init(registrar: FlutterPluginRegistrar, factory: TradingviewFactory) {
        self.registrar = registrar
        self.factory = factory
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tradingview", binaryMessenger: registrar.messenger())
        let factory = TradingviewFactory(messenger: registrar.messenger())
        let instance = TradingviewPlugin(registrar: registrar, factory: factory)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(factory, withId: "tradingview")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "updateChart" {
            if let args = call.arguments as? [String: Any], let viewId = args["viewId"] as? Int64 {
                let symbol = args["symbol"] as? String
                let theme = args["theme"] as? String
                let hideSideToolbar = args["hide_side_toolbar"] as? Bool
                let locale = args["locale"] as? String

                if let view = factory.getView(forId: viewId) {
                    view.updateChart(symbol: symbol, theme: theme, hideSideToolbar: hideSideToolbar, locale: locale)
                    result(nil)
                } else {
                    result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments for updateChart", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
