//
//  AudioPlayerManager.swift
//  NamazVakitleri&Kuran
//
//  Created by Eren AŞKIN on 12.03.2026.
//


import Foundation
import AVFoundation
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    
    // Arayüzün dinleyeceği değişken: Ses şu an çalıyor mu?
    @Published var isPlaying: Bool = false
    
    private init() {
        setupAudioSession()
    }
    
    // Arka planda ses çalabilmek için gerekli ayar (Faz 1'de Info sekmesinden verdiğimiz iznin kod karşılığı)
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Arka plan ses ayarı yapılamadı: \(error.localizedDescription)")
        }
    }
    
    // URL'den Ses Çalma
    func playAudio(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        // Eğer farklı bir ayete tıklandıysa veya player boşsa yeni bir player oluştur
        if player == nil || (player?.currentItem?.asset as? AVURLAsset)?.url != url {
            player = AVPlayer(url: url)
        }
        
        player?.play()
        isPlaying = true
    }
    
    // Sesi Duraklatma
    func pauseAudio() {
        player?.pause()
        isPlaying = false
    }
    
    // Sesi Tamamen Durdurma
    func stopAudio() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
    }
}
