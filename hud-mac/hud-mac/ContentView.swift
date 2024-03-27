import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Foundation

struct ContentView: View {
    @State private var handsPlayed: Int = 0
    @State private var playersData: [String: Double] = [:]
    @State private var playersStartData: [String: Double] = [:]
    @State private var playersNetData: [String: Double] = [:]
    
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
            
            
            Text("Players starting")
                .padding()
            ForEach(playersStartData.keys.sorted(), id: \.self) { key in
                Text("\(key): \(playersStartData[key]!, specifier: "%.2f") in chips")
            }
            
            
            Text("Players final data")
                .padding()
            ForEach(playersData.keys.sorted(), id: \.self) { key in
                Text("\(key): \(playersData[key]!, specifier: "%.2f") in chips")
            }
            Text("Players starting data")
                .padding()
            ForEach(playersNetData.keys.sorted(), id: \.self) { key in
                Text("\(key): \(playersNetData[key]!, specifier: "%.2f") in chips")
            }
            
        }
    }


    private func selectPokerHandFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType.plainText]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                readAndParsePokerHandFile(from: url)
            }
        }
    }


    private func readAndParsePokerHandFile(from url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let firstBlock = trimToFirstBlock(of: content)
            calculatePlayersWonData(from: content)
            calculateFinalResults(from: firstBlock)
         } catch {
            print("Failed to read file: \(error)")
        }
    }

    private func calculatePlayersWonData(from content: String) {
        let lines = content.split(separator: "\n")
        var currentPlayerData: [String: Double] = [:]
        var shouldCollectSeatData = false

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine == "*** SUMMARY ***" {
                shouldCollectSeatData = true
            } else if shouldCollectSeatData && trimmedLine.starts(with: "Seat") {
                let components = trimmedLine.components(separatedBy: ": ")

                if components.count > 1 {
                    let playerInfo = components[1].split(separator: " ")
                    if playerInfo.count >= 3 {
                        let playerName = String(playerInfo[0])
                        if let chipString = playerInfo.first(where: { $0.hasPrefix("($") }) {
                            let cleanedChipString = chipString
                                .replacingOccurrences(of: "($", with: "")
                                .replacingOccurrences(of: ")", with: "")

                            if let chipAmount = Double(cleanedChipString) {
                                currentPlayerData[playerName] = chipAmount
                            }
                        }
                    }
                }
            } else if line.contains(": calls ") || line.contains(": bets ") || line.contains(": raises ") {
                let actionComponents = trimmedLine.components(separatedBy: ": ")
                if actionComponents.count > 1 {
                    let actionInfo = actionComponents[1].split(separator: " ")
                    if let playerName = actionComponents.first, let actionAmountString = actionInfo.last {
                        let cleanedActionAmountString = actionAmountString
                            .replacingOccurrences(of: "$", with: "")
                            .trimmingCharacters(in: .whitespaces)

                        if let actionAmount = Double(cleanedActionAmountString) {
                             if var existingAmount = currentPlayerData[playerName] {
                                existingAmount -= actionAmount
                                currentPlayerData[playerName] = existingAmount
                            }
                        }
                    }
                }
            } else if trimmedLine.isEmpty {
                shouldCollectSeatData = false
            }
        }
        self.playersData = currentPlayerData
    }
    
    
    private func calculateFinalResults(from content: String) {
        let lines = content.split(separator: "\n")
        var playerStartChips: [String: Double] = [:]

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.contains("($") && trimmedLine.contains(" in chips)") {
                let components = trimmedLine.components(separatedBy: ": ")
                if let playerInfo = components.last?.split(separator: " "), playerInfo.count >= 3 {
                    let playerName = String(playerInfo[0])
                    if let chipString = playerInfo.first(where: { $0.hasPrefix("($") }) {
                        let cleanedChipString = chipString
                            .replacingOccurrences(of: "($", with: "")
                            .replacingOccurrences(of: ")", with: "")
                        if let chipAmount = Double(cleanedChipString) {
                            playerStartChips[playerName] = chipAmount
                        }
                    }
                }
            }
        }
        self.playersStartData = playerStartChips
        var netResults: [String: Double] = [:]
        for (player, startChips) in playerStartChips {
            if let endChips = self.playersData[player] {
                print(endChips, player)
                let netResult = endChips - startChips
                netResults[player] = netResult
            } else {
                print("Data not found for player:", player)
            }
        }
        self.playersNetData = netResults
    }

    func trimToFirstBlock(of content: String) -> String {
        if let range = content.range(of: "\n\n\n", options: .literal) {
            let firstBlock = content[..<range.lowerBound]
            return String(firstBlock)
        }
        return content  // Return the whole content if no additional blocks are found
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
