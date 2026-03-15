//
//  ContentView.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // 1. Sekme: Namaz Vakitleri
            PrayerTimesView()
                .tabItem {
                    Label("Vakitler", systemImage: "clock.fill")
                }
            
            // 2. Sekme: Kuran-ı Kerim
            SurahListView()
                .tabItem {
                    Label("Kuran", systemImage: "book.fill")
                }
        }
        // Sekme ikonlarının rengini ayarlayabilirsin
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}
