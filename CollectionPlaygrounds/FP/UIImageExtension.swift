//
//  UIImageExtension.swift
//  FP
//
//  Created by Nguyễn Đức Thọ on 7/28/21.
//

import UIKit

typealias Filter = (CIImage) -> CIImage

extension CIImage {
    func blur(radius: Double) -> CIImage {
        let parameters = [ kCIInputRadiusKey: radius, kCIInputImageKey: self
        ] as [String : Any] as [String : Any]
        let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters)
        return filter?.outputImage ?? self
    }
    
    func colorGenerator(color: UIColor) -> CIImage {
        let parameters = [kCIInputColorKey: color]
        let filter = CIFilter(name: "CIConstantColorGenerator",
                              parameters: parameters)
        return filter?.outputImage ?? self
    }
    
    func compositeSourceOver(overlay: CIImage) -> CIImage {
        let parameters = [ kCIInputBackgroundImageKey: self, kCIInputImageKey: overlay
        ]
        let filter = CIFilter(name: "CISourceOverCompositing",
                              parameters: parameters)
        let cropRect = self.extent
        return filter?.outputImage?.cropped(to: cropRect) ?? self
    }

    func colorOverlay(color: UIColor) -> CIImage {
        let overlay = self.colorGenerator(color: color)
        return self.compositeSourceOver(overlay: overlay)
    }
}
