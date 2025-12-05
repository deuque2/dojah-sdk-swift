//
//  UIImage+.swift
//
//
//  Created by Isaac Iniongun on 25/10/2023.
//

import UIKit

extension UIImage {

    @available(iOS 17.0, *)
    static func res(_ res: ImageResource) -> UIImage {
        return UIImage(resource: res)
    }

    static func res(_ name: String) -> UIImage {
        let snakeName = name.toKebabCase()

        // ✅ First, always preflight using the safe API
        if let existingImage = UIImage(
            named: snakeName,
            in: DojahBundle.bundle,
            with: nil
        ) {
            // ✅ If on iOS 17+, now safely re-load with ImageResource
            if #available(iOS 17.0, *) {
                let imageResource = ImageResource(name: snakeName, bundle: DojahBundle.bundle)
                return UIImage(resource: imageResource) // ✅ Now guaranteed NOT to crash
            }

            // ✅ For iOS 16 and below
            return existingImage
        }

        // ✅ Absolute fallback (prevents all crashes)
        return UIImage()
    }

    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func withTint(_ color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func withColor(_ color: UIColor) -> UIImage? {
        // ✅ SAFE: Prevent cgImage crash
        guard let maskImage = self.cgImage else {
            return nil
        }

        let bounds = CGRect(origin: .zero, size: size)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        guard let cgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }

    func withSize(_ targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )

        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}
