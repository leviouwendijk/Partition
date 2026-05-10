public extension PartitionSchema where Address == DevelopmentPartitionAddress {
    static let development = PartitionSchema(
        id: "development",
        version: 1,
        addresses: DevelopmentPartitionAddress.addresses,
        layouts: DevelopmentPartitionLayout.all
    )
}
