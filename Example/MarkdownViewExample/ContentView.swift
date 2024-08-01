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

    @State var markdownFull = #"""
    What is $\sqrt{16^{4}}$?

    Some latex $\displaystyle 1+\frac{e^{-2\pi}} {1+\frac{e^{-4\pi}} {1+\frac{e^{-6\pi}} {1+\frac{e^{-8\pi}} {1+\cdots} } } }$ end of latex

    $$\sqrt{2}$$

    State | Population
    --- | ---
    CA | 100
    TX | 50

    ```
    let str = "Hello!"
    let age = 50
    ```
    """#

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
                            for line in Constants.californiaPopulation.chunked(into: 5) {
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
