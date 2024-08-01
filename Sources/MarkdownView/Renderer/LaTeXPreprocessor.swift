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
        
        process(input: "")
        
        return newInput
    }
    
    // [ $24 + $32 ] (not latex)
    // [ $24 +$ ]32 (is latex)
    // need to be spaces on outside, and no space on inside.
    
    // takes input and adds backticks.
    // if there is a clean snapshot, return it.
    func process(input _: String) -> (CleanSnapshot?, String) {
        var cleanSnapshot: CleanSnapshot?
        
//        let input = #"""
//        # test.tex
//        \begin{document}
//
//        This is a doc with $math$ in it. $ W o
//        W linebreak $
//
//        Now we have the following \[ offset equation \]
//
//        Now we have another $$
//        offset equation
//        $$ why would you use this one though
//
//        How much would $4 in 1900 be worth now? Answer: $149.61
//
//        \end{document}
//        """#
        
        let input = #"""
        This is a doc with $math$ in it.
        
        How much would $4 in 1900 be worth now? Answer: $149.61
        
        This is a doc with $math$ in it. $ W o
        W linebreak $

        Now we have the following \[ offset equation \]

        Now we have another $$
        offset equation
        $$ why would you use this one though
        """#
        
        var output = input
        
        do {
            let regexDoubleDollar = try NSRegularExpression(pattern: #"\$\$(.*?)\$\$"#, options: [.dotMatchesLineSeparators])
            // from https://files.slack.com/files-pri/T7U3XVBLP-F07EJPURN0P/tokenizelatexextensions.js
            
            // single dollar shouldn't span multiple lines
            let regexSingleDollar = try NSRegularExpression(pattern: #"\$((?:\\.|[^\\\n])*?(?:\\.|[^\\\n$]))\$(?=[\s?!.,:？！。，：)]|$)"#, options: [.dotMatchesLineSeparators])
            
            output = regexDoubleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\[$1\\]"#)
            output = regexSingleDollar.stringByReplacingMatches(in: output, range: NSRange(location: 0, length: output.count), withTemplate: #"\\($1\\)"#)
            
            output = output.replacingOccurrences(of: #"\\\("#, with: #"`\\("#, options: .regularExpression)
            output = output.replacingOccurrences(of: #"\\\["#, with: #"`\\["#, options: .regularExpression)
            output = output.replacingOccurrences(of: "\\)", with: "\\)`", options: .regularExpression)
            output = output.replacingOccurrences(of: "\\]", with: "\\]`", options: .regularExpression)
            print("🌇: \(input)\n\n✅: \(output)")
            
        } catch {
            print("Error creating regex: \(error)")
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
