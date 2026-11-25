import Foundation
import Path

/// Where each location lives on one machine.
///
/// Each entry lists candidate paths relative to `root`, in order. A lookup
/// takes the first candidate that exists, and the last one when none does, so
/// a folder can be renamed on one machine at a time: list the new name first
/// and keep the old one as the fallback until it is gone.
public struct PartitionMap: Sendable, Hashable {
    public let machine: String
    public let root: StandardPath
    public let candidates: [PartitionKey: [[String]]]

    public init(
        machine: String,
        root: StandardPath,
        candidates: [PartitionKey: [[String]]]
    ) throws(PartitionError) {
        for (key, paths) in candidates where paths.isEmpty {
            throw .noCandidates(key)
        }
        self.machine = machine
        self.root = root
        self.candidates = candidates
    }

    /// `~`, `~/relative` or `/absolute`, as written in a map file.
    public static func root(
        _ raw: String,
        home: StandardPath = .home
    ) throws(PartitionError) -> StandardPath {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed == "~" {
            return home
        }
        if trimmed.hasPrefix("~/") {
            return StandardPath(from: home, components(String(trimmed.dropFirst(2))))
        }
        if trimmed.hasPrefix("/") {
            return StandardPath(components(trimmed))
        }
        throw .invalidRoot(raw)
    }

    /// A relative path as written in a map file: `main/programming/bundles/api`.
    public static func components(
        _ relative: String
    ) -> [String] {
        relative
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
            .filter { $0 != "." }
    }
}

/// The host name a map's `machine` is compared with: the first label, lowercased.
public enum PartitionMachine {
    public static func hostname() -> String {
        ProcessInfo
            .processInfo
            .hostName
            .split(separator: ".")
            .first
            .map(String.init)?
            .lowercased() ?? "unknown"
    }
}
