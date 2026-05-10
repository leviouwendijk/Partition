public struct PartitionAddress<Address: PartitionAddressIdentifying>: Sendable, Codable, Hashable, Identifiable {
    public var id: Address
    public var parent: Address?

    public init(
        id: Address,
        parent: Address? = nil
    ) {
        self.id = id
        self.parent = parent
    }
}
