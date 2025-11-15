import XCTest
@testable import SingingBowlTuner

class NoteTests: XCTestCase {

    func test_fromFrequency_A4_isCorrect() {
        let frequency = 440.0
        let note = Note.from(frequency: frequency)

        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "A")
        XCTAssertEqual(note?.octave, 4)
        XCTAssertEqual(note?.cents ?? 0, 0, accuracy: 0.01)
    }

    func test_fromFrequency_C4_isCorrect() {
        let frequency = 261.63
        let note = Note.from(frequency: frequency)

        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "C")
        XCTAssertEqual(note?.octave, 4)
        XCTAssertEqual(note?.cents ?? 0, 0, accuracy: 0.01)
    }

    func test_fromFrequency_SlightlySharp_isCorrect() {
        let frequency = 441.0 // Slightly sharp A4
        let note = Note.from(frequency: frequency)

        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "A")
        XCTAssertEqual(note?.octave, 4)
        XCTAssert(note!.cents > 0)
    }

    func test_fromFrequency_SlightlyFlat_isCorrect() {
        let frequency = 439.0 // Slightly flat A4
        let note = Note.from(frequency: frequency)

        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "A")
        XCTAssertEqual(note?.octave, 4)
        XCTAssert(note!.cents < 0)
    }

    func test_fromFrequency_ZeroFrequency_returnsNil() {
        let frequency = 0.0
        let note = Note.from(frequency: frequency)

        XCTAssertNil(note)
    }
}
