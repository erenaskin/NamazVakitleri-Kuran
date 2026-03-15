//
//  PrayerTimeResponse.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//

import Foundation

// API'dan dönen en dıştaki JSON yapısı
struct PrayerTimeResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerData
}

// Data objesinin içi
struct PrayerData: Codable {
    let timings: Timings
    let date: DateInfo
}

// Vakitlerin tutulduğu model
struct Timings: Codable {
    let fajr, sunrise, dhuhr, asr: String
    let sunset, maghrib, isha, imsak: String

    // JSON'daki büyük harfleri Swift'in küçük harflerine eşleştiriyoruz
    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case sunset = "Sunset"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case imsak = "Imsak"
    }
}

// Tarih bilgisini tutan model
struct DateInfo: Codable {
    let readable: String
}
