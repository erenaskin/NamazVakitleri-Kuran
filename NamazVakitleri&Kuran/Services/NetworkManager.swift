//
//  NetworkManager.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//

import Foundation

// Olası ağ hatalarını tanımladığımız yapı
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

// ÇÖZÜM: Swift 6 için sınıfı final ve Sendable yaptık
final class NetworkManager: Sendable {
    
    // Uygulama genelinde tek bir kopya (Singleton)
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Genel Veri Çekme Fonksiyonu (Generic)
    // ÇÖZÜM: Derleyiciyi rahatlatmak için & Sendable kuralını kaldırdık
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Decoding hatası: \(error.localizedDescription)")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Namaz Vakitlerini Çeken Fonksiyon (Şehir ile)
    func fetchPrayerTimes(city: String = "İzmir", country: String = "Türkiye") async throws -> PrayerTimeResponse {
        let urlString = "https://api.aladhan.com/v1/timingsByCity?city=\(city)&country=\(country)&method=13"
        
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        return try await fetch(from: encodedURLString)
    }
    
    // MARK: - Namaz Vakitlerini Çeken Fonksiyon (GPS ile)
    func fetchPrayerTimes(latitude: Double, longitude: Double) async throws -> PrayerTimeResponse {
        let urlString = "https://api.aladhan.com/v1/timings?latitude=\(latitude)&longitude=\(longitude)&method=13"
        return try await fetch(from: urlString)
    }
    
    // MARK: - Kuran Surelerini Çeken Fonksiyon
    func fetchSurahs() async throws -> QuranResponse<[Surah]> {
        let urlString = "https://api.alquran.cloud/v1/surah"
        return try await fetch(from: urlString)
    }
    
    // MARK: - Kuran Suresi Detayını Çeken Fonksiyon
    func fetchSurahDetail(surahNumber: Int, edition: String = "ar.alafasy") async throws -> QuranResponse<SurahDetail> {
        let urlString = "https://api.alquran.cloud/v1/surah/\(surahNumber)/\(edition)"
        return try await fetch(from: urlString)
    }
}
