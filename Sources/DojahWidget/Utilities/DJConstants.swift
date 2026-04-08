//
//  DJConstants.swift
//
//
//  Created by Isaac Iniongun on 27/10/2023.
//

import Foundation

enum DJConstants {
    static let genericErrorMessage = "An error occured. Try again later"
    static let disclaimerItems = [
        "You must be in a well lit environment before getting started.",
        "Avoid wearing anything that hinders or hides your face from being seen.",
        "All parts of your identification must be shown properly and must be clear"
    ]
    
    static let idCaptureDisclaimerItems = [
        "Please take a moment to review the captured image to ensure it is clear and readable.",
        "Make sure the entire document or ID card is fully visible within the frame.",
        "Look out for any reflections that could obstruct the document’s visibility."
    ]
    
    static let selfieCaptureDisclaimerItems = [
        "Please take a moment to review the captured image to ensure it is clear.",
        "If the image is blurry or dark, you may retake the photo by pressing the designated button.",
        "If you are satisfied with the captured image, proceed to the next step to continue with the verification process."
    ]
    
    static let locationDisclaimerItems = [
        "To ensure the security and integrity of your account, we request access to your device's location for:",
        "Location address and IP address for a successful verification",
        "Your privacy and security are our top priorities.",
        "Location data is encrypted and will only be used for verification and security purposes."
    ]
    
    static let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    static let monthDays = Array(1...31)
    
    static let years = Array(1900...current(.year)).reversed()
    
    static let dateFormat = "dd-MM-yyyy"
    
}
