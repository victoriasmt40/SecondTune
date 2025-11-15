# Singing Bowl Tuner for iOS

An iOS application designed to accurately measure the frequency (Hz) and musical note of singing bowls, focusing on stability and precision for instruments with rich overtones.

## Features

- **Real-time Frequency Detection**: Measures the fundamental frequency of the sound captured by the microphone.
- **Note and Cents Display**: Converts the frequency into the nearest musical note and shows the deviation in cents.
- **Visual Tuning Indicator**: A horizontal scale with a color-coded indicator (green, yellow, red) provides instant feedback on tuning accuracy.
- **High Stability**: Uses a YIN-based pitch detection algorithm, noise reduction, and result smoothing to provide stable readings, avoiding the "jitter" common in generic tuners.
- **Optimized for Singing Bowls**: The algorithm is specifically tailored to handle the long sustain and complex harmonic spectrum of singing bowls.

## How to Build and Run

This project is set up as a Swift Package, which can be opened and run directly in Xcode.

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    ```
2.  **Open the project in Xcode:**
    - Open Xcode.
    - Go to `File` > `Open...`
    - Navigate to the cloned repository folder and select it.
3.  **Run the application:**
    - Select an iPhone simulator or a connected physical device as the target.
    - Press the "Run" button (or `Cmd+R`).

**Permissions:** The application will request access to the microphone upon first launch. This is necessary for the tuner to function.

## Architecture

The project is structured into several key modules to ensure a clean separation of concerns:

-   **/Sources/Audio**: Contains `AudioCaptureEngine.swift`, which manages `AVAudioEngine`, handles microphone permissions, and streams audio data.
-   **/Sources/DSP**: (Digital Signal Processing) Includes `PitchDetector.swift`, which contains the implementation of the pitch detection algorithm (YIN).
-   **/Sources/Core**: Holds the core data models and logic, such as `Note.swift`, which handles the conversion from frequency to a musical note.
-   **/Sources/UI**: Contains all SwiftUI views, including `TunerView.swift` (the main screen) and `TuningIndicatorView.swift`.
-   **/Tests**: Contains unit tests for the core logic, such as `NoteTests.swift`.

## Pitch Detection Algorithm

The tuner uses a custom implementation of the **YIN algorithm**. This choice was deliberate because YIN is highly effective at finding the fundamental frequency in signals that are rich in harmonics and overtones, which is a key characteristic of singing bowls. Unlike simpler methods that might mistakenly lock onto a louder overtone, YIN is more robust and provides a more accurate reading of the base note.

## Configuration

### Changing the Reference Frequency (A4)

By default, the tuner is calibrated to the standard `A4 = 440 Hz`. You can easily change this to another standard, such as `432 Hz`.

To do so, modify the following constant in the `Sources/Core/Note.swift` file:

```swift
// Sources/Core/Note.swift

// Change this value to your desired reference frequency
private static let referenceFrequencyA4: Double = 440.0
```

## Current Limitations

-   The tuner is most effective in a relatively quiet environment to avoid interference from background noise.
-   A reasonably loud and clear signal from the singing bowl is required for accurate detection.
-   For best results, position the iPhone's microphone a consistent distance (e.g., 15-30 cm) from the bowl.
