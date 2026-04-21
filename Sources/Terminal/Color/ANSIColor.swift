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
    case gray
    case softBlack
    case softRed
    case softGreen
    case softYellow
    case softBlue
    case softMagenta
    case softCyan
    case softWhite
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
        case .white: return "\u{001B}[97m"
        case .gray: return "\u{001B}[90m"
        case .softBlack: return "\u{001B}[90m"
        case .softRed: return "\u{001B}[91m"
        case .softGreen: return "\u{001B}[92m"
        case .softYellow: return "\u{001B}[93m"
        case .softBlue: return "\u{001B}[94m"
        case .softMagenta: return "\u{001B}[95m"
        case .softCyan: return "\u{001B}[96m"
        case .softWhite: return "\u{001B}[37m"
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
        case .white: return "\u{001B}[107m"
        case .gray: return "\u{001B}[100m"
        case .softBlack: return "\u{001B}[100m"
        case .softRed: return "\u{001B}[101m"
        case .softGreen: return "\u{001B}[102m"
        case .softYellow: return "\u{001B}[103m"
        case .softBlue: return "\u{001B}[104m"
        case .softMagenta: return "\u{001B}[105m"
        case .softCyan: return "\u{001B}[106m"
        case .softWhite: return "\u{001B}[47m"
        case .rgb(let r, let g, let b): return "\u{001B}[48;2;\(r);\(g);\(b)m"
        case .default: return "\u{001B}[49m"
        }
    }
}
