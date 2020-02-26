//
//  Cache.swift
//  Created by Simon Bromberg on 2020-02-20.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

/// Simple NSCache based memory storage for more efficient loading of data at runtime and automatic memory release
public final class ImageCache {
    private let cache = NSCache<NSString, UIImage>()

    subscript(index: String) -> UIImage? {
        get {
            return cache.object(forKey: NSString(string: index))
        }

        set {
            if let image = newValue {
                cache.setObject(image, forKey: NSString(string: index))
            } else {
                cache.removeObject(forKey: NSString(string: index))
            }
        }
    }
}
