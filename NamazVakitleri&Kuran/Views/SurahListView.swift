//
//  SurahListView.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//


import SwiftUI

struct SurahListView: View {
    @StateObject private var viewModel = QuranViewModel()
    
    // 1. Arama çubuğuna yazılan metni tutacak değişken
    @State private var searchText = ""
    
    // 2. Listeyi arama metnine göre filtreleyen akıllı değişken (Computed Property)
    var searchResults: [Surah] {
        if searchText.isEmpty {
            return viewModel.surahs
        } else {
            return viewModel.surahs.filter { surah in
                // Hem Türkçe isminde hem de orijinal Arapça isminde arama yapabilmesi için:
                let turkishName = SurahHelper.turkishMeanings[surah.number].lowercased()
                let arabicName = surah.name.lowercased()
                let search = searchText.lowercased()
                
                return turkishName.contains(search) || arabicName.contains(search)
            }
        }
    }
    
    var body: some View {
        // Not: Daha modern ve hatasız olan NavigationStack kullanımına geçtik
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.surahs.isEmpty {
                    ProgressView("Sureler Yükleniyor...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else {
                    // 3. Listeye artık tüm sureleri değil, filtrelenmiş sonuçları (searchResults) veriyoruz
                    List(searchResults) { surah in
                        NavigationLink(destination: SurahDetailView(surahNumber: surah.number, viewModel: viewModel)) {
                            HStack {
                                // Sira Numarası Çemberi
                                Text("\(surah.number)")
                                    .font(.caption)
                                    .frame(width: 35, height: 35)
                                    .background(Circle().stroke(Color.green, lineWidth: 2))
                                
                                VStack(alignment: .leading) {
                                    Text(SurahHelper.turkishMeanings[surah.number])
                                        .font(.headline)
                                    Text("Ayet Sayısı: \(surah.numberOfAyahs)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                                
                                Spacer()
                                
                                // Orijinal Arapça İsmi
                                Text(surah.name)
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                    // 4. Arama Çubuğunu (Search Bar) ekleyen o sihirli satır
                    .searchable(text: $searchText, prompt: "Sure Ara...")
                }
            }
            .navigationTitle("Kuran-ı Kerim")
            .onAppear {
                if viewModel.surahs.isEmpty {
                    viewModel.loadSurahs()
                }
            }
        }
    }
}
