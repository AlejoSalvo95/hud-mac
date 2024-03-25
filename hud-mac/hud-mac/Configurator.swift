//
//  Configurator.swift
//  hud-mac
//
//  Created by Alejo Salvo on 25/03/2024.
//

import Foundation

struct ConfigManager {
    static func readPathFromPlist() -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Error reading plist")
            return nil
        }

        return dict["path"] as? String
    }
}
