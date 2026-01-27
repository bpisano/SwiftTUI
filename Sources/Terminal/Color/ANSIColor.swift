//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation

public enum ANSIColor: Equatable, Hashable, Codable, Sendable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    case brightBlack
    case brightRed
    case brightGreen
    case brightYellow
    case brightBlue
    case brightMagenta
    case brightCyan
    case brightWhite
    case rgb(r: UInt8, g: UInt8, b: UInt8)
    case `default`

    public var foregroundCode: String {
        switch self {
        case .black: return "\u{001B}[30m"
        case .red: return "\u{001B}[31m"
        case .green: return "\u{001B}[32m"
        case .yellow: return "\u{001B}[33m"
        case .blue: return "\u{001B}[34m"
        case .magenta: return "\u{001B}[35m"
        case .cyan: return "\u{001B}[36m"
        case .white: return "\u{001B}[37m"
        case .brightBlack: return "\u{001B}[90m"
        case .brightRed: return "\u{001B}[91m"
        case .brightGreen: return "\u{001B}[92m"
        case .brightYellow: return "\u{001B}[93m"
        case .brightBlue: return "\u{001B}[94m"
        case .brightMagenta: return "\u{001B}[95m"
        case .brightCyan: return "\u{001B}[96m"
        case .brightWhite: return "\u{001B}[97m"
        case .rgb(let r, let g, let b): return "\u{001B}[38;2;\(r);\(g);\(b)m"
        case .default: return "\u{001B}[39m"
        }
    }

    public var backgroundCode: String {
        switch self {
        case .black: return "\u{001B}[40m"
        case .red: return "\u{001B}[41m"
        case .green: return "\u{001B}[42m"
        case .yellow: return "\u{001B}[43m"
        case .blue: return "\u{001B}[44m"
        case .magenta: return "\u{001B}[45m"
        case .cyan: return "\u{001B}[46m"
        case .white: return "\u{001B}[47m"
        case .brightBlack: return "\u{001B}[100m"
        case .brightRed: return "\u{001B}[101m"
        case .brightGreen: return "\u{001B}[102m"
        case .brightYellow: return "\u{001B}[103m"
        case .brightBlue: return "\u{001B}[104m"
        case .brightMagenta: return "\u{001B}[105m"
        case .brightCyan: return "\u{001B}[106m"
        case .brightWhite: return "\u{001B}[107m"
        case .rgb(let r, let g, let b): return "\u{001B}[48;2;\(r);\(g);\(b)m"
        case .default: return "\u{001B}[49m"
        }
    }
}
