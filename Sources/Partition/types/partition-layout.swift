import Path

public struct PartitionLayout<Address: PartitionAddressIdentifying>: Sendable, Codable, Hashable, Identifiable {
    public var id: PartitionLayoutIdentifier
    public var root: StandardPath
    public var paths: [Address: StandardPath]

    public init(
        id: PartitionLayoutIdentifier,
        root: StandardPath,
        paths: [Address: StandardPath]
    ) {
        self.id = id
        self.root = root
        self.paths = paths
    }
}
