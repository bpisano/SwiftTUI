import Foundation

/// Three-state dirty system.
///
/// The extra state compared to the original `AttributeGraph` is the distinction between
/// `.dirty` (direct dependency confirmed changed → must re-evaluate) and `.pending`
/// (transitive ancestor changed → check direct deps first before deciding).
///
/// This allows skipping re-evaluation of nodes whose direct dependencies all evaluated
/// to the same value, even when a transitive ancestor changed.
public enum AttributeState: Int8, Hashable, Equatable, Codable, Sendable {
    /// Value is current. No re-evaluation needed.
    case clean
    /// A transitive ancestor changed, but no direct dependency has confirmed a change yet.
    /// Re-evaluate only if at least one direct dependency actually changed its value.
    case pending
    /// A direct dependency confirmed changed, or the value was written externally.
    /// Must re-evaluate unconditionally.
    case dirty
}
