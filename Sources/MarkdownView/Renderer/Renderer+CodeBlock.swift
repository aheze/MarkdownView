import Markdown
import SwiftUI

// MARK: - Inline Code Block

extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
      
        let latexString: String? = {
            if inlineCode.code.hasPrefix("$$") && inlineCode.code.hasSuffix("$$") {
                return String(inlineCode.code.dropFirst(2).dropLast(2))
            }
            
            if inlineCode.code.hasPrefix("$") && inlineCode.code.hasSuffix("$") {
                return String(inlineCode.code.dropFirst().dropLast())
            }
            
            if inlineCode.code.hasPrefix(#"\("#) && inlineCode.code.hasSuffix(#"\)"#) {
                return String(inlineCode.code.dropFirst(2).dropLast(2))
            }
            
            if inlineCode.code.hasPrefix(#"\["#) && inlineCode.code.hasSuffix(#"\]"#) {
                return String(inlineCode.code.dropFirst(2).dropLast(2))
            }
            
            return nil
        }()
        
        if let latexString {
            let svgImageScale = configuration.svgImageScale * configuration.svgImageScaleMultiplier
            
            do {
                let image = try LatexRenderer.renderImage(
                    latexString: latexString,
                    svgImageScale: svgImageScale
                )
                .renderingMode(.template)
                
                return Result(SwiftUI.Text(image).foregroundColor(.primary))
            } catch {
                print("Inline LaTeX error: \(error)")
            }
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
