import AVFoundation
import Combine

enum DrumType: CaseIterable, Hashable {
    case kick
    case snare
    case tom
    case hihat
    case crash
}

class AudioEngineManager: ObservableObject {
    private let engine = AVAudioEngine()
    private var players: [DrumType: AVAudioPlayerNode] = [:]
    private var buffers: [DrumType: AVAudioPCMBuffer] = [:]

    init() {
        setupEngine()
        generateSounds()
    }

    private func setupEngine() {
        for type in DrumType.allCases {
            let player = AVAudioPlayerNode()
            players[type] = player
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: nil)
        }

        engine.prepare()
        try? engine.start()
    }

    private func generateSounds() {
        buffers[.kick]  = generateKick()
        buffers[.snare] = generateSnare()
        buffers[.tom]   = generateTom()
        buffers[.hihat] = generateHiHat()
        buffers[.crash] = generateCrash()
    }

    func playSound(_ type: DrumType) {
        guard let player = players[type],
              let buffer = buffers[type] else { return }

        // Do NOT stop — allow overlaps
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        if !player.isPlaying {
            player.play()
        }
    }
}

private func generateKick() -> AVAudioPCMBuffer? {
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    let frames = AVAudioFrameCount(44100 * 0.3)

    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
    buffer.frameLength = frames

    let l = buffer.floatChannelData![0]
    let r = buffer.floatChannelData![1]

    for i in 0..<Int(frames) {
        let t = Float(i) / 44100
        let freq = 120 * exp(-t * 8)
        let amp = exp(-t * 18)
        let sample = sin(2 * .pi * freq * t) * amp * 0.6
        l[i] = sample
        r[i] = sample
    }
    return buffer
}

private func generateSnare() -> AVAudioPCMBuffer? {
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    let frames = AVAudioFrameCount(44100 * 0.18)

    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
    buffer.frameLength = frames

    let l = buffer.floatChannelData![0]
    let r = buffer.floatChannelData![1]

    for i in 0..<Int(frames) {
        let t = Float(i) / 44100
        let noise = Float.random(in: -1...1)
        let tone = sin(2 * .pi * 200 * t)
        let amp = exp(-t * 18)
        let sample = (noise * 0.7 + tone * 0.3) * amp * 0.4
        l[i] = sample
        r[i] = sample
    }
    return buffer
}

private func generateTom() -> AVAudioPCMBuffer? {
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    let frames = AVAudioFrameCount(44100 * 0.25)

    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
    buffer.frameLength = frames

    let l = buffer.floatChannelData![0]
    let r = buffer.floatChannelData![1]

    for i in 0..<Int(frames) {
        let t = Float(i) / 44100
        let freq = 180 * exp(-t * 4)
        let amp = exp(-t * 8)
        let sample = sin(2 * .pi * freq * t) * amp * 0.5
        l[i] = sample
        r[i] = sample
    }
    return buffer
}


private func generateHiHat() -> AVAudioPCMBuffer? {
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    let frames = AVAudioFrameCount(44100 * 0.08)

    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
    buffer.frameLength = frames

    let l = buffer.floatChannelData![0]
    let r = buffer.floatChannelData![1]

    for i in 0..<Int(frames) {
        let t = Float(i) / 44100
        let noise = Float.random(in: -1...1)
        let amp = exp(-t * 40)
        let sample = noise * amp * 0.25
        l[i] = sample
        r[i] = sample
    }
    return buffer
}

private func generateCrash() -> AVAudioPCMBuffer? {
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    let frames = AVAudioFrameCount(44100 * 0.6)

    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
    buffer.frameLength = frames

    let l = buffer.floatChannelData![0]
    let r = buffer.floatChannelData![1]

    for i in 0..<Int(frames) {
        let t = Float(i) / 44100
        let noise = Float.random(in: -1...1)
        let shimmer = sin(2 * .pi * 8000 * t)
        let amp = exp(-t * 4)
        let sample = (noise * 0.7 + shimmer * 0.3) * amp * 0.3
        l[i] = sample
        r[i] = sample
    }
    return buffer
}
