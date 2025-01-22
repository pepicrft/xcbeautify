import ArgumentParser
import Foundation

package struct SemanticVersion: Comparable, ExpressibleByArgument {
    let major: UInt
    let minor: UInt
    let patch: UInt

    public init?(argument: String) {
        let components = argument.split(separator: ".")

        guard
            (1...3).contains(components.count)
        else {
            return nil
        }

        let _major = components[0]
        let _minor = components[safe: 1] ?? "0"
        let _patch = components[safe: 2] ?? "0"

        guard
            let major = UInt(_major),
            let minor = UInt(_minor),
            let patch = UInt(_patch)
        else {
            return nil
        }

        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major < rhs.major { return true }
        if lhs.major > rhs.major { return false }

        if lhs.minor < rhs.minor { return true }
        if lhs.minor > rhs.minor { return false }

        return lhs.patch < rhs.patch
    }
}
