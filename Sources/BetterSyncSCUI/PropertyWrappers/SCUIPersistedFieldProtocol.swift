import SwiftCrossUI
import BetterSync

protocol SCUIPersistedField: BetterSync.PersistedField, ObservableObject, PublishedMarkerProtocol {
    var upstreamLinkCancellable: Cancellable? { get set }
}
extension SCUIPersistedField {
    /// Handles changing a value. If `publish` is `false` the change won't be
    /// published, but if the wrapped value is ``ObservableObject`` the new
    /// upstream publisher will still get relinked.
    public func valueDidChange(publish: Bool = true) {
        if publish {
            didChange.send()
        }
        
        if let upstream = wrappedValue as? ObservableObject {
            upstreamLinkCancellable?.cancel()
            upstreamLinkCancellable = didChange.link(toUpstream: upstream.didChange)
        }
    }
}
