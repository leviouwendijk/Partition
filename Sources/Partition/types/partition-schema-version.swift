public struct PartitionSchemaVersion: Sendable, Codable, Hashable, Comparable, ExpressibleByIntegerLiteral, CustomStringConvertible {
    public var value: Int

    public init(
        _ value: Int
    ) {
        self.value = value
    }

    public init(
        integerLiteral value: IntegerLiteralType
    ) {
        self.value = value
    }

    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.value < rhs.value
    }

    public var description: String {
        "\(value)"
    }
}
