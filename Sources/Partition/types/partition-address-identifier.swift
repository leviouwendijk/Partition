import Primitives

public protocol PartitionAddressIdentifying:
    Sendable,
    Codable,
    Hashable,
    RawRepresentable,
    CustomStringConvertible
where
    RawValue == String
{
    var rawValue: String { get }
}

public extension PartitionAddressIdentifying {
    var description: String {
        rawValue
    }
}

public struct PartitionAddressIdentifier: PartitionAddressIdentifying, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }

    public init(
        _ rawValue: String
    ) {
        self.rawValue = rawValue
    }

    public init(
        stringLiteral value: String
    ) {
        self.rawValue = value
    }
}
