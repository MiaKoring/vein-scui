import Vein
import SwiftCrossUI

@attached(member, names: named(init), named(id), named(_setupFields), named(context), named(_getSchema), named(_fields), named(_fieldInformation), named(notifyOfChanges), named(_key), named(_PredicateHelper), named(_satisfiesConstraint))
@attached(extension, conformances: PersistentModel, Sendable, SwiftCrossUI.ObservableObject, names: named(version), named(schema))
@attached(peer, names: arbitrary)
public macro Model() = #externalMacro(
    module: "VeinSCUIMacros",
    type: "ModelMacro"
)
