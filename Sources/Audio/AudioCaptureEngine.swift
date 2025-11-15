import Foundation
import AVFoundation

class AudioCaptureEngine: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var pitchDetector: PitchDetector?
    private let audioSession = AVAudioSession.sharedInstance()

    // For smoothing the detected frequency
    private var frequencyHistory: [Float] = []
    private let frequencyHistorySize = 5
    private var bufferCounter = 0
    private let initialBufferCountToIgnore = 3

    @Published var permissionGranted = false
    @Published var detectedFrequency: Float?

    func setup() {
        requestMicrophonePermission()
    }

    private func requestMicrophonePermission() {
        switch audioSession.recordPermission {
        case .granted:
            self.permissionGranted = true
            configureAudioEngine()
        case .denied:
            self.permissionGranted = false
            // Here you might want to show an alert to the user.
            print("Microphone permission denied.")
        case .undetermined:
            audioSession.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.configureAudioEngine()
                    }
                }
            }
        @unknown default:
            fatalError("Unknown microphone permission state.")
        }
    }

    private func configureAudioEngine() {
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Initialize the PitchDetector with the correct sample rate and buffer size.
        let bufferSize: UInt32 = 2048 // A larger buffer size can improve accuracy for low frequencies.
        pitchDetector = PitchDetector(sampleRate: format.sampleRate, bufferSize: Int(bufferSize))

        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, time in
            guard let self = self, let channelData = buffer.floatChannelData else { return }

            self.bufferCounter += 1
            if self.bufferCounter <= self.initialBufferCountToIgnore {
                return
            }

            let bufferSamples = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))

            // Run the pitch detection on a background thread to avoid blocking the audio thread.
            DispatchQueue.global(qos: .userInitiated).async {
                if let frequency = self.pitchDetector?.detectFrequency(from: bufferSamples) {
                    self.addFrequencyToHistory(frequency)
                }

                DispatchQueue.main.async {
                    self.detectedFrequency = self.getSmoothedFrequency()
                }
            }
        }
    }

    // MARK: - Frequency Smoothing

    private func addFrequencyToHistory(_ frequency: Float) {
        frequencyHistory.append(frequency)
        if frequencyHistory.count > frequencyHistorySize {
            frequencyHistory.removeFirst()
        }
    }

    private func getSmoothedFrequency() -> Float? {
        guard !frequencyHistory.isEmpty else { return nil }

        // Simple moving average
        let sum = frequencyHistory.reduce(0, +)
        return sum / Float(frequencyHistory.count)
    }

    func start() {
        guard permissionGranted, let audioEngine = audioEngine else {
            print("Cannot start audio engine: permission not granted or engine not configured.")
            return
        }

        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioEngine.start()
            print("Audio engine started.")
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func stop() {
        if let audioEngine = audioEngine, audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            print("Audio engine stopped.")
        }

        do {
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
