import Foundation

public enum PartitionResolutionError<Address: PartitionAddressIdentifying>: Error, LocalizedError, Sendable, Equatable {
    case layoutNotFound(
        PartitionLayoutIdentifier
    )
    case addressNotFound(
        Address
    )
    case pathMappingNotFound(
        layout: PartitionLayoutIdentifier,
        address: Address
    )

    public var errorDescription: String? {
        switch self {
        case .layoutNotFound(let layout):
            return "Partition layout '\(layout.rawValue)' was not found."

        case .addressNotFound(let address):
            return "Partition address '\(address.rawValue)' was not found."

        case .pathMappingNotFound(let layout, let address):
            return "Partition layout '\(layout.rawValue)' has no path mapping for address '\(address.rawValue)'."
        }
    }
}
