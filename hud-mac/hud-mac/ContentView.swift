import SwiftUI
import AppKit

struct ContentView: View {
    @State private var handsPlayed: Int = 0
    @State private var playersData: [String: Double] = [:]

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()

            Text("Hands Played: \(handsPlayed)")
                .font(.title)
                .padding()

            Button("Select Poker Hand File") {
                selectPokerHandFile()
            }
            .padding()
            .buttonStyle(.bordered)

            ForEach(playersData.keys.sorted(), id: \.self) { key in
                Text("\(key): \(playersData[key]!, specifier: "%.2f") in chips")
            }
        }
    }

    private func selectPokerHandFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["txt"]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                readAndParsePokerHandFile(from: url)
            }
        }
    }

    private func readAndParsePokerHandFile(from url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            parsePlayerData(from: content)
        } catch {
            print("Failed to read file: \(error)")
        }
    }

    private func parsePlayerData(from content: String) {
         let lines = content.split(separator: "\n")
         var currentPlayerData: [String: Double] = [:]
         var shouldCollectSeatData = false

         for line in lines {
             if line.trimmingCharacters(in: .whitespacesAndNewlines) == "*** SUMMARY ***" {
                 print("sum sum")
                 shouldCollectSeatData = true
             } else if shouldCollectSeatData && line.starts(with: "Seat") {
                 let components = line.components(separatedBy: ": ")

                 if components.count > 1 {
                     let playerInfo = components[1].split(separator: " ")
                     print("playerInfo",playerInfo)
                     if playerInfo.count >= 3 {
                         let playerName = String(playerInfo[0])
                         if let chipString = playerInfo.first(where: { $0.hasPrefix("($") }) {
                             let cleanedChipString = chipString
                                 .replacingOccurrences(of: "($", with: "")
                                 .replacingOccurrences(of: ")", with: "")
                             

                             if let chipAmount = Double(cleanedChipString) {
                                 if let existingAmount = currentPlayerData[playerName] {
                                     currentPlayerData[playerName] = existingAmount + chipAmount
                                 } else {
                                     currentPlayerData[playerName] = chipAmount
                                 }
                                 print("currentPlayerData", currentPlayerData)
                             }

                         }
                     }
                 }
             } else if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                 shouldCollectSeatData = false  // Reset flag at the end of a block
             }
         }

         DispatchQueue.main.async {
             self.playersData = currentPlayerData
         }
     }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
