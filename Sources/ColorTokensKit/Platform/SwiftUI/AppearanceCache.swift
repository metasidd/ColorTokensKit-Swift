//
//  AppearanceCache.swift
//  ColorTokensKit
//

import Foundation

/// Values worked out for an appearance and kept for the next time it's drawn, safe to read from any thread.
///
/// The key is the whole appearance: a trait collection on UIKit, an appearance name on AppKit. Increased contrast,
/// an elevated sheet or a custom trait is a different key, so it never gets another appearance's value.
final class AppearanceCache<Key: Equatable, Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [(key: Key, value: Value)] = []

    /// The value for `key`, calling `make` only the first time that appearance is seen.
    func value(for key: Key, make: () -> Value) -> Value {
        lock.lock()
        let kept = entries.first { $0.key == key }?.value
        lock.unlock()
        if let kept { return kept }
        let value = make()
        lock.lock()
        // Four covers light, dark and their high-contrast forms; a longer list would only be scanned.
        entries = [(key, value)] + entries.prefix(3)
        lock.unlock()
        return value
    }
}
