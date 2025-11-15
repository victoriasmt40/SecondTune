import SwiftUI

struct TunerView: View {
    @ObservedObject var audioCaptureEngine: AudioCaptureEngine

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Display the detected frequency
            if let frequency = audioCaptureEngine.detectedFrequency, let note = Note.from(frequency: frequency) {
                Text(note.name)
                    .font(.system(size: 100, weight: .bold))

                Text(String(format: "%.2f Hz", frequency))
                    .font(.title2)

                TuningIndicatorView(cents: note.cents)
                    .frame(height: 100)

                Text(String(format: "%+.2f cents", note.cents))
                    .font(.title3)

            } else {
                Text("...")
                    .font(.system(size: 100, weight: .bold))
            }

            Spacer()

            Text("Singing Bowl Tuner")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct TuningIndicatorView: View {
    let cents: Double
    private let indicatorRange: Double = 50.0 // from -50 to +50 cents

    private func indicatorColor() -> Color {
        let absCents = abs(cents)
        if absCents < 5 {
            return .green
        } else if absCents < 25 {
            return .yellow
        } else {
            return .red
        }
    }

    private func indicatorPosition() -> CGFloat {
        let clampedCents = max(-indicatorRange, min(indicatorRange, cents))
        return CGFloat(clampedCents / indicatorRange)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Background track
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.gray.opacity(0.3))

                // Center line
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(.black.opacity(0.5))

                // Indicator
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(indicatorColor())
                    .frame(width: 6, height: geometry.size.height * 1.2)
                    .offset(x: indicatorPosition() * (geometry.size.width / 2))
                    .animation(.easeInOut, value: cents)
            }
        }
    }
}
