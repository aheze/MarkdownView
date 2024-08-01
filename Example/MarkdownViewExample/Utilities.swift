//
//  Utilities.swift
//  MarkdownViewExample
//
//  Created by Andrew Zheng on 8/1/24.
//

import SwiftUI

extension String {
    func chunked(into size: Int) -> [String] {
        return stride(from: 0, to: self.count, by: size).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
