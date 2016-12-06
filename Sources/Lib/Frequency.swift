import Foundation

public struct Frequency<T> where T: Hashable {
  fileprivate var dictionary: [T:Int] = [:]

  public init() {}

  public mutating func add( _ key: T ) {
    dictionary[key] = (dictionary[key] ?? 0) + 1
  }

  public mutating func add<U>( _ values: U ) where U: Sequence, U.Iterator.Element == T {
    values.forEach { self.add( $0 ) }
  }

  public func sorted( by: ((key:T, count:Int),(key:T, count:Int)) -> Bool ) -> [(T,Int)] {
    return dictionary.sorted { by( (key: $0.key, count: $0.value), (key: $1.key, count: $1.value) ) }
  }
}
