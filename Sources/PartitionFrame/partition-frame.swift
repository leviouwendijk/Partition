import Frame
import Partition

/// The `Partition` Frame module: what `import Partition;` makes nameable in
/// `~/.config/partition/addresses.frame` and `map.frame`.
///
/// addresses.frame, the same on every machine:
///
///     import Partition;
///
///     let addresses: Addresses = .{ .entries = [
///         .{ .key = "apis", .parent = "programming" },
///         .{ .key = "api-depaix", .parent = "apis", .aliases = ["api-hondenmeesters"] },
///         .{ .key = "api-depaix-env", .parent = "api-depaix", .segment = "env" },
///     ] };
///
/// map.frame, one per machine:
///
///     import Partition;
///
///     let map: Map = .{ .machine = "levi-bulldog", .root = "~", .entries = [
///         .{ .key = "apis", .paths = ["main/programming/bundles/api"] },
///         .{ .key = "api-depaix", .paths = [
///             "main/programming/bundles/api/api-depaix",
///             "main/programming/bundles/api/api-hondenmeesters",
///         ] },
///     ] };
public enum PartitionFrame {
    public static let module = Frame.Module("Partition", types: [
        .decodable(Addresses.self, named: "Addresses"),
        .decodable(Address.self, named: "Address"),
        .decodable(Map.self, named: "Map"),
        .decodable(MapEntry.self, named: "MapEntry"),
    ])

    public static let environment = Frame.Environment([module])

    public struct Addresses: Sendable, Hashable, Decodable {
        public let entries: [Address]
    }

    public struct Address: Sendable, Hashable, Decodable {
        public let key: String
        public let uuid: String?
        public let parent: String?
        public let segment: String?
        public let aliases: [String]?
    }

    public struct Map: Sendable, Hashable, Decodable {
        public let machine: String
        public let root: String
        public let entries: [MapEntry]
    }

    public struct MapEntry: Sendable, Hashable, Decodable {
        public let key: String
        public let paths: [String]
    }
}

public extension PartitionFrame.Addresses {
    func catalog() throws(PartitionError) -> PartitionCatalog {
        var entries: [PartitionEntry] = []
        for address in self.entries {
            var aliases: [PartitionKey] = []
            for alias in address.aliases ?? [] {
                aliases.append(try PartitionKey.parse(alias))
            }
            var parent: PartitionKey?
            if let raw = address.parent {
                parent = try PartitionKey.parse(raw)
            }
            entries.append(PartitionEntry(
                key: try PartitionKey.parse(address.key),
                uuid: address.uuid,
                parent: parent,
                segment: address.segment,
                aliases: aliases
            ))
        }
        return try PartitionCatalog(entries)
    }
}

public extension PartitionFrame.Map {
    func map() throws(PartitionError) -> PartitionMap {
        var candidates: [PartitionKey: [[String]]] = [:]
        for entry in entries {
            let key = try PartitionKey.parse(entry.key)
            guard candidates[key] == nil else {
                throw .duplicateMapKey(key)
            }
            candidates[key] = entry.paths.map(PartitionMap.components)
        }
        return try PartitionMap(
            machine: machine,
            root: try PartitionMap.root(root),
            candidates: candidates
        )
    }
}
