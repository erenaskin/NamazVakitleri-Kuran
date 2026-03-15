//
//  QuranViewModel.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class QuranViewModel: ObservableObject {
    @Published var surahs: [Surah] = []
    @Published var selectedSurahDetail: SurahDetail?
    @Published var mergedAyahs: [MergedAyah] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // 1. Tüm Surelerin Listesini Yükler
    func loadSurahs() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchSurahs()
                self.surahs = response.data
                self.isLoading = false
            } catch {
                self.errorMessage = "Sure listesi yüklenemedi: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // 2. Seçilen Surenin Ayetlerini ve Seslerini Yükler
    // edition: "ar.alafasy" (Arapça ses ve metin için)
    func loadSurahDetail(surahNumber: Int) {
            isLoading = true
            errorMessage = nil
            mergedAyahs = [] // Listeyi temizle
            selectedSurahDetail = nil
            
            Task {
                do {
                    // async let ile 3 isteği aynı anda (paralel) başlatıyoruz
                    async let arabicRes = NetworkManager.shared.fetchSurahDetail(surahNumber: surahNumber, edition: "ar.alafasy")
                    async let readingRes = NetworkManager.shared.fetchSurahDetail(surahNumber: surahNumber, edition: "tr.transliteration")
                    async let turkishRes = NetworkManager.shared.fetchSurahDetail(surahNumber: surahNumber, edition: "tr.diyanet")
                    
                    // Üçünün de inmesini bekliyoruz
                    let arabic = try await arabicRes.data
                    let reading = try await readingRes.data
                    let turkish = try await turkishRes.data
                    
                    // Gelen verileri döngüyle birleştirip MergedAyah modeline çeviriyoruz
                                    var tempAyahs: [MergedAyah] = []
                                    for i in 0..<arabic.ayahs.count {
                                        
                                        let newAyah = MergedAyah(
                                            id: arabic.ayahs[i].number,
                                            numberInSurah: arabic.ayahs[i].numberInSurah,
                                            arabicText: arabic.ayahs[i].text,
                                            audio: arabic.ayahs[i].audio,
                                            // Doğrudan API'den gelen akademik tr.transliteration metnini alıyoruz
                                            reading: reading.ayahs[i].text.sentenceCapitalized,
                                            translation: turkish.ayahs[i].text
                                        )
                                        tempAyahs.append(newAyah)
                                    }
                    
                    self.mergedAyahs = tempAyahs
                    self.selectedSurahDetail = arabic // Ekran başlığı (Sure ismi) için lazım
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Ayetler yüklenirken hata oluştu: \(error.localizedDescription)"
                    self.isLoading = false
            }
        }
    }
}
extension String {
    var sentenceCapitalized: String {
        guard let first = self.first else { return self }
        return String(first).uppercased() + self.dropFirst()
    }
}
