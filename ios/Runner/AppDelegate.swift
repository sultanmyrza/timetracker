import UIKit
import Flutter
import NotificationCenter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let scheduledNotificationsChannel  = FlutterMethodChannel(name: "com.u2731.timetracker/notifications", binaryMessenger: controller)
        
        scheduledNotificationsChannel.setMethodCallHandler({
            [] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in guard call.method == "scheduleNotification" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            // TODO: ask permition for notificaitons
            if #available(iOS 10.0, *) {
                
                // Define the custom actions.
                let acceptAction = UNNotificationAction(identifier: "DONE_ACTION",
                                                        title: "Done let's start next",
                                                        options: UNNotificationActionOptions(rawValue: 0))
                let delayAction5mins = UNNotificationAction(identifier: "DELAY_ACTION_MINS_5",
                                                            title: "Need 5 more minutes",
                                                            options: UNNotificationActionOptions(rawValue: 0))
                let delayAction10Mins = UNNotificationAction(identifier: "DELAY_ACTION_MINS_10",
                                                             title: "Need 10 more minutes",
                                                             options: UNNotificationActionOptions(rawValue: 0))
                let delayAction15Mins = UNNotificationAction(identifier: "DELAY_ACTION_MINS_15",
                                                             title: "Need 15 more minutes",
                                                             options: UNNotificationActionOptions(rawValue: 0))
                
                // Define the notification type
                let meetingInviteCategory =
                    UNNotificationCategory(identifier: "MEETING_INVITATION",
                                           actions: [acceptAction, delayAction5mins, delayAction10Mins, delayAction15Mins],
                                           intentIdentifiers: [],
                                           hiddenPreviewsBodyPlaceholder: "",
                                           options: .customDismissAction)
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow, error in})
                
                // TODO: create notificatoin
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "Raffi"
                notificationContent.subtitle = "Subtitle look like this"
                notificationContent.body = "Don't forget to chage task if you done swipe notification down for more optoins"
                notificationContent.categoryIdentifier = "MEETING_INVITATION"
                notificationContent.sound = UNNotificationSound.default()
                
                let uuidString = UUID().uuidString
                let durationInSeconds = call.arguments as! Int
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationInSeconds), repeats: false )
                let request = UNNotificationRequest(identifier: uuidString, content: notificationContent, trigger: trigger)
                
                // Adds ability to sent local notificatin when app is in foreground
                UNUserNotificationCenter.current().delegate = self
                
                // Schedule the request with the system.
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.setNotificationCategories([meetingInviteCategory])
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        // Handle any errors.
                        // TODO: send error adding notificaiton
                    }
                    result(uuidString)
                }
            } else {
                // Fallback on earlier versions
                // TODO send error notification not supported
            }
        })
        
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Adds ability to sent local notificatin when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
}
