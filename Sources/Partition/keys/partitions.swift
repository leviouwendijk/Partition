import Foundation
import IO
import Path

/// The locations of this machine: a catalog read against this machine's map.
///
///     let partitions = try PartitionConfiguration.load()     // PartitionFrame
///     let api = try partitions.path("api-depaix")
///     let env = try partitions.path("api-depaix", "env/.env")
public struct Partitions: Sendable {
    public let catalog: PartitionCatalog
    public let map: PartitionMap
    /// Other machines' or former layouts, used only by `translate(_:)`.
    public let others: [PartitionMap]
    private let exists: @Sendable (URL) -> Bool

    /// Checks that the map is for `hostname` and that every map names declared keys only.
    /// `exists` decides which candidate path wins; tests pass their own.
    public init(
        catalog: PartitionCatalog,
        map: PartitionMap,
        others: [PartitionMap] = [],
        hostname: String = PartitionMachine.hostname(),
        exists: @escaping @Sendable (URL) -> Bool = { FileSystem.default.exists($0) }
    ) throws(PartitionError) {
        guard map.machine.lowercased() == hostname.lowercased() else {
            throw .machineMismatch(map: map.machine, host: hostname)
        }
        for candidateMap in [map] + others {
            for key in candidateMap.candidates.keys {
                if let target = catalog.aliasTarget(of: key) {
                    throw .aliasInMap(alias: key, key: target)
                }
                guard catalog.contains(key: key) else {
                    throw .unknownMapKey(key)
                }
            }
        }
        self.catalog = catalog
        self.map = map
        self.others = others
        self.exists = exists
    }

    /// The same location on this machine, for a path written under another map.
    ///
    /// Finds the key whose path in one of `others` is the longest prefix of
    /// `path` (any of its candidates) and re-roots the rest under that key's
    /// path here. Nil when no other map covers `path`. The result need not exist.
    public func translate(
        _ path: StandardPath
    ) -> StandardPath? {
        let source = path.segments.map(\.value)
        var best: (length: Int, key: PartitionKey, rest: [String])?

        for other in others {
            let root = other.root.segments.map(\.value)
            // Sorted, so equal-length matches resolve the same way every run.
            for (key, candidates) in other.candidates.sorted(by: { $0.key < $1.key }) {
                for candidate in candidates {
                    let prefix = root + candidate
                    guard prefix.count <= source.count,
                          Array(source.prefix(prefix.count)) == prefix,
                          prefix.count > (best?.length ?? -1)
                    else {
                        continue
                    }
                    best = (prefix.count, key, Array(source.dropFirst(prefix.count)))
                }
            }
        }

        guard let best, let here = try? self.path(best.key) else {
            return nil
        }
        return StandardPath(from: here, best.rest, filetype: path.filetype)
    }

    /// The path of a key or alias on this machine.
    public func path(
        _ key: PartitionKey
    ) throws(PartitionError) -> StandardPath {
        var visited: Set<PartitionKey> = []
        return try resolve(key, visited: &visited)
    }

    /// A path inside a key's location: `path("api-depaix", "env/.env")`.
    public func path(
        _ key: PartitionKey,
        _ relative: String
    ) throws(PartitionError) -> StandardPath {
        StandardPath(from: try path(key), PartitionMap.components(relative))
    }

    /// The same, for a key read at runtime.
    public func path(
        _ raw: String,
        _ relative: String? = nil
    ) throws(PartitionError) -> StandardPath {
        let key = try PartitionKey.parse(raw)
        guard let relative else {
            return try path(key)
        }
        return try path(key, relative)
    }

    private func resolve(
        _ key: PartitionKey,
        visited: inout Set<PartitionKey>
    ) throws(PartitionError) -> StandardPath {
        let entry = try catalog.entry(key)
        guard visited.insert(entry.key).inserted else {
            throw .parentCycle(entry.key)
        }

        if let candidates = map.candidates[entry.key] {
            let paths = candidates.map { StandardPath(from: map.root, $0) }
            return paths.first { exists($0.root_url()) } ?? paths[paths.count - 1]
        }

        if let parent = entry.parent, let segment = entry.segment {
            return StandardPath(from: try resolve(parent, visited: &visited), [segment])
        }

        throw .notMapped(entry.key)
    }
}
