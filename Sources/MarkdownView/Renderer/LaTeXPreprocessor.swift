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
        
//        print("newAddition: \(newAddition)")
        
        let cleanSnapshot = CleanSnapshot(input: newInput, output: newInput)
        self.cleanSnapshot = cleanSnapshot
        
//        let str = #"""
//        This is a doc with $math$ in it. $ W o
//        W linebreak $
//
//        Now we have the following \[ offset equation \]
//
//        Now we have another $$
//        offset equation
//        $$ why would you use this one though
//        """#
        let str = #"""
        This is a doc with $math$ in it. $4 + $5
        
        $$long string$$
        
        Some more text
        """#
        process(input: str)
        
        return newInput
    }
    
    // [ $24 + $32 ] (not latex)
    // [ $24 +$ ]32 (is latex)
    // need to be spaces on outside, and no space on inside.
    
    // takes input and adds backticks.
    // if there is a clean snapshot, return it.
    
    // regex from https://files.slack.com/files-pri/T7U3XVBLP-F07EJPURN0P/tokenizelatexextensions.js (single dollar shouldn't span multiple lines)
    func process(input: String) -> (CleanSnapshot?, String) {
        var cleanSnapshot: CleanSnapshot?
        
        var inputCopy = input
        
        var output = input
        
        do {
            let timer = TimeElapsed()
            
            let singleDollarReplacement = "᎒"
            
            let regexDoubleDollar = try NSRegularExpression(pattern: #"\$\$(.*?)\$\$"#, options: [.dotMatchesLineSeparators])
            let regexSingleDollar = try NSRegularExpression(pattern: #"\$((?:\\.|[^\\\n])*?(?:\\.|[^\\\n$]))\$(?=[\s?!.,:？！。，：)]|$)"#, options: [.dotMatchesLineSeparators])
            
            // MARK: - convert $$ -> \[, $ -> \(
            
            // For double dollar signs
            output = regexDoubleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\[$1\\]"#)
            output = regexSingleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\($1\\)"#)
            
            inputCopy = regexDoubleDollar.stringByReplacingMatches(in: inputCopy, range: NSRange(location: 0, length: inputCopy.count), withTemplate: #"\\[$1\\]"#)
            inputCopy = regexSingleDollar.stringByReplacingMatches(in: inputCopy, range: NSRange(location: 0, length: inputCopy.count), withTemplate: singleDollarReplacement + "$1" + singleDollarReplacement) // keep same width with rare unicode char
            
            // MARK: - surround with backticks

            output = output.replacingOccurrences(of: #"\\\("#, with: #"`\\("#, options: .regularExpression)
            output = output.replacingOccurrences(of: #"\\\["#, with: #"`\\["#, options: .regularExpression)
            output = output.replacingOccurrences(of: "\\)", with: "\\)`", options: .regularExpression)
            output = output.replacingOccurrences(of: "\\]", with: "\\]`", options: .regularExpression)
            print("🌇: \(input)\n\n✅: \(output)")
            
            print("timer: \(timer)")
            
            // MARK: - find last index of closing delimiter
           
            let inputClosingDollar = inputCopy.range(of: singleDollarReplacement, options: String.CompareOptions.backwards, range: nil, locale: nil)
            let inputClosingParen = inputCopy.range(of: #"\)"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            let inputClosingSquareBracket = inputCopy.range(of: #"\]"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            
            let outputClosingParen = output.range(of: #"\)`"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            let outputClosingSquareBracket = output.range(of: #"\]`"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            
            let inputMaxIndex = [inputClosingDollar, inputClosingParen, inputClosingSquareBracket].compactMap { $0?.upperBound }.max()
            let outputMaxIndex = [outputClosingParen, outputClosingSquareBracket].compactMap { $0?.upperBound }.max()
            
            print("inputMaxIndex: \(inputMaxIndex), \(outputMaxIndex)")
            
            print("-------")
            if let inputMaxIndex, let outputMaxIndex {
                print("[\(input[input.startIndex..<inputMaxIndex])] ... [\(output[output.startIndex..<outputMaxIndex])]")
            }
            
//            print("indexOfClosingParen: \(indexOfClosingParen?.upperBound) vs \(indexOfClosingSquareBracket?.upperBound)")
//
//            let maxIndex = [indexOfClosingParen, indexOfClosingSquareBracket].compactMap { $0?.upperBound }.max()
//            if let maxIndex {
//                // find the max index in the original string
//                let indexOfDollarOriginal = input.range(of: #"\)"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
//                let indexOfClosingParenOriginal = input.range(of: #"\)"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
//                let indexOfClosingSquareBracketOriginal = input.range(of: #"\]"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
//
//
            ////                let substring = input[input.startIndex ..< maxIndex]
            ////                cleanSnapshot = CleanSnapshot(input: <#T##String#>, output: substring)
//            }
        } catch {
            print("Error creating regex: \(error)")
        }
        
        return (cleanSnapshot, output)
    }
}
