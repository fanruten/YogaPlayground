import Foundation

public class TableModel {
    public let readyLoadMore: Bool
    public let lastLoadFinishedWithError: Bool
    public let sections: [TableSection]

    public init(readyLoadMore: Bool, lastLoadFinishedWithError: Bool = false, sections: [TableSection]) {
        self.readyLoadMore = readyLoadMore
        self.lastLoadFinishedWithError = lastLoadFinishedWithError
        self.sections = sections
    }

    public convenience init() {
        self.init(readyLoadMore: false, lastLoadFinishedWithError: false, sections: [])
    }
}

extension TableModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = ""
        result += "readyLoadMore: \(readyLoadMore)\n"
        result += "lastLoadFinishedWithError: \(lastLoadFinishedWithError)\n"
        result += "sections:\n"
        for section in sections {
            result += "\t sections \"\(section.identifier)\":\n"
            for item in section.items {
                result += "\t\t item \"\(item.identifier)\" \"\(item.cellHelper)\"\n"
            }
        }

        return result
    }
}
