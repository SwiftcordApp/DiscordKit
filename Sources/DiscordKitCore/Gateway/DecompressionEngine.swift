//
//  DecompressionEngine.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation
import Logging

#if os(macOS) || os(iOS)
import Compression

enum GatewayDecompressionResult {
    case waitingForMoreData
    case payload(String)
    case failure
}

/// Decompresses `zlib-stream`-compressed payloads received
/// from the Gateway
///
/// The Gateway sends compressed packets when the `compression` option is
/// set to `zlib-stream`. The packets needs to be run through a shared
/// decompression context for proper decompression. This class decompresses
/// these packets with the built-in `Compression` framework.
///
/// > A shared (de)compression stream is allocated for the lifetime
/// > of this class. Destroy and recreate an instance of ``DecompressionEngine``
/// > to start with a fresh decompression stream.
public class DecompressionEngine {
    private static let ZLIB_SUFFIX = Data([0x00, 0x00, 0xff, 0xff]), BUFFER_SIZE = 32_768

    private static let log = Logger(label: "DecompressionEngine", level: nil)
    private var buf = Data(), stream: compression_stream, status: compression_status,
                decompressing = false
    private let streamSourceStub: UnsafeMutablePointer<UInt8>
    private let streamDestinationStub: UnsafeMutablePointer<UInt8>
    private var streamInitialized = false

    /// Inits an instance of ``DecompressionEngine``
    ///
    /// A compression stream is created and initialised, which is destroyed
    /// in `deinit`. All data is run though this compression stream for decompression.
    public init() {
        streamSourceStub = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        streamDestinationStub = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        streamSourceStub.initialize(to: 0)
        streamDestinationStub.initialize(to: 0)
        stream = compression_stream(
            dst_ptr: streamDestinationStub,
            dst_size: 0,
            src_ptr: UnsafePointer(streamSourceStub),
            src_size: 0,
            state: nil
        )
        status = COMPRESSION_STATUS_OK
        status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)

        guard status != COMPRESSION_STATUS_ERROR else {
            Self.log.critical("Couldn't init compression stream!")
            return
        }
        streamInitialized = true
    }

    deinit {
        if streamInitialized {
            compression_stream_destroy(&stream)
        }
        streamSourceStub.deinitialize(count: 1)
        streamSourceStub.deallocate()
        streamDestinationStub.deinitialize(count: 1)
        streamDestinationStub.deallocate()
    }

    /// Push compressed data into the decompression `Data` buffer
    ///
    /// Appends compressed data into a buffer until the `ZLIB_SUFFIX` is
    /// reached. The whole buffer is then decompressed.
    ///
    /// - Parameter data: The data to push into the decompression buffer
    ///
    /// - Returns: `String` of decompressed data, or nil if the compressed
    /// data is not yet complete
    func pushGatewayData(_ data: Data) -> GatewayDecompressionResult {
        buf.append(data)

        guard buf.count >= 4, buf.suffix(4) == DecompressionEngine.ZLIB_SUFFIX else {
            Self.log.debug("Appending to buf", metadata: ["buf.count": "\(buf.count)"])
            return .waitingForMoreData
        }

        guard let output = decompress(buf) else {
            buf.removeAll()
            return .failure
        }

        buf.removeAll()
        return .payload(String(decoding: output, as: UTF8.self))
    }

    public func push_data(_ data: Data) -> String? {
        switch pushGatewayData(data) {
        case .waitingForMoreData, .failure:
            return nil
        case .payload(let payload):
            return payload
        }
    }
}

public extension DecompressionEngine {
    fileprivate func decompress(_ data: Data) -> Data? {
        guard streamInitialized else {
            Self.log.warning("Compression stream is unavailable")
            return nil
        }
        guard !decompressing else {
            Self.log.warning("Another decompression is currently taking place, skipping")
            return nil
        }
        decompressing = true

        // ZLib header, strip it if necessary
        var data = data.prefix(2) == Data([0x78, 0x9C]) || data.prefix(2) == Data([0x78, 0xDA]) ? data.dropFirst(2) : data

        // Configure stream source and destinations (will be changed in loop)
        stream.src_size = 0
        let bufferSize = DecompressionEngine.BUFFER_SIZE
        let destinationBufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        stream.dst_ptr = destinationBufferPointer
        stream.dst_size = bufferSize

        // Buffer for decompressed chunks
        var decompressed = Data(), srcChunk: Data?

        defer {
            decompressing = false
            destinationBufferPointer.deallocate()
        }

        // Loop over this until there's nothing left to decompress or an error occurred
        repeat {
            var flags = Int32(0)

            // If this iteration has consumed all of the source data,
            // read a new tempData buffer from the input file.
            if stream.src_size == 0 {
                srcChunk = data.prefix(bufferSize)
                data = data.dropFirst(srcChunk!.count)

                stream.src_size = srcChunk!.count
                if stream.src_size < bufferSize {
                    // This technically shouldn't be used this way...
                    flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
            }

            // Perform compression or decompression.
            if let srcChunk = srcChunk {
                srcChunk.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                    guard let baseAddress = buffer.bindMemory(to: UInt8.self).baseAddress else { return }
                    stream.src_ptr = baseAddress.advanced(by: buffer.count - stream.src_size)
                    status = compression_stream_process(&stream, flags)
                }
            }

            switch status {
            case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                // Get the number of bytes put in the destination buffer. This is the difference between
                // stream.dst_size before the call (here bufferSize), and stream.dst_size after the call.
                let count = bufferSize - stream.dst_size

                let outputData = Data(bytesNoCopy: destinationBufferPointer, count: count, deallocator: .none)
                decompressed.append(contentsOf: outputData)

                // Reset the stream to receive the next batch of output.
                stream.dst_ptr = destinationBufferPointer
                stream.dst_size = bufferSize
            case COMPRESSION_STATUS_ERROR:
                // Discord zlib-stream frames can finish at a flush boundary that
                // Apple's Compression reports as ERROR after producing output.
                // Treat an empty result as an actual decompression failure.
                if decompressed.isEmpty {
                    return nil
                }
            default: break
            }
        } while status == COMPRESSION_STATUS_OK

        Self.log.trace("Decompressed data", metadata: [
            "original.count": "\(buf.count)",
            "decompressed.count": "\(decompressed.count)"
        ])

        return decompressed
    }
}

#else
import SWCompression

enum GatewayDecompressionResult {
    case waitingForMoreData
    case payload(String)
    case failure
}

public class DecompressionEngine {
    private var buf = Data()

    private static let ZLIB_SUFFIX = Data([0x00, 0x00, 0xff, 0xff]), BUFFER_SIZE = 32_768
    private static let log = Logger(label: "DecompressionEngine", level: nil)

    func pushGatewayData(_ data: Data) -> GatewayDecompressionResult {
        buf.append(data)

        guard buf.count >= 4, buf.suffix(4) == DecompressionEngine.ZLIB_SUFFIX else {
            Self.log.debug("Appending to buf", metadata: ["buf.count": "\(buf.count)"])
            return .waitingForMoreData
        }

        guard let output = try? ZlibArchive.unarchive(archive: buf) else {
            buf.removeAll()
            return .failure
        }
        buf.removeAll()

        return .payload(String(decoding: output, as: UTF8.self))
    }

    public func push_data(_ data: Data) -> String? {
        switch pushGatewayData(data) {
        case .waitingForMoreData, .failure:
            return nil
        case .payload(let payload):
            return payload
        }
    }
}
#endif
