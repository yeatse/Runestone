import Foundation
import os.lock

final class TreeSitterLanguageLayerStore {
    var allIDs: [UnsafeRawPointer] {
        withLock {
            Array(store.keys)
        }
    }

    var allLayers: [TreeSitterLanguageLayer] {
        withLock {
            Array(store.values)
        }
    }

    var isEmpty: Bool {
        withLock {
            store.isEmpty
        }
    }

    private var store: [UnsafeRawPointer: TreeSitterLanguageLayer] = [:]
    // Use os_unfair_lock for priority inheritance to reduce QoS inversions.
    private var lock = os_unfair_lock_s()

    func storeLayer(_ layer: TreeSitterLanguageLayer, forKey key: UnsafeRawPointer) {
        withLock {
            store[key] = layer
        }
    }

    func layer(forKey key: UnsafeRawPointer) -> TreeSitterLanguageLayer? {
        withLock {
            store[key]
        }
    }

    func removeLayer(forKey key: UnsafeRawPointer) {
        withLock {
            store.removeValue(forKey: key)
        }
    }

    func removeAll() {
        withLock {
            store.removeAll()
        }
    }

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        os_unfair_lock_lock(&lock)
        defer {
            os_unfair_lock_unlock(&lock)
        }
        return try body()
    }
}
