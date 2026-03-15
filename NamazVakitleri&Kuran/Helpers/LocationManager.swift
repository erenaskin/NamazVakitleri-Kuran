//
//  LocationManager.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    // Ekranda göstereceğimiz şehir ismi
    @Published var cityName: String = "Konum Aranıyor..."
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        self.location = newLocation
        manager.stopUpdatingLocation()
        
        // Koordinatları şehir ismine (İzmir, İstanbul vb.) çevirme
        CLGeocoder().reverseGeocodeLocation(newLocation) { placemarks, error in
            if let placemark = placemarks?.first {
                // İlçe veya İl ismini alıp ekrana yansıtıyoruz
                self.cityName = placemark.locality ?? placemark.administrativeArea ?? "Bilinmeyen Konum"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
        self.cityName = "Konum Bulunamadı"
    }
}
