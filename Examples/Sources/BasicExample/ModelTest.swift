import SwiftCrossUI
import BetterSync
import BetterSyncSCUI
import Foundation

typealias Test = TestSchemaV0_0_1.Test

enum TestSchemaV0_0_1: VersionedSchema {
    static let version = ModelVersion(0, 0, 1)
    
    static let models: [any BetterSync.PersistentModel.Type] = [
        Test.self
    ]
    
    @Model
    final class Test: Identifiable {
        typealias SchemaMigration = TestMigration
        
        static let schema = "test"
        
        @Field
        var flag: Bool
        
        @LazyField
        var selectedGroup: Group?
        
        @Field
        var testEncryption: Encrypted<String>
        
        @Field
        var randomValue: Int
        
        init(flag: Bool, testEncryption: String, randomValue: Int) {
            self.flag = flag
            self.testEncryption = Encrypted(wrappedValue: testEncryption)
            self.randomValue = randomValue
            setupFields()
        }
    }
    
    struct TestMigration: ModelSchemaMigration {
        func prepare(in context: BetterSync.ManagedObjectContext) async throws {
            try await context.createSchema(Test.schema)
                .id()
                .field("flag", type: .bool(required: true))
                .field("selectedGroup", type: .string(required: false))
                .field("testEncryption", type: .data(required: true))
                .field("randomValue", type: .int(required: true))
                .run()
        }
    }
}

enum TestMigration: SchemaMigrationPlan {
    static var stages: [MigrationStage] {
        []
    }
    
    static var schemas: [any BetterSync.VersionedSchema.Type] {
        [TestSchemaV0_0_1.self]
    }
}

nonisolated enum Group: String, Persistable, CaseIterable {
    var asPersistentRepresentation: String {
        self.rawValue
    }
    
    typealias PersistentRepresentation = String
    
    static var sqliteTypeName: BetterSync.SQLiteTypeName { String.sqliteTypeName }
    
    var sqliteValue: BetterSync.SQLiteValue {
        .text(rawValue)
    }
    
    static func decode(sqliteValue: BetterSync.SQLiteValue) throws(BetterSync.MOCError) -> Group {
        guard
            case .text(let value) = sqliteValue,
            let correspondingValue = Group(rawValue: value)
        else { throw .propertyDecode(message: "raised by enum Group decoder")}
        return correspondingValue
    }
    
    init?(fromPersistent representation: String) {
        self.init(rawValue: representation)
    }
    
    case football
    case soccer
    case baseball
}

class TestObservableObject: SwiftCrossUI.ObservableObject {
    @SwiftCrossUI.Published var randomText = ""
}
