public struct PermutationIterator<T>: IteratorProtocol {
  var elements: [T]
  var index: [Int]
  var i: Int = 1
  let N: Int
  var initial: Bool = true

  init<U: Collection>( elements: U ) where U.Iterator.Element == T, U.IndexDistance == Int {
    self.elements = Array(elements)
    self.index = [Int]( repeating: 0, count: elements.count )
    self.N = elements.count
  }

  public mutating func next() -> [T]? {
    if initial {
      initial = false
      return elements
    }

    while i < N {
      if index[i] < i {
        let swap = i % 2 * index[i]
        let tmp = elements[swap]
        elements[swap] = elements[i]
        elements[i] = tmp

        defer {
          index[i] += 1
          i = 1
        }

        return elements
      } else {
        defer { i += 1 }
        index[i] = 0
      }
    }

    return nil
  }
}

public struct Permutations<T>: Sequence {
  public typealias Iterator = PermutationIterator<T>

  let elements: [T]

  public init<C: Collection>( _ elements: C ) where C.Iterator.Element == T {
    self.elements = Array(elements)
  }

  public func makeIterator() -> Iterator {
    return Iterator( elements: elements )
  }
}
