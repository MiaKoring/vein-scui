import SwiftCrossUI
import Vein
import Foundation

@MainActor
@propertyWrapper
public class Query<M: PersistentModel>: @MainActor DynamicProperty, @MainActor ObservableProperty {
    public var didChange: SwiftCrossUI.Publisher {
        queryObserver.didChange
    }
    
    public func tryRestoreFromSnapshot(_ snapshot: Data) {}
    
    public func snapshot() throws -> Data? { nil }
    
    public func update(with environment: SwiftCrossUI.EnvironmentValues, previousValue: Query<M>?) {
        guard let context = environment[ContainerKey.self]?.context else {
            fatalError("Missing model container in environment")
        }
        self.context = context
    }
    
    public typealias WrappedType = [M]
    var queryObserver: QueryObserver<M>
    var context: ManagedObjectContext?
    
    public var wrappedValue: [M] {
        if let results = queryObserver.results {
            return results.sorted(by: { $0.id < $1.id })
        }
        if queryObserver.results == nil && queryObserver.primaryObserver == nil {
            queryObserver.initialize(with: context!)
        }
        return (queryObserver.primaryObserver?.results ?? queryObserver.results ?? []).sorted(by: { $0.id < $1.id })
    }
    
    public init(_ predicate: M._PredicateHelper = M._PredicateHelper()) {
        self.queryObserver = QueryObserver<M>(predicate._builder())
    }
}

package final class QueryObserver<M: PersistentModel>: @unchecked Sendable {
    // MARK: - ViewUpdates
    var didChange = Publisher()

    // MARK: - Class Code
    typealias ModelType = M
    
    private var publishToEnclosingObserver: (() -> Void)?
    
    fileprivate var primaryObserver: QueryObserver<M>?
    
    let predicate: PredicateBuilder<M>
    
    package var usedPredicate: AnyPredicateBuilder { predicate }
    
    @MainActor
    package var results: [M]? = nil
    
    @MainActor
    func initialize(with context: ManagedObjectContext) {
        guard results == nil && primaryObserver == nil else { return }
        
        let primary = context.getOrCreateQueryObserver(
            for: M.typeIdentifier,
            predicate.hashValue,
            createWith: {
                return self
            }
        ) as! Self
        
        if primary !== self {
            self.primaryObserver = primary
            let old = primary.publishToEnclosingObserver
            primary.publishToEnclosingObserver = { [weak self] in
                old?()
                self?.didChange.send()
            }
        } else {
            fetchInitialResults(with: context)
        }
    }
    
    @MainActor
    private func fetchInitialResults(with context: ManagedObjectContext) {
        let initialResults = try! context.fetchAll(predicate)
        self.results = initialResults
    }
    
    
    @MainActor
    package func append(_ models: [M]) {
        results?.append(contentsOf: models.filter{ predicate.doesMatch($0) })
        // there is only one Query instance kept in the context for the same filter.
        // this triggers view updates on any other Query oberservers using the registered
        // Query as their source
        publishToEnclosingObserver?()
        didChange.send()
    }
    
    @MainActor
    package func appendAny(_ models: [AnyObject]) {
        guard let typedModels = models as? [M] else { return }
        append(typedModels)
    }
    
    package init(_ predicate: PredicateBuilder<M>) {
        self.predicate = predicate
    }
    
    @MainActor
    package func handleUpdate(_ model: any PersistentModel, matchedBeforeChange: Bool) {
        guard let model = model as? ModelType else { return }
        if predicate.doesMatch(model) {
            if !matchedBeforeChange {
                results?.append(model)
            }
        } else if matchedBeforeChange {
            results?.removeAll(where: { $0.id == model.id })
        }
        publishToEnclosingObserver?()
        didChange.send()
    }
    
    @MainActor
    package func doesMatch(_ model: any PersistentModel) -> Bool {
        guard let model = model as? ModelType else { return false }
        return predicate.doesMatch(model)
    }
    
    @MainActor
    package func remove(_ model: any PersistentModel) {
        guard let model = model as? ModelType else { return }
        results?.removeAll(where: { $0.id == model.id })
        publishToEnclosingObserver?()
        didChange.send()
    }
}

extension QueryObserver: @MainActor AnyQueryObserver {}

public struct ContainerKey: EnvironmentKey {
    public static let defaultValue: Vein.ModelContainer? = nil
}

extension EnvironmentValues {
    public var modelContainer: Vein.ModelContainer? {
        get {
            self[ContainerKey.self]
        }
        set { self[ContainerKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var modelContext: ManagedObjectContext {
        guard let container = modelContainer else {
            fatalError("Tried to access 'EnvironmentValues.modelContainer' without it being set in the environment.")
        }
        return container.context
    }
}

public struct VeinContainer<Content: View>: View {
    @Environment(\.modelContainer) private var container
    @State private var isInitialized: Bool = false
    @State var error: Error?
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content ) {
        self.content = content
    }
    
    public var body: some View {
        if let _ = container, isInitialized {
            content()
        } else if let container = container {
            if let error = error as? LocalizedError {
                Text("An error occured while migrating database:").font(.title3)
                if let errorDescription = error.errorDescription {
                    Text(errorDescription).foregroundColor(.red)
                }
                if let failureReason = error.failureReason {
                    Text(failureReason).foregroundColor(.gray)
                }
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion).foregroundColor(.gray)
                }
            } else if let error {
                Text("An error occured while migrating database:").font(.title3)
                Text(error.localizedDescription).foregroundColor(.red)
            } else {
                ProgressView()
                    .onAppear {
                        do {
                            try container.migrate()
                            isInitialized = true
                        } catch {
                            self.error = error
                            print(error.localizedDescription)
                        }
                    }
            }
        } else {
            ProgressView()
        }
    }
}

extension VeinContainer {
    public func modelContainer(_ container: Vein.ModelContainer) -> some View {
        self.environment(\.modelContainer, container)
    }
}
