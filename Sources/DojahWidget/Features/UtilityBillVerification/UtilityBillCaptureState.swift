
import Foundation

enum UtilityBillCaptureState {
    case capture, upload, preview
    
    var title: String {
        switch self {
        case .upload:
            return "Upload Utility Bill"
    
        case .capture:
            return "Capture Utility Bill"
        case .preview:
            return "Preview"
        }
    }
    
    var primaryButtonTitle: String {
        switch self {
        case .upload:
            return "Upload"
        case .capture:
            return "Capture"
        case .preview:
            return "Continue"
        }
    }
    
    var secondaryButtonTitle: String {
        switch self {
        case .upload:
            return "Capture Instead"
        case .capture:
            return "Upload Instead"
        case .preview:
            return "Retake"
        }
    }
}
