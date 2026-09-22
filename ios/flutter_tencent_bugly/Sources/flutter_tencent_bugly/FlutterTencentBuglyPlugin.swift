import Bugly
import Flutter
import UIKit

// SwiftPM 下桥接层为独立 module；CocoaPods 下它与本文件同 module，无需 import。
#if canImport(BuglyLogBridge)
    import BuglyLogBridge
#endif

public class FlutterTencentBuglyPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tencent_bugly", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(FlutterTencentBuglyPlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "init":
            initialize(arguments, result: result)
        case "setUserId":
            setUserId(arguments, result: result)
        case "setUserTag":
            setUserTag(arguments, result: result)
        case "setDeviceID":
            setDeviceID(arguments, result: result)
        case "setVersion":
            setVersion(arguments, result: result)
        case "putUserData":
            putUserData(arguments, result: result)
        case "postException":
            postException(arguments, result: result)
        case "log":
            log(arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// 初始化 Bugly
    ///
    /// 合规要求（见《开发者合规指南》）：请务必在用户授权《隐私政策》后再调用本方法；
    /// 建议通过 deviceId 参数设置业务唯一 id，使 crash 率统计更精准。
    private func initialize(_ arguments: [String: Any], result: FlutterResult) {
        guard let appId = arguments.nonBlankString("appId") else {
            result(jsonString(["message": "Bugly appId不能为空", "isSuccess": false]))
            return
        }

        let config = BuglyConfig(appId: appId, appKey: "")
        
        config.debugMode = arguments.bool("isDebugMode")
        config.development = arguments.bool("isDevelopmentDevice")
        if let channel = arguments.nonBlankString("channel") { config.channel = channel }
        if let version = arguments.nonBlankString("version") { config.version = version }
        if let deviceId = arguments.nonBlankString("deviceId") { config.deviceIdentifier = deviceId }
        config.blockMonitorEnable = arguments.bool("blockMonitorEnable")
        if let blockMonitorTimeout = arguments["blockMonitorTimeout"] as? NSNumber { config.blockMonitorTimeout = blockMonitorTimeout.doubleValue }
        config.blockReportImmediately = arguments.bool("blockReportImmediately")
        config.crashMonitorEnable = arguments.bool("crashMonitorEnable")
        config.blockCountMonitorEnable = arguments.bool("blockCountMonitorEnable")
        config.blockReportCallStackEnable = arguments.bool("blockReportCallStackEnable")
        if let symbolicateInProcessEnable = arguments.optionalBool("symbolicateInProcessEnable") { config.symbolicateInProcessEnable = symbolicateInProcessEnable }
        config.unexpectedTerminatingDetectionEnable = arguments.bool("unexpectedTerminatingDetectionEnable")
        if let viewControllerTrackingEnable = arguments.optionalBool("viewControllerTrackingEnable") { config.viewControllerTrackingEnable = viewControllerTrackingEnable }
        if let reportLogLevel = arguments["reportLogLevel"] as? NSNumber { config.reportLogLevel = BuglyLogLevel(rawValue: reportLogLevel.uintValue) ?? .silent }

        Bugly.start(with: config)
        if config.debugMode {
            NSLog("Bugly appId: %@", appId)
        }
        result(jsonString(["message": "Bugly 初始化成功", "appId": appId, "isSuccess": true]))
    }

    /// 设置用户ID
    private func setUserId(_ arguments: [String: Any], result: FlutterResult) {
        if let value = arguments.nonBlankString("value") { Bugly.updateUserIdentifier(value) }
        result(true)
    }

    /// 设置用户标签
    private func setUserTag(_ arguments: [String: Any], result: FlutterResult) {
        if let value = arguments["value"] as? NSNumber { Bugly.setTag(value.uintValue) }
        result(true)
    }

    /// 设置设备ID
    private func setDeviceID(_ arguments: [String: Any], result: FlutterResult) {
        if let value = arguments.nonBlankString("value") { Bugly.updateDeviceIdentifier(value) }
        result(true)
    }

    /// 设置版本号
    private func setVersion(_ arguments: [String: Any], result: FlutterResult) {
        if let value = arguments.nonBlankString("value") { Bugly.updateAppVersion(value) }
        result(true)
    }

    /// 设置自定义的 Key-Value 数据，发生 Crash 时随之上报
    private func putUserData(_ arguments: [String: Any], result: FlutterResult) {
        if let key = arguments.nonBlankString("key"), let value = arguments.nonBlankString("value") { Bugly.setUserValue(value, forKey: key) }
        result(true)
    }

    /// 上报自定义异常
    private func postException(_ arguments: [String: Any], result: FlutterResult) {
        let detail = arguments["detail"] as? String
        let message = detail.isBlankOrNil ? "" : (arguments["message"] as? String ?? "")
        let type = arguments.nonBlankString("type") ?? message

        Bugly.reportException(
            withCategory: 5,
            name: type,
            reason: message,
            callStack: detail?.components(separatedBy: "") ?? [],
            extraInfo: arguments["data"] as? [String: Any] ?? [:],
            terminateApp: false
        )
        result(true)
    }

    /// 输出 Bugly 日志，发生 Crash 时随之上报（上报级别由 BuglyConfig.reportLogLevel 控制）
    ///
    /// - 参数 `level`：日志级别，对应 BuglyLogLevel（0~5），缺失或越界时按 Silent 处理
    /// - 参数 `tag`：日志标签，可选
    /// - 参数 `message`：日志内容，需为已格式化的纯字符串
    private func log(_ arguments: [String: Any], result: FlutterResult) {
        let level = (arguments["level"] as? NSNumber).flatMap { BuglyLogLevel(rawValue: $0.uintValue) } ?? .silent
        let message = arguments["message"] as? String ?? ""
        BuglyLogBridge.log(with: level, tag: arguments.nonBlankString("tag"), message: message)
        result(nil)
    }

    /// 将字典序列化为 JSON 字符串
    private func jsonString(_ dict: [String: Any]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

private extension [String: Any] {
    /// 读取字符串参数，缺失或空白时返回 nil
    func nonBlankString(_ key: String) -> String? {
        guard let value = self[key] as? String, !value.isBlank else { return nil }
        return value
    }

    /// 读取布尔参数，缺失时返回 false
    func bool(_ key: String) -> Bool {
        (self[key] as? Bool) ?? false
    }

    /// 读取布尔参数，缺失时返回 nil
    func optionalBool(_ key: String) -> Bool? {
        self[key] as? Bool
    }
}

private extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespaces).isEmpty
    }
}

private extension String? {
    var isBlankOrNil: Bool {
        self?.isBlank ?? true
    }
}
