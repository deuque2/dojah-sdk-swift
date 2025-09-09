//
//  AesEncryption.swift
//  DojahWidget
//
//  Created by Sunday on 31/08/2025.
//

import CryptoKit
import Foundation

// Extension for nonce generation (reused from previous implementation)
extension AES.GCM.Nonce {
    static func nonceWithRandomBytes(count: Int) throws -> AES.GCM.Nonce {
            var randomBytes = [UInt8](repeating: 0, count: count)
            let result = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
            guard result == errSecSuccess else {
            fatalError("Failed to generate random bytes for nonce")
        }
            return try AES.GCM.Nonce(data: Data(randomBytes))
        }
    
    var data: Data {
            return withUnsafeBytes { Data($0) }
    }
}

public struct AesEncryption {
    static func deriveKey(from secret: String) -> SymmetricKey {
        // Convert secret to data
    
        let secretData = secret.data(using: .utf8)!
        // Use HKDF to derive a 256-bit key
        let salt = "fixed_salt_12345".data(using: .utf8)! // In production, use random salt and store it
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: secretData),
            salt: salt,
            outputByteCount: 32 // 256-bit key for AES
        )
    }
    
   public static func encrypt(data: String, secret: String) throws -> String {
        let key = deriveKey(from: secret)
        let dataToEncrypt = data.data(using: .utf8)!
        
       do {
           // Generate random IV
           let iv = try AES.GCM.Nonce.nonceWithRandomBytes(count: 12) // 12 bytes for GCM nonce
           let sealedBox = try AES.GCM.seal(dataToEncrypt, using: key, nonce: iv)
           
           // Combine IV and ciphertext, then encode to Base64
           let combined = sealedBox.nonce.data + sealedBox.ciphertext
            return combined.base64EncodedString()
       }catch {
           return ""
       }
    }
}
