/// :nodoc:
public struct CombinationIterator<Element> : IteratorProtocol {
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]
  /// :nodoc:
  mutating public func next() -> [Element]? {
    for (max, curInd) in zip(coll.indices.reversed(), inds.indices.reversed()) where max != inds[curInd] {
        inds[curInd] += 1
        curr[curInd] = coll[inds[curInd]]
        for j in inds.indices.dropFirst(curInd + 1) {
          inds[j] = inds[j-1].advanced(by: 1)
          curr[j] = coll[inds[j]]
        }
        return curr
    }
    return nil
  }

  internal init( coll: [Element], curr: [Element], inds: [Int] ) {
    self.coll = coll
    self.curr = curr
    self.inds = inds
  }
}
/// :nodoc:
public struct CombinationSequence<Element> : LazySequenceProtocol {
  
  private let start: [Element]
  private let col  : [Element]
  private let inds : [Int]
  /// :nodoc:
  public func makeIterator() -> CombinationIterator<Element> {
    let result = CombinationIterator<Element>(coll: col, curr: start, inds: inds)
    return result
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = Array(col.prefix(upTo:n))
    var inds = Array(col.indices.prefix(upTo:n))
    if !inds.isEmpty {
      inds[n.advanced(by: -1)] -= 1
    }
    self.inds = inds
  }
}
/// :nodoc:
public struct RepeatingCombinationIterator<Element> : IteratorProtocol {
  
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]
  private let max : Int
  /// :nodoc:
  mutating public func next() -> [Element]? {
    for curInd in inds.indices.reversed() where max != inds[curInd] {
      inds[curInd] += 1
      curr[curInd] = coll[inds[curInd]]
      for j in (curInd+1)..<inds.count {
        inds[j] = inds[j-1]
        curr[j] = coll[inds[j]]
      }
      return curr
    }
    return nil
  }

  internal init( coll: [Element], curr: [Element], inds: [Int], max: Int ) {
    self.coll = coll
    self.curr = curr
    self.inds = inds
    self.max = max
  }
}
/// :nodoc:
public struct RepeatingCombinationSequence<Element> : LazySequenceProtocol {
  
  private let start: [Element]
  private let inds : [Int]
  private let col  : [Element]
  private let max  : Int
  /// :nodoc:
  public func makeIterator() -> RepeatingCombinationIterator<Element> {
    return RepeatingCombinationIterator(coll: col, curr: start, inds: inds, max: max)
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = col.first.map { x in Array(repeating: x, count: n) } ?? []
    var inds = Array(repeating: col.startIndex, count: n)
    if !inds.isEmpty { inds[n-1] -= 1 }
    self.inds = inds
    max = col.endIndex.advanced(by: -1)
  }
}


extension Sequence {
  /**
  Returns the combinations without repetition of length `n` of `self`
  */
  public func combos(n: Int) -> [[Iterator.Element]] {
    return Array(CombinationSequence(n: n, col: Array(self)))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`
  */
  public func combosWithRep(n: Int) -> [[Iterator.Element]] {
    return Array(RepeatingCombinationSequence(n: n, col: Array(self)))
  }
  /**
  Returns the combinations without repetition of length `n` of `self`, generated lazily
  and on-demand
  */
  public func lazyCombos(n: Int) -> CombinationSequence<Iterator.Element> {
    return CombinationSequence(n: n, col: Array(self))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`, generated lazily and
  on-demand
  */
  public func lazyCombosWithRep(n: Int) -> RepeatingCombinationSequence<Iterator.Element> {
    return RepeatingCombinationSequence(n: n, col: Array(self))
  }
}

/*
// function combinations(a) { // a = new Array(1,2)
//   var fn = function(n, src, got, all) {
//     if (n == 0) {
//       if (got.length > 0) {
//         all[all.length] = got;
//       }
//       return;
//     }
//     for (var j = 0; j < src.length; j++) {
//       fn(n - 1, src.slice(j + 1), got.concat([src[j]]), all);
//     }
//     return;
//   }
//   var all = [];
//   for (var i=0; i < a.length; i++) {
//     fn(i, a, [], all);
//   }
//   all.push(a);
//   return all;
// }

public struct CombinationIterator<T>: IteratorProtocol {
  var elements: [T]
  var including: [Bool]
  let min: Int
  let max: Int

  // start within elements
  var i: Int

  // number of items we're taking [min...max]
  var n: Int

  var finished: Bool = false

  init<U: Collection>( elements: U, min: Int, max: Int ) where U.Iterator.Element == T, U.IndexDistance == Int {
    precondition( min > 0 && min <= max && max <= elements.count )

    self.elements = Array(elements)
    self.including = [Bool](repeating: false, count: elements.count)
    self.min = min
    self.max = max
    self.i = min - 1
    self.n = min

    for i in 0..<min {
      including[i] = true
    }
  }

  // Without recursions, generate all combinations in sequence. Basic logic:
  // put n items in the first n of m slots; each step, if right most slot can
  // be moved one slot further right, do so; otherwise find right most item
  // that can be moved, move it one step and put all items already to its right
  // next to it.

  public mutating func next() -> [T]? {
    if finished { return nil }

    defer { nextCombination() }

    var result = [T]()
    result.reserveCapacity( n )

    for (i, include) in including.enumerated() {
      if include {
        result.append( elements[i] )
      }
    }

    return result
  }

  mutating func nextCombination() {

  }
}

public struct Combination<T>: Sequence {
  public typealias Iterator = CombinationIterator<T>
  var elements: [T]
  var min: Int
  var max: Int

  public init<C: Collection>( _ elements: C, min: Int = 1, max: Int = 0 ) where C.Iterator.Element == T {
    self.elements = Array(elements)
    self.min = min
    if max == 0 {
      self.max = self.elements.count
    } else {
      self.max = max
    }
  }

  public func makeIterator() -> Iterator {
    return Iterator( elements: elements, min: min, max: max )
  }
}
*/
