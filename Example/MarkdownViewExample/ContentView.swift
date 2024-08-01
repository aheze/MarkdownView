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
    This is *some* **markdown**!


    """

    @State var markdownFull = #"""
    What is $\sqrt{16^{4}}$?
    
    Some latex $\displaystyle 1+\frac{e^{-2\pi}} {1+\frac{e^{-4\pi}} {1+\frac{e^{-6\pi}} {1+\frac{e^{-8\pi}} {1+\cdots} } } }$ end of latex
    
    $$\sqrt{2}$$
    """#
    
//    @State var markdownFull = #"""
//    $$\sqrt{2}$
//    """#
    
//    @State var markdownFull = #"""
//    What is $\sqrt{16^{4}}$
//
//    Some latex $\displaystyle \frac{1}{\Bigl(\sqrt{\phi \sqrt{5}}-\phi\Bigr) e^{\frac25 \pi}} = 1+\frac{e^{-2\pi}} {1+\frac{e^{-4\pi}} {1+\frac{e^{-6\pi}} {1+\frac{e^{-8\pi}} {1+\cdots} } } }$ end of latex
//
//    $$\displaystyle {1 +  \frac{q^2}{(1-q)}+\frac{q^6}{(1-q)(1-q^2)}+\cdots }= \prod_{j=0}^{\infty}\frac{1}{(1-q^{5j+2})(1-q^{5j+3})}, \quad\quad \text{for }\lvert q\rvert<1.$$
////
////    Regular *text*
////
////    State | Population
////    --- | ---
////    CA | 100
////    TX | 50
////
////    ```
////    let str = "Hello!"
////    let age = 50
////    ```
////    """#

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
                            for line in markdownFull.chunked(into: 5) {
                                markdown.append("\(line)")

                                try await Task.sleep(for: .seconds(0.04))
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
