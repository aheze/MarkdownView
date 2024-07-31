import Markdown
import SwiftUI

// MARK: - Inline Code Block

extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
      
        if inlineCode.code.hasPrefix("$") && inlineCode.code.hasSuffix("$") {
            print("inline latex ($ syntax)")
            
            let latex = String(inlineCode.code.dropFirst().dropLast())
            
            do {
                let image = try LatexRenderer.renderImage(latexString: latex)
                return Result(SwiftUI.Text(image))
            } catch {
                print("Error: \(error)")
            }
            
            let image = Image(systemName: "plus")
            return Result(SwiftUI.Text("Here is an image: \(image)"))
        }
        
        if inlineCode.code.hasPrefix(#"\("#) && inlineCode.code.hasSuffix(#"\)"#) {
            print("inline latex")
            return Result(SwiftUI.Text(attributedString))
        }
        
        if inlineCode.code.hasPrefix("$$") && inlineCode.code.hasSuffix("$$") {
            print("block latex ($$ syntax)")
            return Result(SwiftUI.Text(attributedString))
        }
        
        if inlineCode.code.hasPrefix(#"\["#) && inlineCode.code.hasSuffix(#"\["#) {
            print("block latex")
            return Result(SwiftUI.Text(attributedString))
        }
        
        attributedString.foregroundColor = configuration.inlineCodeTintColor
        attributedString.backgroundColor = configuration.inlineCodeTintColor.opacity(0.1)
        return Result(SwiftUI.Text(attributedString))
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        Result(SwiftUI.Text(inlineHTML.rawHTML))
    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            #if os(watchOS) || os(tvOS)
            SwiftUI.Text(codeBlock.code)
            #else
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code,
                theme: configuration.codeBlockTheme
            )
            #endif
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        // Forced conversion of text to view
        Result {
            SwiftUI.Text(html.rawHTML)
        }
    }
}
