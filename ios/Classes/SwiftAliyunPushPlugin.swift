import Flutter
import UIKit
import CloudPushSDK

public class SwiftAliyunPushPlugin: NSObject, FlutterPlugin {
    
    private let _channel: FlutterMethodChannel
    
    public init(_ channel: FlutterMethodChannel) {
        _channel = channel;
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "aliyun_push", binaryMessenger: registrar.messenger())
        let instance = SwiftAliyunPushPlugin(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "Missing args!", message: "Unable to convert args to [String : Any]", details: nil))
                return
            }
            let appKey = args["appKey"] as? String ?? ""
            let appSecret = args["appSecret"] as? String ?? ""
            CloudPushSDK.asyncInit(appKey, appSecret: appSecret) { (res) in
                if res?.error != nil {
                    result(FlutterError(code: "初始化失败", message: res?.error?.localizedDescription ?? "", details: nil))
                }
            }
            break
        case "bindTag":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "Missing args!", message: "Unable to convert args to [String : Any]", details: nil))
                return
            }
            let tags = args["tags"] as? [String] ?? []
            let type = args["type"] as? NSNumber ?? NSNumber.init(value: 1);
            let alias = args["alias"] as? String ?? ""
            CloudPushSDK.bindTag(type.int32Value, withTags: tags, withAlias: alias) { (res) in
                if res?.error != nil {
                    result(FlutterError(code: "打标签失败", message: res?.error?.localizedDescription ?? "", details: nil))
                }
            }
            break
        case "unbindTag":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "Missing args!", message: "Unable to convert args to [String : Any]", details: nil))
                return
            }
            let tags = args["tags"] as? [String] ?? []
            let type = args["type"] as? NSNumber ?? NSNumber.init(value: 1);
            let alias = args["alias"] as? String ?? ""
            CloudPushSDK.unbindTag(type.int32Value, withTags: tags, withAlias: alias) { (res) in
                if res?.error != nil {
                    result(FlutterError(code: "删除标签失败", message: res?.error?.localizedDescription ?? "", details: nil))
                }
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    func registerAPNS(_ application: UIApplication) -> Void {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert , .badge , .sound] , categories: nil))
        application.registerForRemoteNotifications();
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageReceived), name: NSNotification.Name(rawValue: "CCPDidReceiveMessageNotification"), object: nil)
    }
    
    @objc func onMessageReceived(notification: Notification) -> Void {
        let message: CCPSysMessage = notification.object as! CCPSysMessage
        let tit = String.init(data: message.title, encoding: .utf8)
        let bod = String.init(data: message.body, encoding: .utf8)
        _channel.invokeMethod("onCCPMessage", arguments: ["title": tit, "body": bod])
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        registerAPNS(application)
        CloudPushSDK.sendNotificationAck(launchOptions)
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CloudPushSDK.registerDevice(deviceToken) { (res) in
            if res?.success ?? false {
                print("deviceToken 注册成功")
            } else {
                print("deviceToken 注册失败: \(res?.error?.toString() ?? "")")
            }
        }
        let deviceId = CloudPushSDK.getDeviceId();
        _channel.invokeMethod("onDeviceId", arguments: deviceId)
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("通知栏推送")
        let aps = response.notification.request.content
        var result: [String:Any] = [:]
        let body = aps.body
        let badge = aps.badge as? Int ?? 0
        let title = aps.title
        UIApplication.shared.applicationIconBadgeNumber = 0;
        result["body"] = body
        result["badge"] = badge
        result["title"] = title
        result["silent"] = false
        _channel.invokeMethod("onReceived", arguments: result)
        return completionHandler()
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("静默推送")
        let aps = notification.request.content
        var result: [String:Any] = [:]
        let body = aps.body
        let badge = aps.badge as? Int ?? 0
        let title = aps.title
        UIApplication.shared.applicationIconBadgeNumber = 0;
        result["body"] = body
        result["badge"] = badge
        result["title"] = title
        result["silent"] = true
        _channel.invokeMethod("onReceived", arguments: result)
        return completionHandler([.badge, .alert, .sound])
    }
    
}

extension Error {
    public func toString() -> String {
        return String(describing: self);
    }
}
