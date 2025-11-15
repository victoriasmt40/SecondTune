import XCTest
@testable import SingingBowlTuner

class PitchDetectorTests: XCTestCase {

    func test_detectFrequency_with440HzSineWave_isCorrect() {
        let sampleRate = 44100.0
        let bufferSize = 2048
        let frequency: Float = 440.0 // A4

        let sineWave = generateSineWave(frequency: frequency, amplitude: 1.0, sampleRate: sampleRate, bufferSize: bufferSize)

        let pitchDetector = PitchDetector(sampleRate: sampleRate, bufferSize: bufferSize)
        let detectedFrequency = pitchDetector.detectFrequency(from: sineWave)

        XCTAssertNotNil(detectedFrequency)
        XCTAssertEqual(detectedFrequency ?? 0, frequency, accuracy: 5.0, "Should detect pure 440 Hz sine wave")
    }

    func test_detectFrequency_with880HzSineWave_isCorrect() {
        let sampleRate = 44100.0
        let bufferSize = 2048
        let frequency: Float = 880.0 // A5

        let sineWave = generateSineWave(frequency: frequency, amplitude: 1.0, sampleRate: sampleRate, bufferSize: bufferSize)

        let pitchDetector = PitchDetector(sampleRate: sampleRate, bufferSize: bufferSize)
        let detectedFrequency = pitchDetector.detectFrequency(from: sineWave)

        XCTAssertNotNil(detectedFrequency)
        XCTAssertEqual(detectedFrequency ?? 0, frequency, accuracy: 5.0, "Should detect pure 880 Hz sine wave")
    }

    func test_detectFrequency_withFundamentalAndOvertone_detectsFundamental() {
        let sampleRate = 44100.0
        let bufferSize = 2048
        let fundamental: Float = 220.0 // A3
        let overtone: Float = 440.0    // A4 (first overtone)

        // Create a mixed signal with a louder overtone
        let fundamentalWave = generateSineWave(frequency: fundamental, amplitude: 0.7, sampleRate: sampleRate, bufferSize: bufferSize)
        let overtoneWave = generateSineWave(frequency: overtone, amplitude: 1.0, sampleRate: sampleRate, bufferSize: bufferSize)

        var mixedSignal = [Float](repeating: 0.0, count: bufferSize)
        vDSP_vadd(fundamentalWave, 1, overtoneWave, 1, &mixedSignal, 1, vDSP_Length(bufferSize))

        let pitchDetector = PitchDetector(sampleRate: sampleRate, bufferSize: bufferSize)
        let detectedFrequency = pitchDetector.detectFrequency(from: mixedSignal)

        XCTAssertNotNil(detectedFrequency)
        XCTAssertEqual(detectedFrequency ?? 0, fundamental, accuracy: 5.0, "Should detect the fundamental frequency (220 Hz), not the louder overtone (440 Hz)")
    }

    // MARK: - Helper Function

    private func generateSineWave(frequency: Float, amplitude: Float, sampleRate: Double, bufferSize: Int) -> [Float] {
        var buffer = [Float](repeating: 0.0, count: bufferSize)
        for i in 0..<bufferSize {
            buffer[i] = amplitude * sin(2.0 * .pi * frequency * Float(i) / Float(sampleRate))
        }
        return buffer
    }
}
