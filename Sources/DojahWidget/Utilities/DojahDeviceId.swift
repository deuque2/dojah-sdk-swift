//
//  DojahDeviceId.swift
//  DojahWidget
//
//  Created by Sunday on 14/12/2025.
//

import Security
import Foundation

final class DojahDeviceId: NSObject {

    private static let service = "io.dojah.widget.deviceid"
    private static let account = "persistent_device_id"

    static func get() -> String {
        if let existing = read() {
            return existing
        }

        let newID = UUID().uuidString
        save(newID)
        return newID
    }

    private static func save(_ value: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // overwrite if exists
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard
            status == errSecSuccess,
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return value
    }
}
