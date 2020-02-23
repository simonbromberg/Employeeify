//
//  Cache.swift
//
//  Adapted from https://www.swiftbysundell.com/articles/caching-in-swift/
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    public typealias DateProvider = () -> Date

    private let wrapped = NSCache<WrappedKey, Entry>()
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()

    private(set) var dateProvider: DateProvider

    public init(dateProvider: @escaping DateProvider, entryLifetime: TimeInterval, maximumEntryCount: Int) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
        wrapped.evictsObjectsWithDiscardedContent = false
    }

    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    public func reset() {
        wrapped.removeAllObjects()
    }

    public subscript(key: Key) -> Value? {
        get {
            guard let entry = entry(forKey: key) else { return nil }

            return entry.value
        }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            let date = dateProvider().addingTimeInterval(entryLifetime)
            let entry = Entry(key: key, value: value, expirationDate: date)
            insert(entry)
        }
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }

    final class Entry: NSDiscardableContent {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }

        // Prevent objects from being automagically evicted from the cache
        // whenever the app enters background
        public func beginContentAccess() -> Bool { return true }
        public func endContentAccess() { }
        public func discardContentIfPossible() { }
        public func isContentDiscarded() -> Bool { return false }
    }

    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry else { return }

            keys.remove(entry.key)
        }
    }

    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}
