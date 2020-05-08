extension Collection {

    private func distance(from startIndex: Index) -> Int {
        return distance(from: startIndex, to: self.endIndex)
    }

    private func distance(to endIndex: Index) -> Int {
        return distance(from: self.startIndex, to: endIndex)
    }

    public subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }

    public subscript(safe bounds: Range<Index>) -> SubSequence? {
        if distance(to: bounds.lowerBound) >= 0 && distance(from: bounds.upperBound) >= 0 {
            return self[bounds]
        }
        return nil
    }

    public subscript(safe bounds: ClosedRange<Index>) -> SubSequence? {
        if distance(to: bounds.lowerBound) >= 0 && distance(from: bounds.upperBound) > 0 {
            return self[bounds]
        }
        return nil
    }
}
