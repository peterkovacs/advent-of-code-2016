import Foundation

public struct Input: Sequence, IteratorProtocol {
  public init() {
  }

  public typealias Element = String
  public mutating func next() -> String? {
    return readLine( strippingNewline: true )
  }
}
