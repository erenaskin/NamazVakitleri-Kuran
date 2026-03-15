//
//  SurahDetailView.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//


import SwiftUI

struct SurahDetailView: View {
    let surahNumber: Int
    @ObservedObject var viewModel: QuranViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView().scaleEffect(1.5)
                    Text("Ayetler Yükleniyor...").padding(.top)
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red).multilineTextAlignment(.center).padding()
            } else if let detail = viewModel.selectedSurahDetail {
                
                // DİKKAT: Artık mergedAyahs listesini kullanıyoruz
                List(viewModel.mergedAyahs) { ayah in
                    VStack(alignment: .trailing, spacing: 15) {
                        
                        // 1. Üst Kısım: Buton ve Ayet Numarası
                        HStack {
                            if let audioURL = ayah.audio {
                                Button(action: {
                                    AudioPlayerManager.shared.playAudio(from: audioURL)
                                }) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Spacer()
                            Text(" \(ayah.numberInSurah) ")
                                .font(.caption)
                                .padding(5)
                                .background(Circle().stroke(Color.gray))
                        }
                        
                        // 2. Orijinal Arapça Metin (Sağa Dayalı)
                        Text(ayah.arabicText)
                            .font(.system(size: 28, weight: .medium, design: .serif))
                            .multilineTextAlignment(.trailing)
                        
                        // 3. Okunuş ve Anlam Kısmı (Sola Dayalı)
                        VStack(alignment: .leading, spacing: 8) {
                            
                            // İnce ayırıcı çizgi
                            Divider().background(Color.gray.opacity(0.3))
                            
                            // Okunuşu (Yeşil ve İtalik)
                            Text(ayah.reading)
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Türkçe Meali (Normal ve Gri)
                            Text(ayah.translation)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 12)
                }
                .listStyle(PlainListStyle())
                .navigationTitle(SurahHelper.turkishMeanings[surahNumber])                .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Veri çekilemedi, lütfen tekrar deneyin.")
            }
        }
        .task {
            viewModel.loadSurahDetail(surahNumber: surahNumber)
        }
        .onDisappear {
            AudioPlayerManager.shared.stopAudio()
        }
    }
}
