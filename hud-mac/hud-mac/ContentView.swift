import SwiftUI
import AppKit

struct ContentView: View {
    @State private var handsPlayed: Int = 0

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()

            Text("Hands Played: \(handsPlayed)")
                .font(.title)
                .padding()

            Button("Select Hands Directory") {
                selectHandsDirectory()
            }
            .padding()
            .buttonStyle(.bordered)
        }
    }

    private func selectHandsDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                countHandsPlayed(in: url)
            }
        }
    }

    private func countHandsPlayed(in directory: URL) {
        let fileManager = FileManager.default
        do {
            let items = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            handsPlayed = items.count
        } catch {
            print("Failed to count files: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
