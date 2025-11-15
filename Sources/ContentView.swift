import SwiftUI

struct ContentView: View {
    @StateObject private var audioCaptureEngine = AudioCaptureEngine()

    var body: some View {
        VStack {
            if audioCaptureEngine.permissionGranted {
                TunerView(audioCaptureEngine: audioCaptureEngine)
            } else {
                VStack {
                    Text("Microphone access is required to use this app.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Request Permission") {
                        audioCaptureEngine.setup()
                    }
                }
            }
        }
        .onAppear {
            audioCaptureEngine.setup()
        }
        .onChange(of: audioCaptureEngine.permissionGranted) { granted in
            if granted {
                audioCaptureEngine.start()
            }
        }
        .onDisappear {
            audioCaptureEngine.stop()
        }
    }
}
