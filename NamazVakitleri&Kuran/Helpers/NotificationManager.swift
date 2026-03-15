//
//  NotificationManager.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//


import Foundation
import UserNotifications

class NotificationManager {
    // Singleton yapısı
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - [Görev 11] Kullanıcıdan İzin İsteme
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Bildirim izni istenirken hata oluştu: \(error.localizedDescription)")
            } else if granted {
                print("Bildirim izni başarıyla alındı!")
            } else {
                print("Kullanıcı bildirim iznini reddetti.")
            }
        }
    }
    
    // MARK: - [Görev 12] Ezan Vakitlerini Bildirim Olarak Kurma
    func schedulePrayerNotifications(timings: Timings) {
        let center = UNUserNotificationCenter.current()
        
        // Önce eski kurulmuş bildirimleri temizleyelim ki üst üste binmesin
        center.removeAllPendingNotificationRequests()
        
        // Kurmak istediğimiz vakitleri bir sözlük/dizi yapısında hazırlıyoruz
        let prayerTimesArray = [
            ("Sabah", timings.fajr),
            ("Öğle", timings.dhuhr),
            ("İkindi", timings.asr),
            ("Akşam", timings.maghrib),
            ("Yatsı", timings.isha)
        ]
        
        for (name, timeString) in prayerTimesArray {
            // API'dan gelen saat formatı "05:30 (EEST)" şeklinde olabilir. İlk 5 karakteri (05:30) alıyoruz.
            let cleanTime = String(timeString.prefix(5))
            let timeComponents = cleanTime.split(separator: ":")
            
            guard timeComponents.count == 2,
                  let hour = Int(timeComponents[0]),
                  let minute = Int(timeComponents[1]) else { continue }
            
            // 1. Bildirim İçeriğini Hazırlama
            let content = UNMutableNotificationContent()
            content.title = "\(name) Vakti"
            content.body = "\(name) namazı vakti girdi. Haydi namaza!"
            
            // Eğer projeye "ezan.mp3" eklersen bu satır çalışır, eklemezsen varsayılan ses çalar.
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "ezan.mp3"))
            
            // 2. Bildirimin Çalacağı Zamanı Ayarlama (Her gün o saatte)
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // 3. Bildirimi Sisteme Ekleme
            let request = UNNotificationRequest(identifier: "prayer_\(name)", content: content, trigger: trigger)
            center.add(request) { error in
                if let error = error {
                    print("\(name) bildirimi kurulamadı: \(error.localizedDescription)")
                }
            }
        }
    }
}