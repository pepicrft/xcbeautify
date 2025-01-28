import ArgumentParser
import Darwin
import Foundation
import XcbeautifyLib

@main
struct ParsingCheck: ParsableCommand {

    @Option
    var filePath: String

    @Option
    var uncapturedOutput: Int

    enum ParsingCheckError: Error {
        case dataReadError
        case noData
        case regression(Int)
    }

    func run() throws {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            throw ParsingCheckError.noData
        }

        guard !data.isEmpty else {
            throw ParsingCheckError.noData
        }

        var buildLog: [String] = String(decoding: data, as: UTF8.self)
            .components(separatedBy: .newlines)

        let parser = Parser()

        var uncapturedOutput = 0

        while !buildLog.isEmpty {
            let line = buildLog.removeFirst()
            if !line.isEmpty, parser.parse(line: line) == nil {
                uncapturedOutput += 1
            }
        }

        guard self.uncapturedOutput == uncapturedOutput else {
            throw ParsingCheckError.regression(uncapturedOutput)
        }
    }
}
