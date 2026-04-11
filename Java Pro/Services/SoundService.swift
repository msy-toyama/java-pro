//
//  SoundService.swift
//  Java Pro
//
//  効果音を一元管理するサービス。AVAudioPlayer を使用し、
//  音量（volume）と有効/無効（isEnabled）を制御する。
//

import AVFoundation
import UIKit
import os

/// アプリ内効果音の再生を管理するシングルトンサービス。
@MainActor
final class SoundService {
    static let shared = SoundService()

    /// 効果音が有効かどうか（SettingsView で切り替え可能）
    var isEnabled = true

    /// 効果音の音量（0.0〜1.0）
    var volume: Float = 0.7

    private var audioPlayer: AVAudioPlayer?

    /// 音声データキャッシュ（Sound -> WAV Data）- 毎回再生成を回避
    private var soundCache: [Sound: Data] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
    }

    // MARK: - 効果音種別

    enum Sound {
        /// クイズ正解
        case correct
        /// クイズ不正解
        case incorrect
        /// レベルアップ
        case levelUp
        /// バッジ獲得
        case badgeEarned
        /// レッスン完了
        case lessonComplete
        /// ボタンタップ
        case tap
    }

    // MARK: - 再生

    /// 指定した効果音を再生する。`isEnabled` が `false` または `volume` が 0 の場合は何もしない。
    func play(_ sound: Sound) {
        guard isEnabled, volume > 0 else { return }

        let notes: [(frequency: Double, duration: Double)]
        switch sound {
        case .correct:
            notes = [(880, 0.12)]
        case .incorrect:
            notes = [(330, 0.20)]
        case .levelUp:
            notes = [(523, 0.10), (659, 0.10), (784, 0.10), (1047, 0.18)]
        case .badgeEarned:
            notes = [(784, 0.08), (988, 0.08), (1175, 0.18)]
        case .lessonComplete:
            notes = [(659, 0.10), (784, 0.14)]
        case .tap:
            notes = [(1200, 0.03)]
        }

        // キャッシュから WAV データを取得（初回のみ生成）
        let data: Data
        if let cached = soundCache[sound] {
            data = cached
        } else {
            guard let generated = generateWAV(notes: notes) else { return }
            soundCache[sound] = generated
            data = generated
        }

        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            AppLogger.sound.error("再生エラー: \(error.localizedDescription)")
        }
    }

    // MARK: - WAV 生成

    /// 正弦波トーン列から 16-bit モノラル WAV データをメモリ上に生成する。
    private func generateWAV(notes: [(frequency: Double, duration: Double)],
                             sampleRate: Int = 44100) -> Data? {
        let totalFrames = notes.reduce(0) { $0 + Int($1.duration * Double(sampleRate)) }
        guard totalFrames > 0 else { return nil }

        let bytesPerSample = 2
        let dataSize = totalFrames * bytesPerSample

        var wav = Data(capacity: 44 + dataSize)

        // ---- RIFF header ----
        wav.append(contentsOf: Array("RIFF".utf8))
        appendLE32(&wav, UInt32(36 + dataSize))
        wav.append(contentsOf: Array("WAVE".utf8))

        // ---- fmt  chunk ----
        wav.append(contentsOf: Array("fmt ".utf8))
        appendLE32(&wav, 16)                              // chunk size
        appendLE16(&wav, 1)                               // PCM
        appendLE16(&wav, 1)                               // mono
        appendLE32(&wav, UInt32(sampleRate))               // sample rate
        appendLE32(&wav, UInt32(sampleRate * bytesPerSample)) // byte rate
        appendLE16(&wav, UInt16(bytesPerSample))           // block align
        appendLE16(&wav, 16)                              // bits per sample

        // ---- data chunk ----
        wav.append(contentsOf: Array("data".utf8))
        appendLE32(&wav, UInt32(dataSize))

        // ---- PCM samples ----
        for note in notes {
            let frames = Int(note.duration * Double(sampleRate))
            let fadeLen = min(Int(0.005 * Double(sampleRate)), frames / 4)

            for i in 0..<frames {
                let t = Double(i) / Double(sampleRate)
                var amp = sin(2.0 * .pi * note.frequency * t)

                // フェードイン / アウトでクリックノイズを防止
                if i < fadeLen {
                    amp *= Double(i) / Double(fadeLen)
                } else if i > frames - fadeLen {
                    amp *= Double(frames - i) / Double(fadeLen)
                }

                let sample = Int16(clamping: Int(amp * 24000))
                appendLE16Signed(&wav, sample)
            }
        }

        return wav
    }

    // MARK: - バイト書き込みヘルパー

    private func appendLE32(_ data: inout Data, _ value: UInt32) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    private func appendLE16(_ data: inout Data, _ value: UInt16) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    private func appendLE16Signed(_ data: inout Data, _ value: Int16) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }
}
