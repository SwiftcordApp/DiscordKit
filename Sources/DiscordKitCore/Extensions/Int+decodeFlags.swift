//
//  Int+.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 7/3/22.
//

import Foundation

extension Int {
	/// Takes a dict of bit positions to flags
	/// and returns an array of flags where the
	/// corrosponding bit in the Int is true
	func decodeFlags<T: RawRepresentable & CaseIterable>(flags: T) -> [T] where T.RawValue == Int {
		var decoded: [T] = []
		T.allCases.forEach { flag in
			if (self & (1 << flag.rawValue)) != 0 { decoded.append(flag) }
		}
		return decoded
	}
}
