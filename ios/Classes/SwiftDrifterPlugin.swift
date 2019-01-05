import Flutter
import UIKit
import AdSupport

public class SwiftDrifterPlugin: NSObject, FlutterPlugin {
    var debug: Bool = false;

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "me.wener.drifter", binaryMessenger: registrar.messenger())
        let instance = SwiftDrifterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "debug":
            result(debug);
            if let m = call.arguments as? Dictionary<String, Any?> {
                if let v = m["debug"] as? Bool {
                    debug = v;
                }
            }
        case "generateRandomUuid":
            result(UUID().uuidString);
        case "getIdfa":
            result(getIdfa())
        case "getIdfv":
            result(UIDevice.current.identifierForVendor?.uuidString)
        default:
            result(nil)
        }
    }

    func getIdfa() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}
