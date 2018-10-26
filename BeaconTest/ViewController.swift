import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController {
    private var locationManager : CLLocationManager!
    private var region : CLBeaconRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (success, error) in
            return
        }
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        
        print(UIApplication.shared.backgroundRefreshStatus.rawValue)
        
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                break
            
            case .restricted, .denied:
                break
            
            case .authorizedWhenInUse:
                break
            
            case .authorizedAlways:
                break
        }
    }

    func monitorBeacons() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            for region in self.locationManager.monitoredRegions {
                self.locationManager.stopMonitoring(for: region)
            }
            
            // Match all beacons with the specified UUID
            let proximityUUID = UUID(uuidString:
                "F7826DA6-4FA2-4E98-8024-BC5B71E0893E")
            let beaconID = "test"
            
            // Create the region and begin monitoring it.
            region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                        identifier: beaconID)
            
            self.locationManager.startMonitoring(for: region!)
            //self.locationManager.startRangingBeacons(in: region!)
            //self.locationManager.startUpdatingLocation()
            self.locationManager.requestState(for: region!)
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            break
            
        case .authorizedWhenInUse:
            break
            
        case .authorizedAlways:
            print("authorization granted")
            monitorBeacons()
            break
            
        case .notDetermined:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("entered region: " + region.identifier)
        if region is CLBeaconRegion {
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exited region")
        if region is CLBeaconRegion {
            if CLLocationManager.isRangingAvailable() {
                manager.stopRangingBeacons(in: region as! CLBeaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitor fail: " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("started monitoring for " + region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch(state) {
        case .unknown:
            print("region state: unknown")
            break
        case .inside:
            print("region state: inside")
            let notification = UNMutableNotificationContent()
            notification.title = "Hej, du der. Ja dig!"
            notification.subtitle = "Skynd dig at klikke her!"
            notification.body = "Hemmeligheder ligger i vente!"
            
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "notification1", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            break
        case .outside:
            print("region state: outside")
            let notification = UNMutableNotificationContent()
            notification.title = "Nej, kom tilbage!"
            notification.subtitle = "Du kan ikke bare forlade os!"
            notification.body = ":("
            
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "notification2", content: notification, trigger: notificationTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            let nearestBeacon = beacons.first!
            let major = CLBeaconMajorValue(truncating: nearestBeacon.major)
            let minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)
            
            switch nearestBeacon.proximity {
                case .near, .immediate:
                    break
                
                default:
                    break
            }
        }
    }
}
