import Path

public enum DevelopmentPartitionLayout {
    public static let main: PartitionLayoutIdentifier = "main"
    public static let myworkdir: PartitionLayoutIdentifier = "myworkdir"

    public static let main_layout = PartitionLayout<DevelopmentPartitionAddress>(
        id: main,
        root: .home,
        paths: [
            .main:
                .init("main"),
            .programming:
                .init("main", "programming"),
            .accounting:
                .init("main", "programming"),
            .binaries:
                .init("main", "programming", "binaries"),
            .swift_binaries:
                .init("main", "programming", "binaries", "swiftbins"),
            .c_binaries:
                .init("main", "programming", "binaries", "cbins"),
            .libraries:
                .init("main", "programming", "libraries"),
            .swift_libraries:
                .init("main", "programming", "libraries", "swiftlibs"),
            .specifications:
                .init("main", "programming", "specifications"),
            .websites:
                .init("main", "programming", "bundles", "websites"),
            .apis:
                .init("main", "programming", "bundles", "api"),
            .api_hondenmeesters:
                .init("main", "programming", "bundles", "api", "api-hondenmeesters"),
            .api_hondenmeesters_env:
                .init("main", "programming", "bundles", "api", "api-hondenmeesters", "env"),
            .api_hondenmeesters_env_file:
                .init("main", "programming", "bundles", "api", "api-hondenmeesters", "env", ".env"),
            .api_hondenmeesters_tests:
                .init("main", "programming", "bundles", "api", "api-hondenmeesters", "tests")
        ]
    )

    public static let myworkdir_layout = PartitionLayout<DevelopmentPartitionAddress>(
        id: myworkdir,
        root: .home,
        paths: [
            .main:
                .init("myworkdir"),
            .programming:
                .init("myworkdir", "programming"),
            .accounting:
                .init("myworkdir", "programming"),
            .binaries:
                .init("myworkdir", "programming", "scripts"),
            .swift_binaries:
                .init("myworkdir", "programming", "scripts", "swiftbins"),
            .c_binaries:
                .init("myworkdir", "programming", "scripts", "cbins"),
            .libraries:
                .init("myworkdir", "programming", "libraries"),
            .swift_libraries:
                .init("myworkdir", "programming", "libraries", "swiftlibs"),
            .specifications:
                .init("myworkdir", "programming", "specifications"),
            .websites:
                .init("myworkdir", "programming", "websites"),
            .apis:
                .init("myworkdir", "programming", "api"),
            .api_hondenmeesters:
                .init("myworkdir", "programming", "api", "api-hondenmeesters"),
            .api_hondenmeesters_env:
                .init("myworkdir", "programming", "api", "api-hondenmeesters", "env"),
            .api_hondenmeesters_env_file:
                .init("myworkdir", "programming", "api", "api-hondenmeesters", "env", ".env"),
            .api_hondenmeesters_tests:
                .init("myworkdir", "programming", "api", "api-hondenmeesters", "tests")
        ]
    )

    public static let all: [PartitionLayout<DevelopmentPartitionAddress>] = [
        main_layout,
        myworkdir_layout
    ]
}
