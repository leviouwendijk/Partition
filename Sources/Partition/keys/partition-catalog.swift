/// One declared location: the same on every machine.
public struct PartitionEntry: Sendable, Hashable {
    public let key: PartitionKey
    /// Written once when the entry is created; lets a map pin what it means by a key.
    public let uuid: String?
    public let parent: PartitionKey?
    /// The path component under the parent, for a key a machine map need not list.
    public let segment: String?
    /// Former keys that still resolve to this entry.
    public let aliases: [PartitionKey]

    public init(
        key: PartitionKey,
        uuid: String? = nil,
        parent: PartitionKey? = nil,
        segment: String? = nil,
        aliases: [PartitionKey] = []
    ) {
        self.key = key
        self.uuid = uuid
        self.parent = parent
        self.segment = segment
        self.aliases = aliases
    }
}

/// Every declared location, by key and alias. Construction is the validation:
/// keys and aliases are unique, parents exist, no key is its own ancestor and
/// segments are single path components.
public struct PartitionCatalog: Sendable, Hashable {
    public let entries: [PartitionEntry]
    private let byKey: [PartitionKey: PartitionEntry]
    private let aliasTarget: [PartitionKey: PartitionKey]

    public init(
        _ entries: [PartitionEntry]
    ) throws(PartitionError) {
        var byKey: [PartitionKey: PartitionEntry] = [:]
        for entry in entries {
            guard byKey[entry.key] == nil else {
                throw .duplicateKey(entry.key)
            }
            byKey[entry.key] = entry
        }

        var aliasTarget: [PartitionKey: PartitionKey] = [:]
        for entry in entries {
            for alias in entry.aliases {
                guard byKey[alias] == nil, aliasTarget[alias] == nil else {
                    throw .aliasCollision(alias: alias, key: entry.key)
                }
                aliasTarget[alias] = entry.key
            }
        }

        for entry in entries {
            if let parent = entry.parent, byKey[parent] == nil {
                throw .unknownParent(key: entry.key, parent: parent)
            }
            if let segment = entry.segment,
               segment.isEmpty || segment.contains("/") || segment == "." || segment == ".." {
                throw .invalidSegment(key: entry.key, segment: segment)
            }
        }

        for entry in entries {
            var seen: Set<PartitionKey> = [entry.key]
            var current = entry.parent
            while let parent = current {
                guard seen.insert(parent).inserted else {
                    throw .parentCycle(entry.key)
                }
                current = byKey[parent]?.parent
            }
        }

        self.entries = entries
        self.byKey = byKey
        self.aliasTarget = aliasTarget
    }

    /// The entry a key or alias names.
    public func entry(
        _ key: PartitionKey
    ) throws(PartitionError) -> PartitionEntry {
        if let entry = byKey[key] {
            return entry
        }
        if let target = aliasTarget[key], let entry = byKey[target] {
            return entry
        }
        throw .unknownKey(key)
    }

    /// The key an alias stands for; nil when `key` is not an alias.
    public func aliasTarget(
        of key: PartitionKey
    ) -> PartitionKey? {
        aliasTarget[key]
    }

    public func contains(
        key: PartitionKey
    ) -> Bool {
        byKey[key] != nil
    }

    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.entries == rhs.entries
    }

    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(entries)
    }
}
