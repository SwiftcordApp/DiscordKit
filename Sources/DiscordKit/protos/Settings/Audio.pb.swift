// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Settings/Audio.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct AudioSettings {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var user: Dictionary<UInt64,AudioContextSetting> = [:]

  public var stream: Dictionary<UInt64,AudioContextSetting> = [:]

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct AudioContextSetting {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var muted: Bool = false

  public var volume: Float = 0

  public var modifiedAt: UInt64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension AudioSettings: @unchecked Sendable {}
extension AudioContextSetting: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension AudioSettings: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "AudioSettings"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "user"),
    2: .same(proto: "stream"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMessageMap<SwiftProtobuf.ProtobufFixed64,AudioContextSetting>.self, value: &self.user) }()
      case 2: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMessageMap<SwiftProtobuf.ProtobufFixed64,AudioContextSetting>.self, value: &self.stream) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.user.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMessageMap<SwiftProtobuf.ProtobufFixed64,AudioContextSetting>.self, value: self.user, fieldNumber: 1)
    }
    if !self.stream.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMessageMap<SwiftProtobuf.ProtobufFixed64,AudioContextSetting>.self, value: self.stream, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AudioSettings, rhs: AudioSettings) -> Bool {
    if lhs.user != rhs.user {return false}
    if lhs.stream != rhs.stream {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AudioContextSetting: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "AudioContextSetting"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "muted"),
    2: .same(proto: "volume"),
    3: .standard(proto: "modified_at"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.muted) }()
      case 2: try { try decoder.decodeSingularFloatField(value: &self.volume) }()
      case 3: try { try decoder.decodeSingularFixed64Field(value: &self.modifiedAt) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.muted != false {
      try visitor.visitSingularBoolField(value: self.muted, fieldNumber: 1)
    }
    if self.volume != 0 {
      try visitor.visitSingularFloatField(value: self.volume, fieldNumber: 2)
    }
    if self.modifiedAt != 0 {
      try visitor.visitSingularFixed64Field(value: self.modifiedAt, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AudioContextSetting, rhs: AudioContextSetting) -> Bool {
    if lhs.muted != rhs.muted {return false}
    if lhs.volume != rhs.volume {return false}
    if lhs.modifiedAt != rhs.modifiedAt {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
