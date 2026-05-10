import Path

public struct PartitionResolver<Address: PartitionAddressIdentifying>: Sendable, Codable, Hashable {
    public var schema: PartitionSchema<Address>
    public var layoutIdentifier: PartitionLayoutIdentifier

    public init(
        schema: PartitionSchema<Address>,
        layoutIdentifier: PartitionLayoutIdentifier
    ) {
        self.schema = schema
        self.layoutIdentifier = layoutIdentifier
    }

    public func layout() throws -> PartitionLayout<Address> {
        guard let layout = schema.layouts[layoutIdentifier] else {
            throw PartitionResolutionError<Address>.layoutNotFound(
                layoutIdentifier
            )
        }

        return layout
    }

    public func resolve(
        _ address: Address
    ) throws -> StandardPath {
        guard schema.addresses.contains(where: { $0.id == address }) else {
            throw PartitionResolutionError<Address>.addressNotFound(
                address
            )
        }

        let layout = try layout()

        guard let path = layout.paths[address] else {
            throw PartitionResolutionError<Address>.pathMappingNotFound(
                layout: layout.id,
                address: address
            )
        }

        return StandardPath(
            from: layout.root,
            path.segments.map(\.value),
            filetype: path.filetype
        )
    }
}
