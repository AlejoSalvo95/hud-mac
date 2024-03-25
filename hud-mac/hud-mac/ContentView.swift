import SwiftUI

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

            // Button to trigger hand tracking functionality
            Button("Track New Hand") {
                self.trackNewHand()
            }
            .padding()
            .buttonStyle(.bordered)
        }
    }

    // Function to track a new hand - replace this with actual tracking logic
    func trackNewHand() {
        // Placeholder logic for tracking a new hand
        handsPlayed += 1  // You'll replace this with the actual hand tracking logic later
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
