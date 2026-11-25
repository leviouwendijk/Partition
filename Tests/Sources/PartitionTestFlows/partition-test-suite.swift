import TestFlows

enum PartitionTestSuite: TestFlowRegistry {
    static let title = "Partition"

    static let flows: [TestFlow] = PartitionKeyFlows.flows
}
