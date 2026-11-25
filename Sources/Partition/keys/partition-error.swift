import Foundation

/// Why a partition catalog, map or lookup failed.
public enum PartitionError: Error, LocalizedError, Sendable, Equatable {
    // catalog
    case duplicateKey(PartitionKey)
    case aliasCollision(alias: PartitionKey, key: PartitionKey)
    case unknownParent(key: PartitionKey, parent: PartitionKey)
    case parentCycle(PartitionKey)
    case invalidSegment(key: PartitionKey, segment: String)

    // map
    case machineMismatch(map: String, host: String)
    case unknownMapKey(PartitionKey)
    case aliasInMap(alias: PartitionKey, key: PartitionKey)
    case duplicateMapKey(PartitionKey)
    case noCandidates(PartitionKey)
    case invalidRoot(String)

    // lookup
    case unknownKey(PartitionKey)
    case notMapped(PartitionKey)

    // configuration
    case configurationMissing(file: String)
    case invalidConfiguration(file: String, message: String)
    case invalidKey(raw: String, reason: String)

    public var errorDescription: String? {
        switch self {
        case .duplicateKey(let key):
            return "Partition key '\(key)' is declared more than once."
        case .aliasCollision(let alias, let key):
            return "Alias '\(alias)' of '\(key)' is already a key or another key's alias."
        case .unknownParent(let key, let parent):
            return "Partition key '\(key)' names parent '\(parent)', which is not declared."
        case .parentCycle(let key):
            return "Partition key '\(key)' is its own ancestor."
        case .invalidSegment(let key, let segment):
            return "Partition key '\(key)' has segment '\(segment)'; a segment is one path component."
        case .machineMismatch(let map, let host):
            return "The partition map is for machine '\(map)', but this is '\(host)'."
        case .unknownMapKey(let key):
            return "The partition map has an entry for '\(key)', which addresses do not declare."
        case .aliasInMap(let alias, let key):
            return "The partition map uses alias '\(alias)'; write its key '\(key)'."
        case .duplicateMapKey(let key):
            return "The partition map has more than one entry for '\(key)'."
        case .noCandidates(let key):
            return "The partition map entry for '\(key)' lists no paths."
        case .invalidRoot(let root):
            return "Partition map root '\(root)' is neither '~', '~/…' nor an absolute path."
        case .unknownKey(let key):
            return "Partition key '\(key)' is not declared."
        case .notMapped(let key):
            return "Partition key '\(key)' has no path on this machine: no map entry, and no parent with a segment."
        case .configurationMissing(let file):
            return "Partition configuration not found: \(file)."
        case .invalidConfiguration(let file, let message):
            return "\(file): \(message)"
        case .invalidKey(let raw, let reason):
            return "'\(raw)' is not a valid partition key (\(reason))."
        }
    }
}

public extension PartitionKey {
    /// Parses a key read from configuration, failing as a `PartitionError`.
    static func parse(
        _ raw: String
    ) throws(PartitionError) -> PartitionKey {
        do {
            return try PartitionKey(raw)
        } catch {
            throw .invalidKey(raw: raw, reason: "\(error)")
        }
    }
}
