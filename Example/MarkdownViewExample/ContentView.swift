//
//  ContentView.swift
//  MarkdownViewExample
//
//  Created by Andrew Zheng on 8/1/24.
//

import MarkdownView
import SwiftUI

struct ContentView: View {
    @State var markdown = """
    **Swift** *Markdown* `Testing`

    ---

    """

    var body: some View {
        VStack {
            VStack {
                Image(systemName: "textformat.abc.dottedunderline")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("Swift Markdown Testing")

                HStack {
                    Button("Start Stream") {
                        Task {
                            for line in Constants.bigLatexTest.chunked(into: 5) {
                                markdown.append("\(line)")

                                try await Task.sleep(for: .seconds(0.03))
                            }
                        }
                    }

                    Button("Clear Text") {
                        markdown = ""
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .padding(.top)

            ScrollView {
                MarkdownView(text: $markdown)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ContentView()
}
