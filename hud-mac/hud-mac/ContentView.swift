import SwiftUI
import Foundation

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

            Button("Track New Hand") {
                self.trackNewHand()
            }
            .padding()
            .buttonStyle(.bordered)
        }
        .onAppear {
            self.countHandsPlayed()
        }
    }

    func countHandsPlayed() {
        let fileManager = FileManager.default
        let path = ConfigManager.readPathFromPlist() ?? ""
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            handsPlayed = items.count
        } catch {
            print("Failed to count files: \(error)")
        }
        
    }
    
    func trackNewHand() {
        handsPlayed += 1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
