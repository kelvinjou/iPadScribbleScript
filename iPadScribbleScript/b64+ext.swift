//
//  b64+ext.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import Foundation
import UIKit
extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
