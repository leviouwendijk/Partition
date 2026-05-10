import Path

public struct PartitionSchema<Address: PartitionAddressIdentifying>: Sendable, Codable, Hashable, Identifiable {
    public var id: PartitionSchemaIdentifier
    public var version: PartitionSchemaVersion
    public var addresses: [PartitionAddress<Address>]
    public var layouts: [PartitionLayoutIdentifier: PartitionLayout<Address>]

    public init(
        id: PartitionSchemaIdentifier,
        version: PartitionSchemaVersion,
        addresses: [PartitionAddress<Address>],
        layouts: [PartitionLayout<Address>]
    ) {
        self.id = id
        self.version = version
        self.addresses = addresses
        self.layouts = Dictionary(
            uniqueKeysWithValues: layouts.map {
                (
                    $0.id,
                    $0
                )
            }
        )
    }
}
