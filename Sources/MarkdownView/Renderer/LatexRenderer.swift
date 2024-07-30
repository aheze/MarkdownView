//
//  LatexRenderer.swift
//  MarkdownView
//
//  Created by Andrew Zheng on 7/30/24.
//

import Foundation
import MathJaxSwift

enum LatexRenderer {
    static var mathJax: MathJax? = {
        do {
            let mathJax = try MathJax()
            return mathJax
        } catch {
            print("LatexRenderer: Couldn't initialize MathJax. \(error)")
        }
        
        return nil
    }()
}
