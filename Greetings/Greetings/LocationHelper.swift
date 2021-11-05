import Foundation
import CoreLocation
import SwiftUI

enum LocationAlert {
    static let off = Alert(title: Text("Location services is OFF"), message: Text("Please turn on location services in Settings > Privacy > Location Services. Altitude is required in collecting RDE data."), dismissButton: .default(Text("OK")))
    static let restricted = Alert(title: Text("Location services is RESTRICTED"), message: Text("Please turn on location services in Settings > Privacy > Location Services. Altitude is required in collecting RDE data."), dismissButton: .default(Text("OK")))
    static let denied = Alert(title: Text("Location services is DENIED"), message: Text("Please turn on location services in Settings > Privacy > Location Services. Altitude is required in collecting RDE data."), dismissButton: .default(Text("OK")))
}

// CLLocationManagerDelegate: so that whenever location permisson changes, the delegate is notified.
// add NSObject before the CLLocationManagerDelegate protocol, otherwise it won't work.
final class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    // The system calls the delegate’s locationManagerDidChangeAuthorization(_:) method immediately when you create a location manager, and again when the app’s authorization changes.
    var locationManager: CLLocationManager?
    
    @Published var alert: Alert? = nil
    @Published var showAlert: Bool = false
    @Published var altitude: CLLocationDistance = 0
    
    func checkIfLocationServicesIsEnabled()->() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            alert = nil
            showAlert = false
        }else{
            print("Location service is off, please turn it on.")
            alert = LocationAlert.off
            showAlert = true
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            alert = LocationAlert.restricted
            showAlert = true
        case .denied:
            alert = LocationAlert.denied
            showAlert = true
        case .authorizedAlways, .authorizedWhenInUse:
            altitude = locationManager.location!.altitude
            print("assign altitude to \(altitude)")
            alert = nil
            showAlert = false
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
