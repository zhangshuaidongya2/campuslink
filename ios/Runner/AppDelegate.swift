import Flutter
import Network
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let deviceChannelName = "campuslink/device_info"
  private let networkChannelName = "campuslink/network_tools"
  private var localNetworkBrowser: NWBrowser?
  private var localNetworkCleanupWorkItem: DispatchWorkItem?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: deviceChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "getCurrentDevice" else {
          result(FlutterMethodNotImplemented)
          return
        }

        result(self?.buildCurrentDevicePayload() ?? [:])
      }

      let networkChannel = FlutterMethodChannel(
        name: networkChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      networkChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "requestLocalNetworkPermission" else {
          result(FlutterMethodNotImplemented)
          return
        }

        self?.startLocalNetworkProbe()
        result([
          "status": "started",
          "message": "已發起本地網路檢測；首次在真機上操作時，iOS 可能會顯示本地網路權限提示。"
        ])
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func buildCurrentDevicePayload() -> [String: Any] {
    let device = UIDevice.current
    let managedConfiguration =
      UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed") ?? [:]
    let normalizedManagedConfiguration = normalizePropertyList(managedConfiguration)
    let managedFlagValue =
      managedConfiguration["campus_managed"] ??
      managedConfiguration["is_managed"] ??
      managedConfiguration["managed"]

    let hasManagedConfiguration = !managedConfiguration.isEmpty
    let isManaged = parseManagedFlag(managedFlagValue) ?? hasManagedConfiguration

    return [
      "deviceName": device.name,
      "model": device.model,
      "localizedModel": device.localizedModel,
      "systemName": device.systemName,
      "systemVersion": device.systemVersion,
      "machineIdentifier": machineIdentifier(),
      "vendorIdentifier": device.identifierForVendor?.uuidString ?? "",
      "isManaged": isManaged,
      "managedConfiguration": normalizedManagedConfiguration,
    ]
  }

  private func parseManagedFlag(_ value: Any?) -> Bool? {
    switch value {
    case let boolValue as Bool:
      return boolValue
    case let numberValue as NSNumber:
      return numberValue.boolValue
    case let stringValue as String:
      switch stringValue.lowercased() {
      case "1", "true", "yes", "managed":
        return true
      case "0", "false", "no", "unmanaged":
        return false
      default:
        return nil
      }
    default:
      return nil
    }
  }

  private func normalizePropertyList(_ value: Any) -> Any {
    switch value {
    case let dictionary as [String: Any]:
      return dictionary.mapValues { normalizePropertyList($0) }
    case let array as [Any]:
      return array.map { normalizePropertyList($0) }
    case let string as String:
      return string
    case let number as NSNumber:
      return number
    case let data as Data:
      return data.base64EncodedString()
    case let date as Date:
      return ISO8601DateFormatter().string(from: date)
    default:
      return String(describing: value)
    }
  }

  private func machineIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)

    let mirror = Mirror(reflecting: systemInfo.machine)
    return mirror.children.reduce(into: "") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else {
        return
      }
      identifier.append(Character(UnicodeScalar(UInt8(value))))
    }
  }

  private func startLocalNetworkProbe() {
    localNetworkCleanupWorkItem?.cancel()
    localNetworkCleanupWorkItem = nil
    localNetworkBrowser?.cancel()
    localNetworkBrowser = nil

    let parameters = NWParameters.tcp
    parameters.includePeerToPeer = true

    let browser = NWBrowser(
      for: .bonjour(type: "_http._tcp", domain: nil),
      using: parameters
    )

    browser.stateUpdateHandler = { _ in }
    browser.browseResultsChangedHandler = { _, _ in }
    browser.start(queue: .main)
    localNetworkBrowser = browser

    let cleanup = DispatchWorkItem { [weak self] in
      self?.localNetworkBrowser?.cancel()
      self?.localNetworkBrowser = nil
      self?.localNetworkCleanupWorkItem = nil
    }

    localNetworkCleanupWorkItem = cleanup
    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: cleanup)
  }
}
