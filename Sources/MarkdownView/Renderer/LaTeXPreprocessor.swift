//
//  LaTeXPreprocessor.swift
//  MarkdownView
//
//  Created by Andrew Zheng on 7/31/24.
//

import SwiftUI

// add backticks around LaTeX, which is necessary for the Markdown parser.
// $\sqrt{4}$ -> `$\sqrt{4}$`

class LaTeXPreprocessor: ObservableObject {
    // latex formats:
    // `$$ ... $$`
    // $ ... $
    // \( ... \)
    // \[ ... \]
    
    struct CleanSnapshot {
        var input: String = ""
        var output: String = ""
    }
    
    // store the already processed string
    // this should be completely clean, e.g. all latex ranges are closed.
    var cleanSnapshot = CleanSnapshot()
    
    // processes input incrementally, with caching, to prevent going through the whole string over and over again
    func process(newInput: String) -> String {
        // get the newly added string
        // ex. cleanSnapshot is "Hello"
        // `string` is "Hello World"
        // addedSubstring is " World"
        let newAddition = newInput.dropFirst(cleanSnapshot.input.count)
        
        print("newAddition: \(newAddition)")
        
        let cleanSnapshot = CleanSnapshot(input: newInput, output: newInput)
        self.cleanSnapshot = cleanSnapshot
        
        return newInput
    }
    
    enum LaTeXOpenDelimiter {
        case singleDollar
        case doubleDollar
        case openParenthesis
        case openSquareBracket
    }
    
    // [ $24 + $32 ] (not latex)
    // [ $24 +$ ]32 (is latex)
    // need to be spaces on outside, and no space on inside.
    
    // takes input and adds backticks.
    // if there is a clean snapshot, return it.
    func process(input: String) -> (CleanSnapshot?, String) {
        var openDelimiter: LaTeXOpenDelimiter?
        var currentLaTeXRun = ""
        
        
        var cleanSnapshot: CleanSnapshot?
        var output = ""
        
        let arr = Array(input)
        for char in arr {
            
            if let openDelimiter {
                currentLaTeXRun.append(char)
            }
            
            switch char {
            case "$":
                
                
                if let openDelimiter {
                    if openDelimiter == .singleDollar {
                        if currentLaTeXRun.isEmpty {
                            // $$ (opening)
                            openDelimiter = .doubleDollar
                        } else {
                            // $...$ (this is the closing)
                            openDelimiter = nil
                        }
                    }
                }
                break
            case "\\":
                break
            case "(":
                break
            case "[":
                break
            case ")":
                break
            case "]":
                break
            default:
                output.append(char)
            }
            
            
        }
        
        return (cleanSnapshot, output)
    }
    
//    if inlineCode.code.hasPrefix("$$") && inlineCode.code.hasSuffix("$$") {
//        return String(inlineCode.code.dropFirst(2).dropLast(2))
//    }
//
//    if inlineCode.code.hasPrefix("$") && inlineCode.code.hasSuffix("$") {
//        return String(inlineCode.code.dropFirst().dropLast())
//    }
//
//    if inlineCode.code.hasPrefix(#"\("#) && inlineCode.code.hasSuffix(#"\)"#) {
//        return String(inlineCode.code.dropFirst(2).dropLast(2))
//    }
//
//    if inlineCode.code.hasPrefix(#"\["#) && inlineCode.code.hasSuffix(#"\]"#) {
//        return String(inlineCode.code.dropFirst(2).dropLast(2))
//    }
}
