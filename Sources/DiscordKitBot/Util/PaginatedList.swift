import DiscordKitCore

public struct PaginatedList<Element> : AsyncSequence {
    let pageFetch: (Snowflake?) async throws -> [Element]
    let afterGetter: (Element) -> Snowflake

    public struct AsyncIterator: AsyncIteratorProtocol {
        let pageFetch: (Snowflake?) async throws -> [Element]
        let afterGetter: (Element) -> Snowflake

        private var buffer: [Element] = []
        private var currentIndex: Int = 0
        private var after: Snowflake? = nil

        public mutating func next() async throws -> Element? {
            if currentIndex >= buffer.count || buffer.isEmpty {
                let tmpBuffer: [Element] = try await pageFetch(after)
                guard !tmpBuffer.isEmpty else { return nil }

                buffer = tmpBuffer
                currentIndex = 0
                if let last = tmpBuffer.last {
                    after = afterGetter(last)
                }
            }

            let result = buffer[currentIndex]
            currentIndex += 1
            return result
        }

        public init(_ pageFetch: @escaping (Snowflake?) async throws -> [Element], _ afterGetter: @escaping (Element) -> Snowflake) {
            self.pageFetch = pageFetch
            self.afterGetter = afterGetter
        }
    }

    public typealias Element = Element

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(pageFetch, afterGetter)
    }
}