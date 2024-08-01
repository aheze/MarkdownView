import SwiftUI

#if canImport(Highlightr)
import Highlightr
#endif

#if canImport(Highlightr)
struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    var theme: CodeHighlighterTheme

    @Environment(\.fontGroup) private var font
    @Environment(\.colorScheme) private var colorScheme
    @State private var attributedCode: AttributedString?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                codeLanguage

                Spacer()

                CopyButton(content: code)
                    .scaleEffect(0.9, anchor: .trailing) // make slightly smaller
            }
            .font(.callout)
            .padding(.bottom, 12)

            Group {
//                if let attributedCode {
//                    SwiftUI.Text(attributedCode)
//                } else {
                SwiftUI.Text(code)
//                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lineSpacing(5)
        .font(font.codeBlock)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
        .task(id: colorScheme) {
            let theme = colorScheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName
            Highlightr.shared?.setTheme(to: theme)
            await highlight()
        }
        .onChange(of: theme) { newTheme in
            let theme = colorScheme == .dark ? newTheme.darkModeThemeName : newTheme.lightModeThemeName
            Highlightr.shared?.setTheme(to: theme)
            Task {
                await highlight()
            }
        }
        .onChange(of: colorScheme) { newColorTheme in
            let theme = newColorTheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName
            Highlightr.shared?.setTheme(to: theme)
            Task {
                await highlight()
            }
        }
    }

    @ViewBuilder
    private var codeLanguage: some View {
        if let language {
            SwiftUI.Text(language.uppercased())
                .font(.callout.monospaced())
                .foregroundStyle(.secondary)
        }
    }

    @Sendable private func highlight() async {
        guard let highlighter = Highlightr.shared else { return }
        let language = highlighter.supportedLanguages().first(where: { $0.lowercased() == self.language?.lowercased() })
        if let highlightedCode = highlighter.highlight(code, as: language) {
            let code = NSMutableAttributedString(attributedString: highlightedCode)
            code.removeAttribute(.font, range: NSMakeRange(0, code.length))

            attributedCode = AttributedString(code)
        }
    }
}
#endif

// MARK: - Shared Instance

#if canImport(Highlightr)
extension Highlightr {
    static var shared: Highlightr? = Highlightr()
}
#endif

struct CodeHighlighterUpdator: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.codeHighlighterTheme) private var theme: CodeHighlighterTheme

    func body(content: Content) -> some View {
        content
        #if canImport(Highlightr)
        .task(id: colorScheme) {
            let theme = colorScheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName
            Highlightr.shared?.setTheme(to: theme)
        }
        .onChange(of: theme) { newTheme in
            let theme = colorScheme == .dark ? newTheme.darkModeThemeName : newTheme.lightModeThemeName
            Highlightr.shared?.setTheme(to: theme)
        }
        .onChange(of: colorScheme) { newColorTheme in
            let theme = newColorTheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName
            Highlightr.shared?.setTheme(to: theme)
        }
        #endif
    }
}

extension View {
    func updateCodeBlocksWhenColorSchemeChanges() -> some View {
        modifier(CodeHighlighterUpdator())
    }
}
