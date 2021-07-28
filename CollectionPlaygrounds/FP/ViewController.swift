//
//  ViewController.swift
//  FP
//
//  Created by Nguyễn Đức Thọ on 7/28/21.
//

import UIKit
import SnapKit

precedencegroup ForwardPipe {
    associativity: left
    higherThan: TernaryPrecedence
    lowerThan: LogicalDisjunctionPrecedence
}

infix operator |> : ForwardPipe

public func |> <T, U>(data: T, fn: (T) -> U) -> U {
    return fn(data)
}


precedencegroup AssignmentTrue {
    associativity: left
}
infix operator >>>: AssignmentTrue
func >>> (filter1:@escaping Filter, filter2:@escaping Filter) -> Filter {
    return { img in
        filter2(filter1(img))
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: "http://tinyurl.com/m74sldb")!;
        let image = CIImage(contentsOf: url)
        let blurRadius = 5.0
        let overlayColor = UIColor.white//.withAlphaComponent(0.8)
        let result = image?
            .blur(radius: blurRadius)
            .colorOverlay(color: overlayColor)
        let imageView = UIImageView.init(image: UIImage.init(ciImage: result!))
        self.view.addSubview(imageView)
        imageView.frame = CGRect.init(x: 0, y: 0, width: 200, height: 300)
        imageView.contentMode = .scaleAspectFill
        
        
       // let result2 = colorOverlay(color: overlayColor)(blur(radius: blurRadius)(image!))
        
        let myFilter2 = blur(radius: blurRadius) >>> colorOverlay(color: overlayColor)
        let result2 = myFilter2(image!)
        
        
        let imageView2 = UIImageView.init(image: UIImage.init(ciImage: result2))
        self.view.addSubview(imageView2)
        imageView2.frame = CGRect.init(x: 0, y: 320, width: 200, height: 300)
        imageView2.contentMode = .scaleAspectFill

    }

    func blur(radius: Double) -> Filter { return { image in
        let parameters = [ kCIInputRadiusKey: radius, kCIInputImageKey: image
        ] as [String : Any]
        let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters)
        return (filter?.outputImage)! }
    }

    func colorGenerator(color: UIColor) -> Filter { return { image in
        let parameters = [kCIInputColorKey: color]
        let filter = CIFilter(name: "CIConstantColorGenerator",
                              parameters: parameters)
        return filter?.outputImage ?? image
    } }
    
    func compositeSourceOver(overlay: CIImage) -> Filter { return { image in
    let parameters = [ kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay
    ]
    let filter = CIFilter(name: "CISourceOverCompositing",
                          parameters: parameters); let cropRect = image.extent
        return (filter?.outputImage!.cropped(to: cropRect))! }
    }
    
    
    func colorOverlay(color: UIColor) -> Filter { return { image in
        let overlay = self.colorGenerator(color: color)(image)
        return self.compositeSourceOver(overlay: overlay)(image) }
    }


}


