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
        var inputMaxIndex: String.Index
        var outputMaxIndex: String.Index
        var inputSubstring: Substring
        var outputSubstring: Substring
    }
    
    // store the already processed string
    // this should be completely clean, e.g. all latex ranges are closed.
    var cleanSnapshot: CleanSnapshot?
    
    // processes input incrementally, with caching, to prevent going through the whole string over and over again
    func processIncrementally(input: String) -> String {
        let (cleanOutput, rawInput): (String, String) = {
            if let cleanSnapshot = self.cleanSnapshot {
                let cleanOutput = String(cleanSnapshot.outputSubstring)
                let rawInput = String(input[cleanSnapshot.inputMaxIndex ..< input.endIndex])
                return (cleanOutput, rawInput)
            }
            
            // no snapshot yet, so process the whole input.
            return ("", input)
        }()

        let (cleanSnapshot, output) = process(input: rawInput)
        if let cleanSnapshot {
            if let existingCleanSnapshot = self.cleanSnapshot {
                // append to the existing
                self.cleanSnapshot = CleanSnapshot(
                    inputMaxIndex: existingCleanSnapshot.inputSubstring.index(existingCleanSnapshot.inputMaxIndex, offsetBy: cleanSnapshot.inputMaxIndex.utf16Offset(in: rawInput)),
                    outputMaxIndex: existingCleanSnapshot.outputSubstring.index(existingCleanSnapshot.outputMaxIndex, offsetBy: cleanSnapshot.outputMaxIndex.utf16Offset(in: cleanSnapshot.outputSubstring)),
                    inputSubstring: existingCleanSnapshot.inputSubstring + cleanSnapshot.inputSubstring,
                    outputSubstring: existingCleanSnapshot.outputSubstring + cleanSnapshot.outputSubstring
                )
            } else {
                self.cleanSnapshot = cleanSnapshot
            }
        }
        
        let finalOutput = cleanOutput + output
        return finalOutput
    }
    
    // [ $24 + $32 ] (not latex)
    // [ $24 +$ ]32 (is latex)
    // need to be spaces on outside, and no space on inside.
    
    // takes input and adds backticks.
    // if there is a clean snapshot, return it.
    
    // regex from https://files.slack.com/files-pri/T7U3XVBLP-F07EJPURN0P/tokenizelatexextensions.js (single dollar shouldn't span multiple lines)
    func process(input: String) -> (CleanSnapshot?, String) {
        var inputCopy = input
        var cleanSnapshot: CleanSnapshot?
        var output = input
        
        do {
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
            
            // MARK: - find last index of closing delimiter
           
            let inputClosingDollar = inputCopy.range(of: singleDollarReplacement, options: String.CompareOptions.backwards, range: nil, locale: nil)
            let inputClosingParen = inputCopy.range(of: #"\)"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            let inputClosingSquareBracket = inputCopy.range(of: #"\]"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            
            let outputClosingParen = output.range(of: #"\)`"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            let outputClosingSquareBracket = output.range(of: #"\]`"#, options: String.CompareOptions.backwards, range: nil, locale: nil)
            
            let inputMaxIndex = [inputClosingDollar, inputClosingParen, inputClosingSquareBracket].compactMap { $0?.upperBound }.max()
            let outputMaxIndex = [outputClosingParen, outputClosingSquareBracket].compactMap { $0?.upperBound }.max()
            
            if let inputMaxIndex, let outputMaxIndex {
                cleanSnapshot = CleanSnapshot(
                    inputMaxIndex: inputMaxIndex,
                    outputMaxIndex: outputMaxIndex,
                    inputSubstring: input[input.startIndex ..< inputMaxIndex],
                    outputSubstring: output[output.startIndex ..< outputMaxIndex]
                )
            }
            
        } catch {
            print("Error creating regex: \(error)")
        }
        
        return (cleanSnapshot, output)
    }
}
