//
//  ViewController.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/7/21.
//

import UIKit
import NaturalLanguage
import CoreML

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NLTagger.findProduct("Apple Pay Apple")
    }


}

extension NLTagScheme {
    static let ingredients = NLTagScheme.init("ingredients")
}

extension NLTagger {
    static func findProduct(_ text: String) {
        // 1
        let productTag = NLTag("PROD")
        
        // 2
        let modelURL = Bundle.main.url(forResource: "ProductTagger", withExtension: "mlmodelc")!
        let productTaggerModel = try! NLModel(contentsOf: modelURL)
        
        // 3
        let productTagger = NLTagger(tagSchemes: [.ingredients])
        productTagger.setModels([productTaggerModel], forTagScheme: .ingredients)
        
        // 4
        productTagger.string = text
        
        
        productTagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .ingredients, options: []) { (tag, tokenRange) -> Bool in
            if tag == productTag {
                print("thond \(text[tokenRange])")
            }
            return true
        }
    }
    
    static func findProduct2(_ text: String) {
        do {
            let mlModel = try ProductTagger(configuration: MLModelConfiguration()).model
            
            let customModel = try NLModel(mlModel: mlModel)
            
            let customTagScheme = NLTagScheme("Apple")
            
            let tagger = NLTagger(tagSchemes: [.nameType, customTagScheme])
            tagger.string = text
            tagger.setModels([customModel], forTagScheme: customTagScheme)
            
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word,
                                 scheme: customTagScheme, options: .omitWhitespace) { tag, tokenRange  in
                if tag == NLTag.init("PROD") {
                    print("thond \(text[tokenRange]): \(tag?.rawValue)")
                }
                return true
            }
        } catch {
            print(error)
        }
    }
}
