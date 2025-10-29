import BetterSync
import SwiftCrossUI

@attached(member, names: named(init), named(id), named(setupFields), named(context), named(_getSchema), named(_fields), named(_fieldInformation), named(objectWillChange), named(_key), named(_PredicateHelper), named(_satisfiesConstraint))
@attached(extension, conformances: PersistentModel, Sendable, SwiftCrossUI.ObservableObject)
@attached(peer, names: arbitrary)
public macro Model() = #externalMacro(
    module: "BetterSyncSCUIMacros",
    type: "ModelMacro"
)
