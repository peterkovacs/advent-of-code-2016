import Foundation
import Lib

class KeyGenerator: Sequence, IteratorProtocol {
  var hash: HashSequence

  init( salt: String, rounds: Int ) {
    hash = MemoizedHashSequence( bytes: salt, rounds: rounds )
  }

  public func next() -> Int? {
    while true {
      guard let (key, candidate) = hash.next() else { return nil }
      if let target = valid3( candidate ) {
        if valid5( target: target, key: key ) {
          return key
        }
      }
    }
  }

  func valid3( _ candidate: [UInt8] ) -> UInt8? {
    for i in 0..<(candidate.count - 1) {
      let hi0 = ( candidate[i] & 0xF0 ) >> 4
      let lo0 = candidate[i] & 0xF
      let hi1 = ( candidate[i+1] & 0xF0 ) >> 4
      let lo1 = candidate[i+1] & 0xF

      if ( hi0 == lo0 && lo0 == hi1 ) || ( lo0 == hi1 && hi1 == lo1 ) {
        // lo0 is always in middle
        return lo0
      }
    }

    return nil
  }

  func valid5( target: UInt8, key: Int ) -> Bool {
    for n in 1...1000 {
      let next = key + n
      let candidate = hash.hash( of: next )

      for i in 0..<(candidate.count &- 2) {
        let hi0 = ( candidate[i] & 0xF0 ) >> 4

        let lo0 = candidate[i] & 0xf
        let hi1 = ( candidate[i+1] & 0xf0 ) >> 4
        let lo1 = candidate[i+1] & 0xf
        let hi2 = ( candidate[i+2] & 0xf0 ) >> 4

        let lo2 = candidate[i+2] & 0xf

        if lo0 == target && hi1 == target && lo1 == target && hi2 == target && ( hi0 == target || lo2 == target ) {
          return true
        }
      }
    }

    return false
  }
}
