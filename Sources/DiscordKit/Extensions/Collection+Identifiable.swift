public extension Collection where Element: Identifiable {
    /// Returns the first element of the sequence that has an identifier matching the provided identifier.
    /// - Parameter identifier: The stable identity of the element you want to find.
    /// - Returns: The first element of the sequence that has an identifier matching the provided identifier.
    func first(identifiedBy identifier: Element.ID) -> Element? {
        first { $0.id == identifier }
    }

    /// Returns the first element of the sequence that has an identifier matching the identifier of the provided element.
    /// - Parameter element: The identifiable element you want to find.
    /// - Returns: The first element of the sequence that has an identifier matching the identifier of the provided element.
    func first(matchingIdentifierFor element: Element) -> Element? {
        first(identifiedBy: element.id)
    }

    /// Returns the first index in the sequence that has an identifier matching the provided identifier.
    /// - Parameter identifier: The stable identity of the element you want to find.
    /// - Returns: The first index in the sequence that has an identifier matching the provided identifier.
    func firstIndex(identifiedBy identifier: Element.ID) -> Index? {
        firstIndex { $0.id == identifier }
    }

    /// Returns the first index in the sequence that has an identifier matching the identifier of the provided element.
    /// - Parameter element: The identifiable element you want to find.
    /// - Returns: The first index in the sequence that has an identifier matching the identifier of the provided element.
    func firstIndex(matchingIdentifierFor element: Element) -> Index? {
        firstIndex(identifiedBy: element.id)
    }
}

public extension RangeReplaceableCollection where Element: Identifiable {
    /// Removes all the elements that have the given identifier.
    ///
    /// Use this method to remove every element in a collection that has
    /// the given identifier. The order of the remaining elements is preserved.
    /// - Parameter identifier: The stable identity of the element you want to find.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    mutating func removeAll(identifiedBy identifier: Element.ID) {
        removeAll { $0.id == identifier }
    }

    /// Removes all the elements that have the same identifier as the given element.
    ///
    /// Use this method to remove every element in a collection that has
    /// the same identifier as the given element. The order of the remaining elements
    /// is preserved.
    /// - Parameter element: The identifiable element you want to find.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    mutating func removeAll(matchingIdentifierFor element: Element) {
        removeAll(identifiedBy: element.id)
    }
}
