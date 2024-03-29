// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Settings/GameLibrary.proto
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

public struct GameLibrarySettings {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var installShortcutDesktop: SwiftProtobuf.Google_Protobuf_BoolValue {
    get {return _installShortcutDesktop ?? SwiftProtobuf.Google_Protobuf_BoolValue()}
    set {_installShortcutDesktop = newValue}
  }
  /// Returns true if `installShortcutDesktop` has been explicitly set.
  public var hasInstallShortcutDesktop: Bool {return self._installShortcutDesktop != nil}
  /// Clears the value of `installShortcutDesktop`. Subsequent reads from it will return its default value.
  public mutating func clearInstallShortcutDesktop() {self._installShortcutDesktop = nil}

  public var installShortcutStartMenu: SwiftProtobuf.Google_Protobuf_BoolValue {
    get {return _installShortcutStartMenu ?? SwiftProtobuf.Google_Protobuf_BoolValue()}
    set {_installShortcutStartMenu = newValue}
  }
  /// Returns true if `installShortcutStartMenu` has been explicitly set.
  public var hasInstallShortcutStartMenu: Bool {return self._installShortcutStartMenu != nil}
  /// Clears the value of `installShortcutStartMenu`. Subsequent reads from it will return its default value.
  public mutating func clearInstallShortcutStartMenu() {self._installShortcutStartMenu = nil}

  public var disableGamesTab: SwiftProtobuf.Google_Protobuf_BoolValue {
    get {return _disableGamesTab ?? SwiftProtobuf.Google_Protobuf_BoolValue()}
    set {_disableGamesTab = newValue}
  }
  /// Returns true if `disableGamesTab` has been explicitly set.
  public var hasDisableGamesTab: Bool {return self._disableGamesTab != nil}
  /// Clears the value of `disableGamesTab`. Subsequent reads from it will return its default value.
  public mutating func clearDisableGamesTab() {self._disableGamesTab = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _installShortcutDesktop: SwiftProtobuf.Google_Protobuf_BoolValue? = nil
  fileprivate var _installShortcutStartMenu: SwiftProtobuf.Google_Protobuf_BoolValue? = nil
  fileprivate var _disableGamesTab: SwiftProtobuf.Google_Protobuf_BoolValue? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension GameLibrarySettings: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension GameLibrarySettings: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "GameLibrarySettings"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "install_shortcut_desktop"),
    2: .standard(proto: "install_shortcut_start_menu"),
    3: .standard(proto: "disable_games_tab"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._installShortcutDesktop) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._installShortcutStartMenu) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._disableGamesTab) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._installShortcutDesktop {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._installShortcutStartMenu {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._disableGamesTab {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: GameLibrarySettings, rhs: GameLibrarySettings) -> Bool {
    if lhs._installShortcutDesktop != rhs._installShortcutDesktop {return false}
    if lhs._installShortcutStartMenu != rhs._installShortcutStartMenu {return false}
    if lhs._disableGamesTab != rhs._disableGamesTab {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
