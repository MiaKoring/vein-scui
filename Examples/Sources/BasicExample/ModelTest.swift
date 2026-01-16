import SwiftCrossUI
import Vein
import VeinSCUI
import Foundation

typealias Test = TestSchemaV0_0_1.Test

enum TestSchemaV0_0_1: VersionedSchema {
    static let version = ModelVersion(0, 0, 1)
    
    static let models: [any Vein.PersistentModel.Type] = [
        Test.self
    ]
    
    @Model
    final class Test: Identifiable {      
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
        }
    }
}

enum TestMigration: SchemaMigrationPlan {
    static var stages: [MigrationStage] {
        []
    }
    
    static var schemas: [any Vein.VersionedSchema.Type] {
        [TestSchemaV0_0_1.self]
    }
}

nonisolated enum Group: String, Persistable, CaseIterable {
    var asPersistentRepresentation: String {
        self.rawValue
    }
    
    typealias PersistentRepresentation = String
    
    static var sqliteTypeName: Vein.SQLiteTypeName { String.sqliteTypeName }
    
    var sqliteValue: Vein.SQLiteValue {
        .text(rawValue)
    }
    
    static func decode(sqliteValue: Vein.SQLiteValue) throws(Vein.MOCError) -> Group {
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
