//
//  TableOptions.swift
//  MarkdownView
//
//  Created by Andrew Zheng on 7/30/24.
//

import SwiftUI

struct TableOptions: Equatable {
    var strokeColor = Color.primary.opacity(0.25)
    var strokeWidth = CGFloat(0.5)
    var cellPadding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
}

private struct TableOptionsKey: EnvironmentKey {
    static let defaultValue = TableOptions()
}

extension EnvironmentValues {
    var tableOptions: TableOptions {
        get { self[TableOptionsKey.self] }
        set { self[TableOptionsKey.self] = newValue }
    }
}
