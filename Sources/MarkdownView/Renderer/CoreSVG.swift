//
//  CoreSVG.swift
//  MarkdownView
//
//  Created by Andrew Zheng on 7/30/24.
//

import CoreGraphics
import Darwin
import Foundation

// https://github.com/xybp888/iOS-SDKs/blob/master/iPhoneOS17.1.sdk/System/Library/PrivateFrameworks/CoreSVG.framework/CoreSVG.tbd
// https://developer.limneos.net/index.php?ios=17.1&framework=UIKitCore.framework&header=UIImage.h

@objc
class CGSVGDocument: NSObject {}

var CGSVGDocumentRetain: (@convention(c) (CGSVGDocument?) -> Unmanaged<CGSVGDocument>?) = load("CGSVGDocumentRetain")
var CGSVGDocumentRelease: (@convention(c) (CGSVGDocument?) -> Void) = load("CGSVGDocumentRelease")
var CGSVGDocumentCreateFromData: (@convention(c) (CFData?, CFDictionary?) -> Unmanaged<CGSVGDocument>?) = load("CGSVGDocumentCreateFromData")
var CGContextDrawSVGDocument: (@convention(c) (CGContext?, CGSVGDocument?) -> Void) = load("CGContextDrawSVGDocument")
var CGSVGDocumentGetCanvasSize: (@convention(c) (CGSVGDocument?) -> CGSize) = load("CGSVGDocumentGetCanvasSize")

let CoreSVGFramework = dlopen("/System/Library/PrivateFrameworks/CoreSVG.framework/CoreSVG", RTLD_NOW)

func load<T>(_ name: String) -> T {
    unsafeBitCast(dlsym(CoreSVGFramework, name), to: T.self)
}

public class CoreSVG {
    deinit { CGSVGDocumentRelease(document) }

    let document: CGSVGDocument

    public convenience init?(_ value: String) {
        guard let data = value.data(using: .utf8) else { return nil }
        self.init(data)
    }

    public init?(_ data: Data) {
        guard let document = CGSVGDocumentCreateFromData(data as CFData, nil)?.takeUnretainedValue() else { return nil }
        guard CGSVGDocumentGetCanvasSize(document) != .zero else { return nil }
        self.document = document
    }

    public var size: CGSize {
        CGSVGDocumentGetCanvasSize(document)
    }

    public func draw(in context: CGContext) {
        draw(in: context, size: size)
    }

    public func draw(in context: CGContext, size target: CGSize) {
        var target = target

        let ratio = (
            x: target.width / size.width,
            y: target.height / size.height
        )

        let rect = (
            document: CGRect(origin: .zero, size: size), ()
        )

        let scale: (x: CGFloat, y: CGFloat)

        if target.width <= 0 {
            scale = (ratio.y, ratio.y)
            target.width = size.width * scale.x
        } else if target.height <= 0 {
            scale = (ratio.x, ratio.x)
            target.width = size.width * scale.y
        } else {
            let min = min(ratio.x, ratio.y)
            scale = (min, min)
            target.width = size.width * scale.x
            target.height = size.height * scale.y
        }

        let transform = (
            scale: CGAffineTransform(scaleX: scale.x, y: scale.y),
            aspect: CGAffineTransform(translationX: (target.width / scale.x - rect.document.width) / 2, y: (target.height / scale.y - rect.document.height) / 2)
        )

        // flip for UIKit
        context.translateBy(x: 0, y: target.height)
        context.scaleBy(x: 1, y: -1)
        context.concatenate(transform.scale)
        context.concatenate(transform.aspect)

        CGContextDrawSVGDocument(context, document)
    }
}
