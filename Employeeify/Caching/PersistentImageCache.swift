//
//  PersistentImageCache.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-23.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

// TODO: clear old images from cache

/// Longer term image caching which stores images to documents directory
class PersistentImageCache {
    func getImageData(forRemoteURL url: URL) -> Data? {
        let fileURL = fileURLForRemoteURL(url)

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            NSLog("Unable to initialize data from file \(error), \(fileURL)")
            return nil
        }
    }

    func saveImageToDocuments(remoteURL url: URL, data: Data) {
        let fileManager = FileManager.default
        let fileURL = fileURLForRemoteURL(url)

        do {
            try fileManager.createDirectory(atPath: imageCacheLocation.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Unable to create directory \(error), \(fileURL)")
        }

        do {
            try data.write(to: fileURL)
        } catch {
            NSLog("Unable to write image data \(error), \(fileURL)")
        }
    }

    private let imageCacheFolderName = "ImageCache"
    private var imageCacheLocation: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(imageCacheFolderName)
    }

    private func fileURLForRemoteURL(_ url: URL) -> URL {
        return imageCacheLocation.appendingPathComponent(url.path.replacingOccurrences(of: "/", with: "_"))
    }

    func resetCache() {
        do {
            try FileManager.default.removeItem(at: imageCacheLocation)
        } catch {
            NSLog("\(#function) failure: \(error)")
        }
    }
}
