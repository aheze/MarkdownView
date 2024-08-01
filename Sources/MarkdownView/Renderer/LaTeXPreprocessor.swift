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
        """#
        process(input: str)
        
        return newInput
    }
    
    // [ $24 + $32 ] (not latex)
    // [ $24 +$ ]32 (is latex)
    // need to be spaces on outside, and no space on inside.
    
    // takes input and adds backticks.
    // if there is a clean snapshot, return it.
    func process(input: String) -> (CleanSnapshot?, String) {
        var cleanSnapshot: CleanSnapshot?
        
        var output = input
        
        do {
            // MARK: - convert $$ -> \[, $ -> \(

            let timer = TimeElapsed()
            let regexDoubleDollar = try NSRegularExpression(pattern: #"\$\$(.*?)\$\$"#, options: [.dotMatchesLineSeparators])
            
            // from https://files.slack.com/files-pri/T7U3XVBLP-F07EJPURN0P/tokenizelatexextensions.js
            // single dollar shouldn't span multiple lines
            let regexSingleDollar = try NSRegularExpression(pattern: #"\$((?:\\.|[^\\\n])*?(?:\\.|[^\\\n$]))\$(?=[\s?!.,:？！。，：)]|$)"#, options: [.dotMatchesLineSeparators])
            
//            output = regexDoubleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\[$1\\]"#)
//            output = regexSingleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\($1\\)"#)
            
            
            
            // For double dollar signs
            let doubleRanges = regexDoubleDollar.matches(in: output, range: NSRange(location: 0, length: output.count)).map { $0.range }
            print("Ranges for double dollar signs: \(doubleRanges)")
            
            // length of string should remain the same, since `\[` and `$$` are both length 2.
            output = regexDoubleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\[$1\\]"#)
            
            print("Before: \(input.count) -> \(output.count)")

            // range in input
            let indexOfClosingSquareOriginal = output.range(of: #"\]"#, options: String.CompareOptions.backwards, range: nil, locale: nil)?.lowerBound
            
            // For single dollar signs
            let singleRanges = regexSingleDollar.matches(in: output, range: NSRange(location: 0, length: output.count)).map { $0.range }
            print("Ranges for single dollar signs: \(singleRanges)")
            output = regexSingleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\($1\\)"#)
            
            print("---")
            
            print("output: \(output)")
            
            let indexOfClosingParenOriginal: String.Index? = {
                let lowerBound = output.range(of: #"\)"#, options: String.CompareOptions.backwards, range: nil, locale: nil)?.lowerBound
                if let lowerBound {
                    
                    // for every match, a character was inserted ($ -> \()
                    // to get index in original, need to offset.
                    let lowerBoundInOriginal = output.index(lowerBound, offsetBy: -singleRanges.count)
                    return lowerBoundInOriginal
                }
                
                return nil
            }()
            
            if let indexOfClosingSquareOriginal {
                print("closing square: \(input[indexOfClosingSquareOriginal ..< input.index(indexOfClosingSquareOriginal, offsetBy: 2)])")
            }
            
            if let indexOfClosingParenOriginal {
                print("closing paren: \(input[indexOfClosingParenOriginal ..< input.index(indexOfClosingParenOriginal, offsetBy: 5)])")
            }
            
            // get the index of the last closing delimiter in the original input.
            // could be $, $$, \), or \].
            
//            var inputStaging = input
//            inputStaging = regexSingleDollar.stringByReplacingMatches(in: inputStaging, range: NSRange(location: 0, length: output.count), withTemplate: #"\$\$1"#)
//            
//            let indexOfClosingParen = output.range(of: #"\)"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
//            let indexOfClosingSquareBracket = output.range(of: #"\]"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
//            print("indexOfClosingParen: \(indexOfClosingParen?.upperBound) vs \(indexOfClosingSquareBracket?.upperBound)")
//            
//            if let indexOfClosingParen {
//                
//            }

//            let maxIndex = [indexOfClosingParen, indexOfClosingSquareBracket].compactMap { $0?.upperBound }.max()
            
            
            // MARK: - surround with backticks

            output = output.replacingOccurrences(of: #"\\\("#, with: #"`\\("#, options: .regularExpression)
            output = output.replacingOccurrences(of: #"\\\["#, with: #"`\\["#, options: .regularExpression)
            output = output.replacingOccurrences(of: "\\)", with: "\\)`", options: .regularExpression)
            output = output.replacingOccurrences(of: "\\]", with: "\\]`", options: .regularExpression)
            print("🌇: \(input)\n\n✅: \(output)")
            
            print("timer: \(timer)")
            
            // MARK: - find last index of closing delimiter
           
//            let indexOfClosingParen = output.range(of: #"\)`"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
//            let indexOfClosingSquareBracket = output.range(of: #"\]`"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
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
