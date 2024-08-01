import SwiftUI

#if os(macOS) || os(iOS)
struct CopyButton: View {
    var content: String
    @State private var copied = false
    #if os(macOS)
    @ScaledMetric private var size = 12
    #else
    @ScaledMetric private var size = 18
    #endif
    @State private var isHovering = false
    
    var body: some View {
        Button(action: copy) {
            HStack(spacing: 6) {
                // use checkmark as base because it's not that tall
                Image(systemName: "checkmark")
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .scaleEffect(copied ? 1 : 0.8)
                    .opacity(copied ? 1 : 0)
                    .overlay {
                        Image(systemName: "doc.on.clipboard")
                            .scaleEffect(!copied ? 1 : 0.8)
                            .opacity(!copied ? 1 : 0)
                    }
                
                Text(copied ? "Copied!" : "Copy")
                    .transition(.identity)
                    .animation(nil)
            }
            .scaleEffect(1)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .buttonStyle(.plain) // Only use `.borderless` can behave correctly when text selection is enabled.
    }
    
    private func copy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        #else
        UIPasteboard.general.string = content
        #endif
        Task {
            withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 1)) {
                copied = true
            }
            
            try await Task.sleep(for: .seconds(2.0))
            
            withAnimation(.spring(response: 0.4, dampingFraction: 1, blendDuration: 1)) {
                copied = false
            }
        }
    }
}
#endif

struct UnstyledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
