import TestFlows

@main
struct PartitionTestFlowsMain {
    static func main() async {
        await TestFlowCLI.run(
            suite: PartitionTestSuite.self
        )
    }
}
