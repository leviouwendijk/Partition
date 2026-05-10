import Partition
import Path
import TestFlows

enum PartitionTestSuite: TestFlowRegistry {
    static let title = "Partition"

    static let flows: [TestFlow] = [
        TestFlow(
            "schema-shape",
            tags: [
                "schema",
                "development"
            ]
        ) {
            let schema = PartitionSchema<DevelopmentPartitionAddress>.development

            try Expect.equal(
                schema.id.rawValue,
                "development",
                "schema id"
            )

            try Expect.equal(
                schema.version.value,
                1,
                "schema version"
            )

            try Expect.equal(
                schema.addresses.count,
                DevelopmentPartitionAddress.allCases.count,
                "schema address count"
            )

            try Expect.equal(
                schema.layouts.count,
                2,
                "schema layout count"
            )

            try Expect.true(
                schema.layouts.keys.contains(
                    DevelopmentPartitionLayout.main
                ),
                "schema contains main layout"
            )

            try Expect.true(
                schema.layouts.keys.contains(
                    DevelopmentPartitionLayout.myworkdir
                ),
                "schema contains myworkdir layout"
            )

            return [
                .field(
                    "addresses",
                    "\(schema.addresses.count)"
                ),
                .field(
                    "layouts",
                    "\(schema.layouts.count)"
                )
            ]
        },

        TestFlow(
            "address-parent-graph",
            tags: [
                "schema",
                "addresses"
            ]
        ) {
            try Expect.isNil(
                DevelopmentPartitionAddress.main.parent,
                "main has no parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.programming.parent,
                .main,
                "programming parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.specifications.parent,
                .programming,
                "specifications parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.websites.parent,
                .programming,
                "websites parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.apis.parent,
                .programming,
                "apis parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.api_hondenmeesters.parent,
                .apis,
                "api hondenmeesters parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.api_hondenmeesters_env_file.parent,
                .api_hondenmeesters_env,
                "api hondenmeesters env file parent"
            )

            try Expect.equal(
                DevelopmentPartitionAddress.api_hondenmeesters_tests.parent,
                .api_hondenmeesters,
                "api hondenmeesters tests parent"
            )

            return [
                .field(
                    "checked",
                    "parent graph"
                )
            ]
        },

        TestFlow(
            "resolve-main-layout",
            tags: [
                "resolver",
                "main"
            ]
        ) {
            let resolver = PartitionResolver(
                schema: .development,
                layoutIdentifier: DevelopmentPartitionLayout.main
            )

            try Expect.equal(
                try resolver.resolve(
                    .main
                ),
                StandardPath(
                    from: .home,
                    [
                        "main"
                    ]
                ),
                "main root"
            )

            try Expect.equal(
                try resolver.resolve(
                    .programming
                ),
                StandardPath(
                    from: .home,
                    [
                        "main",
                        "programming"
                    ]
                ),
                "main programming"
            )

            try Expect.equal(
                try resolver.resolve(
                    .websites
                ),
                StandardPath(
                    from: .home,
                    [
                        "main",
                        "programming",
                        "bundles",
                        "websites"
                    ]
                ),
                "main websites"
            )

            try Expect.equal(
                try resolver.resolve(
                    .apis
                ),
                StandardPath(
                    from: .home,
                    [
                        "main",
                        "programming",
                        "bundles",
                        "api"
                    ]
                ),
                "main apis"
            )

            try Expect.equal(
                try resolver.resolve(
                    .api_hondenmeesters_tests
                ),
                StandardPath(
                    from: .home,
                    [
                        "main",
                        "programming",
                        "bundles",
                        "api",
                        "api-hondenmeesters",
                        "tests"
                    ]
                ),
                "main api hondenmeesters tests"
            )

            return [
                .field(
                    "layout",
                    DevelopmentPartitionLayout.main.rawValue
                )
            ]
        },

        TestFlow(
            "resolve-myworkdir-layout",
            tags: [
                "resolver",
                "myworkdir"
            ]
        ) {
            let resolver = PartitionResolver(
                schema: .development,
                layoutIdentifier: DevelopmentPartitionLayout.myworkdir
            )

            try Expect.equal(
                try resolver.resolve(
                    .main
                ),
                StandardPath(
                    from: .home,
                    [
                        "myworkdir"
                    ]
                ),
                "myworkdir root"
            )

            try Expect.equal(
                try resolver.resolve(
                    .programming
                ),
                StandardPath(
                    from: .home,
                    [
                        "myworkdir",
                        "programming"
                    ]
                ),
                "myworkdir programming"
            )

            try Expect.equal(
                try resolver.resolve(
                    .binaries
                ),
                StandardPath(
                    from: .home,
                    [
                        "myworkdir",
                        "programming",
                        "scripts"
                    ]
                ),
                "myworkdir binaries maps to scripts"
            )

            try Expect.equal(
                try resolver.resolve(
                    .websites
                ),
                StandardPath(
                    from: .home,
                    [
                        "myworkdir",
                        "programming",
                        "websites"
                    ]
                ),
                "myworkdir websites"
            )

            try Expect.equal(
                try resolver.resolve(
                    .apis
                ),
                StandardPath(
                    from: .home,
                    [
                        "myworkdir",
                        "programming",
                        "api"
                    ]
                ),
                "myworkdir apis"
            )

            try Expect.equal(
                try resolver.resolve(
                    .api_hondenmeesters_env_file
                ),
                StandardPath(
                    from: .home,
                    [
                        "myworkdir",
                        "programming",
                        "api",
                        "api-hondenmeesters",
                        "env",
                        ".env"
                    ]
                ),
                "myworkdir api hondenmeesters env file"
            )

            return [
                .field(
                    "layout",
                    DevelopmentPartitionLayout.myworkdir.rawValue
                )
            ]
        },

        TestFlow(
            "missing-layout-fails",
            tags: [
                "resolver",
                "errors"
            ]
        ) {
            let resolver = PartitionResolver(
                schema: PartitionSchema<DevelopmentPartitionAddress>.development,
                layoutIdentifier: "missing"
            )

            try Expect.throwsError(
                "missing layout throws"
            ) {
                _ = try resolver.resolve(
                    .main
                )
            }

            return [
                .field(
                    "error",
                    "layoutNotFound"
                )
            ]
        },

        TestFlow(
            "missing-address-fails",
            tags: [
                "resolver",
                "errors"
            ]
        ) {
            let schema = PartitionSchema<DevelopmentPartitionAddress>(
                id: "development",
                version: 1,
                addresses: [],
                layouts: [
                    DevelopmentPartitionLayout.main_layout
                ]
            )

            let resolver = PartitionResolver(
                schema: schema,
                layoutIdentifier: DevelopmentPartitionLayout.main
            )

            try Expect.throwsError(
                "missing address throws"
            ) {
                _ = try resolver.resolve(
                    .main
                )
            }

            return [
                .field(
                    "error",
                    "addressNotFound"
                )
            ]
        },

        TestFlow(
            "missing-path-mapping-fails",
            tags: [
                "resolver",
                "errors"
            ]
        ) {
            let layout = PartitionLayout<DevelopmentPartitionAddress>(
                id: "partial",
                root: .home,
                paths: [:]
            )

            let schema = PartitionSchema<DevelopmentPartitionAddress>(
                id: "development",
                version: 1,
                addresses: [
                    .init(
                        id: .main
                    )
                ],
                layouts: [
                    layout
                ]
            )

            let resolver = PartitionResolver(
                schema: schema,
                layoutIdentifier: "partial"
            )

            try Expect.throwsError(
                "missing path mapping throws"
            ) {
                _ = try resolver.resolve(
                    .main
                )
            }

            return [
                .field(
                    "error",
                    "pathMappingNotFound"
                )
            ]
        }
    ]
}
