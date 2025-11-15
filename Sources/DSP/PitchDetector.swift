import Foundation
import Accelerate

/// `PitchDetector` is responsible for analyzing a buffer of audio samples to find the fundamental frequency.
/// It uses the YIN algorithm, which is well-suited for signals with rich overtones, like singing bowls.
class PitchDetector {

    private let sampleRate: Double
    private let bufferSize: Int
    private let yinBufferSize: Int
    private var yinBuffer: [Float]

    // YIN algorithm parameters
    private let threshold: Float = 0.15 // Standard threshold for YIN

    /// Initializes the pitch detector.
    /// - Parameters:
    ///   - sampleRate: The sample rate of the audio being processed (e.g., 44100 Hz).
    ///   - bufferSize: The size of the incoming audio buffers.
    init(sampleRate: Double, bufferSize: Int) {
        self.sampleRate = sampleRate
        self.bufferSize = bufferSize
        self.yinBufferSize = bufferSize / 2
        self.yinBuffer = [Float](repeating: 0.0, count: yinBufferSize)
    }

    /// Detects the fundamental frequency from a buffer of audio samples using the YIN algorithm.
    /// - Parameter buffer: An array of `Float` audio samples.
    /// - Returns: The detected frequency in Hz, or `nil` if no clear pitch is found.
    func detectFrequency(from buffer: [Float]) -> Float? {
        guard buffer.count == bufferSize else { return nil }

        // Step 1: Calculate the difference function.
        // This is the core of the YIN algorithm. d(τ) = Σ(x_j - x_{j+τ})²
        for tau in 1..<yinBufferSize {
            var sum: Float = 0.0
            // We can optimize this loop using vDSP
            vDSP_distancesq(buffer, 1, buffer.advanced(by: tau), 1, &sum, vDSP_Length(yinBufferSize))
            yinBuffer[tau] = sum
        }

        // Step 2: Cumulative mean normalized difference function.
        // This step helps to prevent selecting an overtone (octave errors).
        yinBuffer[0] = 1.0
        var runningSum: Float = 0.0
        for tau in 1..<yinBufferSize {
            runningSum += yinBuffer[tau]
            if runningSum > 0 {
                yinBuffer[tau] *= Float(tau) / runningSum
            }
        }

        // Step 3: Absolute threshold.
        // Find the first dip in the YIN buffer that is below the threshold.
        // This dip corresponds to the fundamental period of the signal.
        var period: Int = 0
        for tau in 2..<yinBufferSize { // Start from 2 to avoid trivial dips
            if yinBuffer[tau] < threshold && yinBuffer[tau] < yinBuffer[tau-1] {
                period = tau
                break
            }
        }

        // If no period is found below the threshold, find the global minimum.
        if period == 0 {
            var minVal: Float = .greatestFiniteMagnitude
            for tau in 1..<yinBufferSize {
                if yinBuffer[tau] < minVal {
                    minVal = yinBuffer[tau]
                    period = tau
                }
            }
        }

        // If the period is still 0, it means no pitch was detected.
        if period == 0 {
            return nil
        }

        // Step 4: Parabolic interpolation for better precision.
        // Refine the period estimate for greater accuracy by fitting a parabola to the dip.
        let estimatedFrequency: Float
        if period > 0 && period < yinBufferSize - 1 {
            let prev = yinBuffer[period - 1]
            let current = yinBuffer[period]
            let next = yinBuffer[period + 1]

            let a = (prev + next - 2 * current) / 2
            let b = (next - prev) / 2

            let fractionalPeriod = (a != 0) ? -b / (2 * a) : 0
            estimatedFrequency = Float(sampleRate) / (Float(period) + fractionalPeriod)
        } else {
            estimatedFrequency = Float(sampleRate) / Float(period)
        }

        // A simple sanity check for the detected frequency.
        guard estimatedFrequency > 60 && estimatedFrequency < 2000 else {
            return nil
        }

        return estimatedFrequency
    }
}
