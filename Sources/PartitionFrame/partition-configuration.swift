import Foundation
import Frame
import IO
import Partition
import Readers

/// Where partition configuration lives and how it loads.
///
/// `addresses.frame` (portable) and `map.frame` (this machine) in
/// `$PARTITION_CONFIG`, else `$XDG_CONFIG_HOME/partition`, else
/// `~/.config/partition`.
public enum PartitionConfiguration {
    public static let environmentKey = "PARTITION_CONFIG"
    public static let addressesFile = "addresses.frame"
    public static let mapFile = "map.frame"

    public static func directory(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> URL {
        if let override = environment[environmentKey].flatMap({ $0.isEmpty ? nil : $0 }) {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        let base = environment["XDG_CONFIG_HOME"].flatMap { $0.isEmpty ? nil : $0 }
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config", isDirectory: true)
        return base.appendingPathComponent("partition", isDirectory: true)
    }

    /// This machine's partitions, from the configuration directory.
    public static func load(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        hostname: String = PartitionMachine.hostname()
    ) throws(PartitionError) -> Partitions {
        try load(directory: directory(environment: environment), hostname: hostname)
    }

    public static func load(
        directory: URL,
        hostname: String = PartitionMachine.hostname()
    ) throws(PartitionError) -> Partitions {
        let addresses = directory.appendingPathComponent(addressesFile)
        let map = directory.appendingPathComponent(mapFile)
        return try parse(
            addresses: try read(addresses),
            addressesPath: addresses.path,
            map: try read(map),
            mapPath: map.path,
            hostname: hostname
        )
    }

    /// Both files' sources, already read; for tests and tools that hold them in memory.
    public static func parse(
        addresses: String,
        addressesPath: String = addressesFile,
        map: String,
        mapPath: String = mapFile,
        hostname: String = PartitionMachine.hostname(),
        exists: @escaping @Sendable (URL) -> Bool = { FileSystem.default.exists($0) }
    ) throws(PartitionError) -> Partitions {
        let catalog = try decode(PartitionFrame.Addresses.self, binding: "addresses", source: addresses, path: addressesPath)
            .catalog()
        let machineMap = try decode(PartitionFrame.Map.self, binding: "map", source: map, path: mapPath)
            .map()
        return try Partitions(
            catalog: catalog,
            map: machineMap,
            hostname: hostname,
            exists: exists
        )
    }

    private static func read(
        _ file: URL
    ) throws(PartitionError) -> String {
        guard FileSystem.default.exists(file) else {
            throw .configurationMissing(file: file.path)
        }
        do {
            return try TextFileReader(file).read().text
        } catch {
            throw .invalidConfiguration(file: file.path, message: "\(error)")
        }
    }

    private static func decode<T: Decodable>(
        _ type: T.Type,
        binding: String,
        source: String,
        path: String
    ) throws(PartitionError) -> T {
        do {
            let document = try Frame.parse(source, filePath: path, environment: PartitionFrame.environment)
            return try document.decode(type, binding: binding)
        } catch {
            throw .invalidConfiguration(file: path, message: "\(error)")
        }
    }
}
