//
//  PrayerTimesView.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//


import SwiftUI
internal import _LocationEssentials

struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading && viewModel.timings == nil {
                    VStack {
                        ProgressView().scaleEffect(1.5)
                        Text("Vakitler Hesaplanıyor...").padding(.top)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundColor(.red).padding()
                } else if let timings = viewModel.timings {
                    
                    // ÇÖZÜM: Tüm ekranı tek bir ScrollView içine aldık
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            
                            // 1. Konum Göstergesi
                            HStack(spacing: 12) {
                                Image(systemName: "location.fill")
                                    .font(.title3) // İkonu bir tık büyüttük
                                    .foregroundColor(.green)
                                
                                Text(locationManager.cityName) // Örneğin ekranda "İzmir" yazacak
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // 2. Geri Sayım Kartı
                            VStack(spacing: 8) {
                                Text("\(viewModel.nextPrayerName) Vaktine Kalan Süre")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(viewModel.timeRemaining)
                                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                                    .foregroundColor(.green)
                                
                                Text(viewModel.dateInfo)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            
                            // 3. Vakitlerin Listesi (VStack ile özel tasarım liste)
                            VStack(spacing: 0) {
                                PrayerTimeRow(title: "İmsak", time: timings.fajr, icon: "moon.stars.fill")
                                Divider().padding(.leading, 40)
                                PrayerTimeRow(title: "Güneş", time: timings.sunrise, icon: "sunrise.fill")
                                Divider().padding(.leading, 40)
                                PrayerTimeRow(title: "Öğle", time: timings.dhuhr, icon: "sun.max.fill")
                                Divider().padding(.leading, 40)
                                PrayerTimeRow(title: "İkindi", time: timings.asr, icon: "sun.min.fill")
                                Divider().padding(.leading, 40)
                                PrayerTimeRow(title: "Akşam", time: timings.maghrib, icon: "sunset.fill")
                                Divider().padding(.leading, 40)
                                PrayerTimeRow(title: "Yatsı", time: timings.isha, icon: "moon.fill")
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Namaz Vakitleri")
            .onAppear {
                NotificationManager.shared.requestAuthorization()
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation {
                    viewModel.loadPrayerTimes(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }
            }
        }
    }
}

struct PrayerTimeRow: View {
    let title: String
    let time: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text(time)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}
