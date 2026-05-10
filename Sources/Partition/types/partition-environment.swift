import Foundation
import Milieu

public enum PartitionEnvironment {
    public static let key = "PARTITION"

    public static func raw() -> String? {
        EnvironmentExtractor
            .optional(key)?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .nilIfEmpty
    }

    public static func layout(
        _ raw: String
    ) -> PartitionLayoutIdentifier {
        switch raw
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
        {
        case "1", "1.0", "1.0.0", "myworkdir":
            return DevelopmentPartitionLayout.myworkdir

        case "2", "2.0", "2.0.0", "main":
            return DevelopmentPartitionLayout.main

        default:
            return PartitionLayoutIdentifier(
                rawValue: raw
            )
        }
    }

    public static func layout() -> PartitionLayoutIdentifier? {
        raw().map(layout)
    }

    public static func resolver(
        fallback: PartitionLayoutIdentifier
    ) -> PartitionResolver<DevelopmentPartitionAddress> {
        PartitionResolver(
            schema: .development,
            layoutIdentifier: layout() ?? fallback
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
