// ios/Runner/AppDelegate.swift

import UIKit
import Flutter
import Firebase
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // AR Properties
    private var arChannel: FlutterMethodChannel?
    private var arViewFactory: ArMeasurementViewFactory?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // ═══════════════════════════════════════════════════════════════════
        // Firebase Initialize
        // ═══════════════════════════════════════════════════════════════════
        FirebaseApp.configure()
        
        // ═══════════════════════════════════════════════════════════════════
        // Push Notification Setup
        // ═══════════════════════════════════════════════════════════════════
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        // Set Messaging delegate
        Messaging.messaging().delegate = self
        
        // ═══════════════════════════════════════════════════════════════════
        // ARKit Setup
        // ═══════════════════════════════════════════════════════════════════
        let controller = window?.rootViewController as! FlutterViewController
        
        // Setup AR method channel
        arChannel = FlutterMethodChannel(
            name: "com.ssaprktech.scaffassistant/ar_measurement",
            binaryMessenger: controller.binaryMessenger
        )
        
        // Create and register AR view factory
        arViewFactory = ArMeasurementViewFactory(
            messenger: controller.binaryMessenger,
            channel: arChannel!
        )
        
        let registrar = self.registrar(forPlugin: "ArMeasurementPlugin")!
        registrar.register(arViewFactory!, withId: "ar_measurement_view_ios")
        
        // Handle AR method calls
        arChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let arView = self?.arViewFactory?.currentView else {
                if call.method == "isSupported" {
                    result(ArMeasurementView.isARKitSupported())
                    return
                }
                result(FlutterError(code: "NO_VIEW", message: "AR View not initialized", details: nil))
                return
            }
            
            switch call.method {
            case "isSupported":
                result(ArMeasurementView.isARKitSupported())
            case "initialize":
                let success = arView.initialize()
                result(success)
            case "addPoint":
                arView.addPoint()
                result(nil)
            case "undo":
                arView.undo()
                result(nil)
            case "clear":
                arView.clear()
                result(nil)
            case "snapshot":
                let data = arView.takeSnapshot()
                result(data)
            case "dispose":
                arView.dispose()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // Register Plugins
        // ═══════════════════════════════════════════════════════════════════
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // Handle device token
    // ═══════════════════════════════════════════════════════════════════════
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}