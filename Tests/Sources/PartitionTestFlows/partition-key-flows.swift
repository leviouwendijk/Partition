import Foundation
import Partition
import PartitionFrame
import Path
import TestFlows

/// Keys, Frame configuration and fallback candidates (PartitionFrame).
enum PartitionKeyFlows {
    static let addresses = """
    import Partition;

    let addresses: Addresses = .{ .entries = [
        .{ .key = "main" },
        .{ .key = "programming", .parent = "main" },
        .{ .key = "apis", .parent = "programming" },
        .{ .key = "api-depaix", .parent = "apis", .aliases = ["api-hondenmeesters"] },
        .{ .key = "api-depaix-env", .parent = "api-depaix", .segment = "env" },
        .{ .key = "nginx", .parent = "programming" },
    ] };
    """

    static let map = """
    import Partition;

    let map: Map = .{ .machine = "test-host", .root = "/srv/home", .entries = [
        .{ .key = "main", .paths = ["main"] },
        .{ .key = "programming", .paths = ["main/programming"] },
        .{ .key = "apis", .paths = ["main/programming/bundles/api"] },
        .{ .key = "api-depaix", .paths = [
            "main/programming/bundles/api/api-depaix",
            "main/programming/bundles/api/api-hondenmeesters",
        ] },
    ] };
    """

    static let newFolder = "/srv/home/main/programming/bundles/api/api-depaix"
    static let oldFolder = "/srv/home/main/programming/bundles/api/api-hondenmeesters"

    /// Partitions over the test configuration, where only `existing` paths exist.
    static func configured(
        existing: Set<String>,
        map: String = map,
        hostname: String = "test-host"
    ) throws -> Partitions {
        try PartitionConfiguration.parse(
            addresses: addresses,
            map: map,
            hostname: hostname,
            exists: { existing.contains($0.path) }
        )
    }

    static func rendered(
        _ path: StandardPath
    ) -> String {
        path.root_url().path
    }

    /// The `PartitionError` `body` throws; fails the flow when it throws nothing or something else.
    static func error(
        _ label: String,
        _ body: () throws -> Void
    ) throws -> PartitionError {
        do {
            try body()
        } catch let error as PartitionError {
            return error
        } catch {
            throw TestFlowAssertionFailure(label: label, message: "expected a PartitionError, got \(error)")
        }
        throw TestFlowAssertionFailure(label: label, message: "expected a PartitionError, nothing was thrown")
    }

    static let flows: [TestFlow] = [
        TestFlow("key-validation", tags: ["keys"]) {
            // PartitionKey("…") with a literal is a literal conversion (a bad literal traps);
            // runtime strings go through parse, which throws.
            try Expect.equal(try PartitionKey.parse("api-depaix").raw, "api-depaix", "valid key")
            try Expect.equal(try PartitionKey.parse("  nginx ").raw, "nginx", "trimmed")
            try Expect.throwsError("empty key") { _ = try PartitionKey.parse("") }
            try Expect.throwsError("uppercase") { _ = try PartitionKey.parse("Api") }
            try Expect.throwsError("underscore") { _ = try PartitionKey.parse("api_depaix") }
            try Expect.throwsError("edge hyphen") { _ = try PartitionKey.parse("-api") }
            try Expect.throwsError("double hyphen") { _ = try PartitionKey.parse("api--depaix") }
            return []
        },

        TestFlow("fallback-candidates", tags: ["keys", "map"]) {
            let onlyOld = try configured(existing: [oldFolder])
            try Expect.equal(rendered(try onlyOld.path("api-depaix")), oldFolder, "only the old folder exists: fallback")

            let both = try configured(existing: [newFolder, oldFolder])
            try Expect.equal(rendered(try both.path("api-depaix")), newFolder, "both exist: first candidate")

            let neither = try configured(existing: [])
            try Expect.equal(rendered(try neither.path("api-depaix")), oldFolder, "none exist: last candidate")
            return [.field("fallback", oldFolder)]
        },

        TestFlow("alias-resolution", tags: ["keys", "aliases"]) {
            let partitions = try configured(existing: [oldFolder])
            try Expect.equal(
                rendered(try partitions.path("api-hondenmeesters")),
                rendered(try partitions.path("api-depaix")),
                "alias resolves to the key's path"
            )
            return []
        },

        TestFlow("child-under-fallback-parent", tags: ["keys", "segments"]) {
            let old = try configured(existing: [oldFolder])
            try Expect.equal(rendered(try old.path("api-depaix-env")), oldFolder + "/env", "segment under the fallback")

            let new = try configured(existing: [newFolder])
            try Expect.equal(rendered(try new.path("api-depaix-env")), newFolder + "/env", "segment under the new folder")
            try Expect.equal(rendered(try new.path("api-depaix", "env/.env")), newFolder + "/env/.env", "relative path inside a key")
            return []
        },

        TestFlow("lookup-failures", tags: ["keys", "errors"]) {
            let partitions = try configured(existing: [])
            try Expect.equal(try error("unknown key") { _ = try partitions.path("nope") }, .unknownKey("nope"), "unknown key")
            try Expect.equal(try error("unmapped key") { _ = try partitions.path("nginx") }, .notMapped("nginx"), "declared but not mapped")
            return []
        },

        TestFlow("map-validation", tags: ["map", "errors"]) {
            try Expect.equal(
                try error("machine mismatch") { _ = try configured(existing: [], hostname: "other-host") },
                .machineMismatch(map: "test-host", host: "other-host"),
                "map for another machine is rejected"
            )

            let unknownKey = map.replacingOccurrences(of: ".{ .key = \"main\", .paths = [\"main\"] },", with: ".{ .key = \"main\", .paths = [\"main\"] },\n    .{ .key = \"ghost\", .paths = [\"x\"] },")
            try Expect.equal(
                try error("unknown map key") { _ = try configured(existing: [], map: unknownKey) },
                .unknownMapKey("ghost"),
                "map key not in addresses"
            )

            let aliasKey = map.replacingOccurrences(of: ".{ .key = \"api-depaix\", .paths", with: ".{ .key = \"api-hondenmeesters\", .paths")
            try Expect.equal(
                try error("alias in map") { _ = try configured(existing: [], map: aliasKey) },
                .aliasInMap(alias: "api-hondenmeesters", key: "api-depaix"),
                "map must name the key, not an alias"
            )
            return []
        },

        TestFlow("catalog-validation", tags: ["catalog", "errors"]) {
            try Expect.equal(
                try error("duplicate key") { _ = try PartitionCatalog([.init(key: "a"), .init(key: "a")]) },
                .duplicateKey("a"),
                "duplicate key"
            )
            try Expect.equal(
                try error("alias collision") { _ = try PartitionCatalog([.init(key: "a"), .init(key: "b", aliases: ["a"])]) },
                .aliasCollision(alias: "a", key: "b"),
                "alias equal to a key"
            )
            try Expect.equal(
                try error("unknown parent") { _ = try PartitionCatalog([.init(key: "a", parent: "b")]) },
                .unknownParent(key: "a", parent: "b"),
                "parent not declared"
            )
            try Expect.equal(
                try error("cycle") { _ = try PartitionCatalog([.init(key: "a", parent: "b"), .init(key: "b", parent: "a")]) },
                .parentCycle("a"),
                "parent cycle"
            )
            try Expect.equal(
                try error("segment") { _ = try PartitionCatalog([.init(key: "a"), .init(key: "b", parent: "a", segment: "x/y")]) },
                .invalidSegment(key: "b", segment: "x/y"),
                "segment with a slash"
            )
            return []
        },

        TestFlow("configuration-directory", tags: ["configuration"]) {
            try Expect.equal(
                PartitionConfiguration.directory(environment: ["PARTITION_CONFIG": "/tmp/partition-test"]).path,
                "/tmp/partition-test",
                "PARTITION_CONFIG overrides"
            )
            try Expect.equal(
                PartitionConfiguration.directory(environment: ["XDG_CONFIG_HOME": "/tmp/xdg"]).path,
                "/tmp/xdg/partition",
                "XDG_CONFIG_HOME next"
            )
            try Expect.equal(
                try error("missing files") { _ = try PartitionConfiguration.load(directory: URL(fileURLWithPath: "/nonexistent/partition"), hostname: "test-host") },
                .configurationMissing(file: "/nonexistent/partition/addresses.frame"),
                "missing addresses.frame"
            )
            return []
        },

        TestFlow("live-configuration", tags: ["configuration", "live"]) {
            let directory = PartitionConfiguration.directory()
            let addressesFile = directory.appendingPathComponent(PartitionConfiguration.addressesFile)
            guard FileManager.default.fileExists(atPath: addressesFile.path) else {
                throw TestFlowSkip("no configuration at \(directory.path)")
            }
            let partitions = try PartitionConfiguration.load()
            var fields: [TestDiagnostic] = [.field("machine", partitions.map.machine)]
            for entry in partitions.catalog.entries {
                let path = rendered(try partitions.path(entry.key))
                try Expect.true(FileManager.default.fileExists(atPath: path), "\(entry.key) exists at \(path)")
                if entry.key == "api-depaix" {
                    fields.append(.field("api-depaix", path))
                }
            }
            return fields
        },

        TestFlow("frame-rejects-unknown-fields", tags: ["configuration", "frame"]) {
            let typo = addresses.replacingOccurrences(of: ".aliases =", with: ".alias =")
            let failure = try error("typo") {
                _ = try PartitionConfiguration.parse(addresses: typo, map: map, hostname: "test-host", exists: { _ in false })
            }
            guard case .invalidConfiguration(let file, _) = failure else {
                throw TestFlowAssertionFailure(label: "typo", message: "expected invalidConfiguration, got \(failure)")
            }
            try Expect.equal(file, PartitionConfiguration.addressesFile, "reported against addresses.frame")
            return []
        },
    ]
}
