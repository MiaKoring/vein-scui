import Foundation
import SwiftCrossUI
import DefaultBackend
import Vein
import VeinSCUI

struct ContentView: View {
    @Query
    var testItems: [Test]
    @State var stop = false
    @Environment(\.modelContext) var context
    
    init(predicate: Test._PredicateHelper = .init()) {
        self._testItems = Query<Test>(predicate)
    }
    
    var body: some View {
        VStack {
            Text("\(testItems.count)")
            Button("generate") {
                stop = false
                Task {
                    for _ in 0...30 {
                        if stop { return }
                        do {
                            try context.insert(Test(flag: Int.random(in: 0...1) > 0, testEncryption: "\(Int.random(in: 0...1000))", randomValue: Int.random(in: 0...1000)))
                        } catch {
                            print(error.localizedDescription)
                        }
                        await Task.yield()
                    }
                }
            }
            Button("printQuery") { print(testItems.map { $0.id }) }
            Button("Stop") { stop = true }
            Button("print managed instances") {
                print(context.trackedObjectCount)
            }
            Button("Save changes") {
                try? context.save()
            }
            Button("add one") {
                do {
                    try context.insert(Test(flag: Int.random(in: 0...1) > 0, testEncryption: "\(Int.random(in: 0...1000))", randomValue: Int.random(in: 0...1000)))
                } catch {
                    print(error.localizedDescription)
                }
            }
            if let first = testItems.first {
                ObservedTextField(item: first)
            }
            ScrollView {
                ForEach(testItems) { item in
                    TestModelDisplay(item: item)
                }
                .padding()
            }
        }
    }
}

struct ObservedTextField: View {
    var item: Test
    
    var body: some View {
        Toggle("", isOn: item.$flag)
        TextField("edit", text: item.$testEncryption.decrypted)
        Picker(of: Group.allCases, selection: item.$selectedGroup)
    }
}

struct TestModelDisplay: View {
    var item: Test
    @Environment(\.modelContext) var context
    var body: some View {
        VStack {
            HStack {
                Toggle("", isOn: item.$flag)
                Text(item.selectedGroup?.rawValue ?? "none")
                Text(item.testEncryption.wrappedValue)
                Text(item.randomValue.description)
                Button("Delete") {
                    do {
                        try context.delete(item)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

