//
//  String+random.swift
//  DiscordAPI
//
//  Created by royal on 16/05/2022.
//

import Foundation

// From: https://stackoverflow.com/a/39425959
extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !contains { !$0.isEmoji } }

    var containsOnlyEmojiAndSpaces: Bool {
        String(self.filter {  !$0.isWhitespace  }).containsOnlyEmoji
    }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension String {
    var fileExtension: String {
        NSString(string: self).pathExtension
    }
}

extension String {
    /// Returns true if the string has any content after stripping spaces/newlines
    func hasContent() -> Bool {
        let text = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return !text.isEmpty
    }
}

public extension String {
	static func random(count: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<count).map { _ in letters.randomElement()! })
	}

    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
