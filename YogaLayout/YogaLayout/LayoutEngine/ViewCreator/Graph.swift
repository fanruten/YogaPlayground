import Foundation

class GraphItem<T>: CustomDebugStringConvertible {
    var item: T
    var children: [Int]

    init(item: T, children: [Int] = []) {
        self.item = item
        self.children = children
    }

    func transformed<N>(_ transform: (T) -> N) -> GraphItem<N> {
        return GraphItem<N>(item: transform(item), children: children)
    }

    public var debugDescription: String {
        return "value: \(item) children: \(children)"
    }
}

class Graph<T>: CustomDebugStringConvertible {
    var items: [GraphItem<T>]

    init(items: [GraphItem<T>]) {
        self.items = items
    }

    convenience init(root: T, childsForItem: (T) -> [T]) {
        let rootItem = GraphItem(item: root, children: [])

        var result: [GraphItem<T>] = []
        var index = 0

        var itemsForIteration: [GraphItem<T>] = [rootItem]
        while let item = itemsForIteration.first {
            itemsForIteration.removeFirst()

            result.append(item)

            for child in childsForItem(item.item) {
                let childItem = GraphItem(item: child)

                index += 1
                item.children.append(index)

                itemsForIteration.append(childItem)
            }
        }

        self.init(items: result)
    }

    func first() -> T? {
        return items.first?.item
    }

    func transform<N>(_ transform: ((T) -> N)) -> Graph<N> {
        let transformedItems = items.map { item -> GraphItem<N> in
            return item.transformed(transform)
        }
        return Graph<N>(items: transformedItems)
    }

    func traverse(_ block: (_ current: T, _ parent: T?) -> Void) {
        guard let first = items.first else {
            return
        }

        var itemsForIteration: [(GraphItem<T>, GraphItem<T>?)] = [(first, nil)]
        while let (current, parent) = itemsForIteration.first {
            itemsForIteration.removeFirst()

            block(current.item, parent?.item)

            for i in current.children {
                itemsForIteration.append((items[i], current))
            }
        }
    }

    @discardableResult func transformAndTraverseDepth<N>(_ tranform: (_ current: T, _ parent: N?) -> N?) -> Graph<N> {
        guard let first = self.items.first else {
            return Graph<N>(items: [])
        }

        var mappedItems: [GraphItem<N>] = []
        
        var itemsForIteration: [(GraphItem<T>, N?)] = [(first, nil)]
        while let (current, parent) = itemsForIteration.first {
            itemsForIteration.removeFirst()
            
            guard let transformed = tranform(current.item, parent) else {
                continue
            }
            
            mappedItems.append(GraphItem<N>(item: transformed, children: current.children))

            var children: [(GraphItem<T>, N?)] = []
            for i in current.children {
                children.append((self.items[i], transformed))
            }
            itemsForIteration = children + itemsForIteration
        }

        return Graph<N>(items: mappedItems)
    }

    @discardableResult func transformAndTraverseBreadth<N>(_ tranform: (_ current: T, _ parent: N?) -> N?) -> Graph<N> {
        guard let first = self.items.first else {
            return Graph<N>(items: [])
        }

        var mappedItems: [GraphItem<N>] = []

        var itemsForIteration: [(GraphItem<T>, N?)] = [(first, nil)]
        while let (current, parent) = itemsForIteration.first {
            itemsForIteration.removeFirst()

            guard let transformed = tranform(current.item, parent) else {
                continue
            }
            
            mappedItems.append(GraphItem<N>(item: transformed, children: current.children))

            for i in current.children {
                itemsForIteration.append((self.items[i], transformed))
            }
        }

        return Graph<N>(items: mappedItems)
    }

    // MARK: - CustomDebugStringConvertible

    public var debugDescription: String {
        var result: String = ""
        for (i, item) in items.enumerated() {
            result += "\(i) ==> \(item)\n"
        }
        return result
    }
}
