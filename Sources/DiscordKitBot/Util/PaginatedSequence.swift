import DiscordKitCore

/// Paginated data from Discord's API. 
/// 
/// This is used whenever we need to fetch data from Discord's API in chunks. You can access the data using a `for-in` loop.
/// For example, the following code will print the username of every member in a guild.
/// 
/// ```swift
/// for try await member: Member in guild.members {
///     print(member.user!.username)
/// }
/// ```
/// 
/// We handle all of the paging code internally, so there's nothing you have to worry about.
public struct PaginatedSequence<Element> : AsyncSequence {
    private let pageFetch: (Snowflake?) async throws -> [Element]
    private let snowflakeGetter: (Element) -> Snowflake

    /// Create a new PaginatedList.
    /// 
    /// As an example, here's the implementation for the server Member List:
    /// ```swift
    /// PaginatedList({ try await self.rest.listGuildMembers(self.id, $0) }, { $0.user!.id })
    /// ```
    /// For the `pageFetch` parameter, I provided a function that returns the first 50 `Member` objects after a specific user ID.
    /// I passed the provided Snowflake as the after value, so that discord provides the 50 `Member`s after that ID.
    ///
    /// For the `afterGetter`, I simply look the provided `Element`, and transformed it to get the User ID.
    ///
    /// - Parameters:
    ///   - pageFetch: The api method that gets the paginated data. Use the `Snowflake` as the `after` value.
    ///   - snowflakeGetter: A method that takes the incoming element and transforms it into the Snowflake ID needed for pagination.
    internal init(_ pageFetch: @escaping (Snowflake?) async throws -> [Element], _ snowflakeGetter: @escaping (Element) -> Snowflake) {
        self.pageFetch = pageFetch
        self.snowflakeGetter = snowflakeGetter
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let pageFetch: (Snowflake?) async throws -> [Element]
        private let snowflakeGetter: (Element) -> Snowflake

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
                    after = snowflakeGetter(last)
                }
            }

            let result = buffer[currentIndex]
            currentIndex += 1
            return result
        }

        internal init(_ pageFetch: @escaping (Snowflake?) async throws -> [Element], _ afterGetter: @escaping (Element) -> Snowflake) {
            self.pageFetch = pageFetch
            self.snowflakeGetter = afterGetter
        }
    }

    public typealias Element = Element

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(pageFetch, snowflakeGetter)
    }
}