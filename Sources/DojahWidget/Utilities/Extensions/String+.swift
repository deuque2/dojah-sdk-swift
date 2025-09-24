//
//  String+.swift
//
//
//  Created by Isaac Iniongun on 25/10/2023.
//

import CryptoKit
import Foundation
import UIKit

extension String {
    subscript(start: Int, end: Int) -> Substring {
        let startPos = index(startIndex, offsetBy: start)
        let endPos: String.Index
        if end > 0 {
            endPos = index(startIndex, offsetBy: end)
        } else {
            endPos = index(endIndex, offsetBy: end)
        }
        return self[startPos...endPos]
    }

    subscript(pos: Int) -> Character {
        if pos > 0 {
            return self[index(startIndex, offsetBy: pos)]

        }
        return self[index(endIndex, offsetBy: pos)]
    }

    var isNumber: Bool {
        
        rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    var isNotNumber: Bool { !isNumber }

    func chunkFormatted(
        withChunkSize chunkSize: Int = 4,
        withSeparator separator: Character = " "
    ) -> String {
        return self.filter { $0 != separator }.chunk(n: chunkSize).map {
            String($0)
        }.joined(separator: String(separator))
    }
    
    func encrypted() -> String? {
        let ENC_SECRET = "6543210987654321"
        
        return AesEncryption.encrypt(data: self, secret: ENC_SECRET)
    }

    func formatWith234() -> String {
        var value = self
        value.replaceSubrange(value.startIndex...value.startIndex, with: "+234")
        return value
    }

    var remove234: String {
        return self.replacingOccurrences(of: "+234", with: "0")
    }

    func removePhoneCode() -> String {
        if hasPrefix("234") {
            return replaceFirstOccurrence(of: "234", with: "")
        } else if hasPrefix("233") {
            return replaceFirstOccurrence(of: "233", with: "")
        } else if hasPrefix("254") {
            return replaceFirstOccurrence(of: "254", with: "")
        } else if hasPrefix("225") {
            return replaceFirstOccurrence(of: "225", with: "")
        } else if hasPrefix("256") {
            return replaceFirstOccurrence(of: "256", with: "")
        } else {
            return replacingOccurrences(of: "+234", with: "")
                .replacingOccurrences(of: "+233", with: "")
                .replacingOccurrences(of: "+254", with: "")
                .replacingOccurrences(of: "+225", with: "")
                .replacingOccurrences(of: "+256", with: "")
        }
    }

    func replaceFirstOccurrence(of target: String, with replaceString: String)
        -> String
    {
        if let range = range(of: target) {
            return replacingCharacters(in: range, with: replaceString)
        }
        return self
    }

    var orDash: String {
        return self.isEmpty ? "-" : self
    }

    var orEmpty: String {
        return self.isEmpty ? "" : self
    }

    func copyToClipboard() {
        UIPasteboard.general.string = self
    }

    var int: Int? { Int(self) }

    var float: Float? { Float(self) }

    var double: Double? { Double(self) }

    var dropFirstIfZero: String {
        if first == "0" {
            return String(dropFirst())
        }
        return self
    }

    var jsonBundleURL: URL? {
        DojahBundle.bundle.url(forResource: self, withExtension: "json")
    }

    func insensitiveEquals(_ other: String) -> Bool {
        localizedCaseInsensitiveCompare(other) == .orderedSame
    }

    func insensitiveNotEquals(_ other: String) -> Bool {
        !insensitiveEquals(other)
    }

    func insensitiveContains(_ other: String) -> Bool {
        localizedCaseInsensitiveContains(other)
    }

    func insensitiveNotContains(_ other: String) -> Bool {
        !insensitiveContains(other)
    }

    var currencySignRemoved: String {
        replacingOccurrences(of: "", with: "")
    }

    var amountSanitized: String {
        commasRemoved.currencySignRemoved
    }

    func amountSanitized(symbol: String) -> String {
        spacesRemoved.commasRemoved.replacingOccurrences(of: symbol, with: "")
    }

    var whitespacesAndBNewlinesRemoved: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var digitsRemoved: String {
        components(separatedBy: .decimalDigits).joined()
    }

    var whitespacesAndNewlinesRemoved: String {
        trimmingCharacters(in: .whitespacesAndNewlines).spacesRemoved
    }

    var spacesRemoved: String { replacingOccurrences(of: " ", with: "") }

    var dashesRemoved: String { replacingOccurrences(of: "-", with: "") }

    var commasRemoved: String { replacingOccurrences(of: ",", with: "") }

    var isCamelCase: Bool {
        let camelCasePattern = "^[a-z][a-zA-Z0-9]*$"
        let camelCaseRegex = try? NSRegularExpression(pattern: camelCasePattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return camelCaseRegex?.firstMatch(in: self, options: [], range: range)
            != nil
    }

    // Function to convert a camel case string to kebab case
    func toKebabCase() -> String {
        guard isCamelCase else {
            return self
        }

        let kebabCaseString =
            self
            .replacingOccurrences(
                of: "([a-z])([A-Z])",
                with: "$1-$2",
                options: .regularExpression,
                range: nil
            )
            .lowercased()

        return kebabCaseString
    }

}
