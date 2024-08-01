//
//  SVGImageScaleMultiplier.swift
//  MarkdownView
//
//  Created by Andrew Zheng on 7/30/24.
//

import SwiftUI

private struct SVGImageScaleMultiplierKey: EnvironmentKey {
    static let defaultValue: CGFloat = {
#if os(iOS)
        return 0.12
#else
        return 0.1
#endif
    }()
}

extension EnvironmentValues {
    var svgImageScaleMultiplier: CGFloat {
        get { self[SVGImageScaleMultiplierKey.self] }
        set { self[SVGImageScaleMultiplierKey.self] = newValue }
    }
}

public extension View {
    func svgImageScaleMultiplier(_ multiplier: CGFloat) -> some View {
        self.environment(\.svgImageScaleMultiplier, multiplier)
    }
}
