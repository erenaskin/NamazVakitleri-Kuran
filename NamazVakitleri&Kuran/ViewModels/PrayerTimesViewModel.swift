//
//  PrayerTimesViewModel.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//

import Foundation
import Combine

@MainActor
class PrayerTimesViewModel: ObservableObject {
    @Published var timings: Timings?
    @Published var dateInfo: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Geri sayım için değişkenler
    @Published var nextPrayerName: String = ""
    @Published var timeRemaining: String = ""
    
    private var timer: Timer?
    
    // Şehir ismi yerine doğrudan GPS koordinatlarını alıyoruz
    func loadPrayerTimes(latitude: Double, longitude: Double) {
            isLoading = true
            errorMessage = nil
            
            Task {
                do {
                    let response = try await NetworkManager.shared.fetchPrayerTimes(latitude: latitude, longitude: longitude)
                    self.timings = response.data.timings
                    self.dateInfo = response.data.date.readable
                    self.isLoading = false
                    
                    // YENİ EKLENEN SATIR: Veri gelir gelmez alarmları View yerine buradan kuruyoruz
                    NotificationManager.shared.schedulePrayerNotifications(timings: response.data.timings)
                    
                    // Veri gelince geri sayımı başlat
                    self.startTimer()
                } catch {
                    self.errorMessage = "Vakitler yüklenirken hata oluştu: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    
    // MARK: - Geri Sayım (Timer) Mantığı
    private func startTimer() {
        timer?.invalidate()
        updateCountdown()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateCountdown()
            }
        }
    }
    
    private func updateCountdown() {
        guard let timings = timings else { return }
        
        let now = Date()
        let calendar = Calendar.current
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        
        // API'dan gelen saati bugünün tarihi ile eşleştiren yardımcı fonksiyon
        func date(from timeString: String) -> Date? {
            let cleanTime = String(timeString.prefix(5))
            guard let targetDate = format.date(from: cleanTime) else { return nil }
            return calendar.date(bySettingHour: calendar.component(.hour, from: targetDate),
                                 minute: calendar.component(.minute, from: targetDate),
                                 second: 0,
                                 of: now)
        }
        
        let times = [
            ("İmsak", timings.fajr), ("Güneş", timings.sunrise), ("Öğle", timings.dhuhr),
            ("İkindi", timings.asr), ("Akşam", timings.maghrib), ("Yatsı", timings.isha)
        ]
        
        var nextFound = false
        for (name, timeStr) in times {
            if let tDate = date(from: timeStr), tDate > now {
                let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: tDate)
                self.nextPrayerName = name
                self.timeRemaining = String(format: "%02d:%02d:%02d", diff.hour ?? 0, diff.minute ?? 0, diff.second ?? 0)
                nextFound = true
                break
            }
        }
        
        // Tüm vakitler geçtiyse (Yatsı kılındıysa), hedef yarının İmsak vaktidir
        if !nextFound {
            if let tDate = date(from: timings.fajr), let tomorrow = calendar.date(byAdding: .day, value: 1, to: tDate) {
                let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: tomorrow)
                self.nextPrayerName = "İmsak"
                self.timeRemaining = String(format: "%02d:%02d:%02d", diff.hour ?? 0, diff.minute ?? 0, diff.second ?? 0)
            }
        }
    }
}
