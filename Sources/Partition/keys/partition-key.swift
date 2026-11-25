import Foundation
import Primitives

/// A location's stable name, such as `nginx` or `billing`.
///
/// Lowercase ASCII letters, digits and single hyphens, starting and ending with
/// a letter or digit. A key is never renamed: a rename adds a key and keeps the
/// old one as an alias (`PartitionEntry.aliases`).
public struct PartitionKey: CodableInvariant, Hashable, Sendable, Comparable, CustomStringConvertible, ExpressibleByStringLiteral {
    public enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case invalidCharacter(Character)
        case edgeHyphen
        case doubleHyphen
    }

    public let raw: String

    public init(
        _ raw: String
    ) throws(Error) {
        let candidate = raw.trimmingCharacters(
            in: .whitespaces
        )
        guard !candidate.isEmpty else {
            throw .empty
        }
        if let invalid = candidate.first(where: { !Self.isAllowed($0) }) {
            throw .invalidCharacter(invalid)
        }
        guard candidate.first != "-", candidate.last != "-" else {
            throw .edgeHyphen
        }
        guard !candidate.contains("--") else {
            throw .doubleHyphen
        }
        self.raw = candidate
    }

    /// For keys written in code; a literal that is not a valid key is a programming error.
    public init(
        stringLiteral value: String
    ) {
        do {
            try self.init(value)
        } catch {
            preconditionFailure("'\(value)' is not a valid partition key: \(error)")
        }
    }

    public var description: String {
        raw
    }

    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.raw < rhs.raw
    }

    private static func isAllowed(
        _ character: Character
    ) -> Bool {
        switch character {
        case "a"..."z", "0"..."9", "-":
            return true
        default:
            return false
        }
    }
}
