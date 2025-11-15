import Foundation

/// Represents a musical note with its name, octave, frequency, and deviation from a target frequency.
struct Note {
    let name: String
    let octave: Int
    let frequency: Double
    let cents: Double // Deviation in cents from the perfect pitch

    /// A static list of all note names in an octave.
    private static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    /// The reference frequency for A4. This can be changed for different tuning standards.
    private static let referenceFrequencyA4: Double = 440.0

    /// Converts a given frequency (in Hz) into a musical note.
    /// - Parameter frequency: The frequency to convert.
    /// - Returns: A `Note` object representing the closest musical note, or `nil` if the frequency is out of a reasonable range.
    static func from(frequency: Double) -> Note? {
        guard frequency > 0 else { return nil }

        // Calculate the number of half-steps away from the reference A4
        let halfStepsFromA4 = 12.0 * log2(frequency / referenceFrequencyA4)

        // Round to the nearest half-step to find the closest note
        let nearestHalfStep = Int(round(halfStepsFromA4))

        // Calculate the "perfect" frequency of the closest note
        let perfectFrequency = referenceFrequencyA4 * pow(2.0, Double(nearestHalfStep) / 12.0)

        // Calculate the deviation in cents
        let cents = 1200.0 * log2(frequency / perfectFrequency)

        // Determine the note's name and octave
        let noteIndex = (nearestHalfStep + 57) % 12 // 57 is the number of half-steps from C0 to A4
        let octave = 4 + (nearestHalfStep + 9) / 12

        // Handle negative indices for note names
        let correctedNoteIndex = (noteIndex + 12) % 12

        return Note(
            name: noteNames[correctedNoteIndex],
            octave: octave,
            frequency: frequency,
            cents: cents
        )
    }
}
