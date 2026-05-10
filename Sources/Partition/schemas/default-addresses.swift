public enum DevelopmentPartitionAddress: String, PartitionAddressIdentifying, CaseIterable {
    case main
    case programming
    case accounting

    case binaries
    case swift_binaries
    case c_binaries

    case libraries
    case swift_libraries

    case specifications

    case websites
    case apis

    case api_hondenmeesters
    case api_hondenmeesters_env
    case api_hondenmeesters_env_file
    case api_hondenmeesters_tests

    public var parent: Self? {
        switch self {
        case .main:
            return nil

        case .programming:
            return .main

        case .accounting:
            return .programming

        case .binaries:
            return .programming

        case .swift_binaries:
            return .binaries

        case .c_binaries:
            return .binaries

        case .libraries:
            return .programming

        case .swift_libraries:
            return .libraries

        case .specifications:
            return .programming

        case .websites:
            return .programming

        case .apis:
            return .programming

        case .api_hondenmeesters:
            return .apis

        case .api_hondenmeesters_env:
            return .api_hondenmeesters

        case .api_hondenmeesters_env_file:
            return .api_hondenmeesters_env

        case .api_hondenmeesters_tests:
            return .api_hondenmeesters
        }
    }

    public var address: PartitionAddress<Self> {
        .init(
            id: self,
            parent: parent
        )
    }

    public static let addresses: [PartitionAddress<Self>] = allCases.map(\.address)
}
