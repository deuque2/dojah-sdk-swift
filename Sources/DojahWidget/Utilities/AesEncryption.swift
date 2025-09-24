//
//  AesEncryption.swift
//  DojahWidget
//
//  Created by Sunday on 31/08/2025.
//

import Foundation
import CommonCrypto

struct AesEncryption {
    private static let algorithm = CCAlgorithm(kCCAlgorithmAES128)
    private static let options = CCOptions(kCCOptionPKCS7Padding)
    
    static func encrypt(data: String, secret: String) -> String {
        // Remove the data URL prefix if present (same as Kotlin)
        let cleanedData = data.replacingOccurrences(
            of: "^data:(image|application)/(jpeg|png|pdf);base64,",
            with: "",
            options: .regularExpression
        )
        
        guard let keyData = secret.data(using: .utf8),
              let inputData = cleanedData.data(using: .utf8) else {
            return data
        }
        
        let keyBytes = [UInt8](keyData)
        let inputBytes = [UInt8](inputData)
        
        // Use key as IV (same as Kotlin's IvParameterSpec(key))
        let iv = keyBytes
        
        var encryptedData = [UInt8](repeating: 0, count: inputBytes.count + kCCBlockSizeAES128)
        var numBytesEncrypted = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            algorithm,
            options,
            keyBytes, // Use the key bytes directly, no validation
            keyBytes.count, // Use actual key length
            iv, // IV is the same as key
            inputBytes,
            inputBytes.count,
            &encryptedData,
            encryptedData.count,
            &numBytesEncrypted
        )
        
        if cryptStatus == kCCSuccess {
            let encryptedBytes = encryptedData.prefix(numBytesEncrypted)
            return Data(encryptedBytes).base64EncodedString()
        } else {
            return data
        }
    }
}
