//
//  QuranResponse.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//

import Foundation

// 1. Generic yapı
struct QuranResponse<T: Codable>: Codable, Sendable {
    let code: Int
    let status: String
    let data: T
}

// 2. Sure modeli
struct Surah: Codable, Identifiable, Sendable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String
    
    var id: Int { number }
}

// 3. Detay modeli
struct SurahDetail: Codable, Sendable {
    let number: Int
    let name: String
    let englishName: String
    let ayahs: [Ayah]
}

// 4. Ayet modeli
struct Ayah: Codable, Identifiable, Sendable {
    let number: Int
    let text: String
    let numberInSurah: Int
    let audio: String?
    
    var id: Int { number }
}

// 5. Birleşik (Merged) model
struct MergedAyah: Identifiable, Sendable {
    let id: Int
    let numberInSurah: Int
    let arabicText: String
    let audio: String?
    let reading: String
    let translation: String
}
