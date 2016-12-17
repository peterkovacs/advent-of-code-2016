import Foundation
import CommonCrypto

public protocol ByteRepresentable {
  var byteRepresentation: [UInt8] { get }
}

internal struct Hex: Sequence, IteratorProtocol {
  var value: Int

  init( _ val: Int ) {
    self.value = val
  }

  mutating func next() -> UInt8? {
    guard value > 0 else { return nil }

    defer { 
      self.value = value / 10 
    }

    let rem = UInt8(value % 10)
    return rem &+ 0x30
  }
}


extension Int: ByteRepresentable {
  public var byteRepresentation: [UInt8] {
    var result = [UInt8]()
    if self > 0 {
      result.append( contentsOf: Hex(self).reversed() )
    } else if self == 0 {
      result.append( 0x30 )
    } else {
      result.append( 0x2d )
      result.append( contentsOf: (-self).byteRepresentation )
    }

    return result
  }
}

extension String: ByteRepresentable {
  public var byteRepresentation: [UInt8] {
    return self.utf8.map { $0 as UInt8 }
  }
}

public class MD5<T: ByteRepresentable> {
  let rounds: Int
  let bytes: [UInt8]
  var digest: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

  public init( bytes: String, rounds: Int ) {
    self.bytes = bytes.byteRepresentation
    self.rounds = rounds
  }

  public func hash( of value: T ) -> [UInt8] {
    var data = self.bytes
    data.append( contentsOf: value.byteRepresentation )

    _ = data.withUnsafeBufferPointer {
      CC_MD5( $0.baseAddress, CC_LONG( data.count ), &digest )
    }

    if rounds > 0 {
      let lookup: [UInt8] = [ 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66 ]
      var buffer = [UInt8](repeating: 0, count: 32)
      for _ in 0..<rounds {

        for i in stride( from: 0, to: 32, by: 2 ) {
          let j: Int   = i / 2
          let hi: Int  = ( Int(digest[j]) & 0xf0 ) >> 4 
          let lo: Int  = ( Int(digest[j]) & 0xf )
          buffer[i]    = lookup[ hi ]
          buffer[i&+1] = lookup[ lo ]
        }

        _ = buffer.withUnsafeBufferPointer {
          CC_MD5( $0.baseAddress, CC_LONG( buffer.count ), &digest )
        }
      }
    }

    return digest
  }
}

public class HashSequence: MD5<Int>, IteratorProtocol, Sequence {
  public typealias Element = (Int,[UInt8])
  var val: Int = 0

  public func next() -> (Int,[UInt8])? {
    defer { val = val &+ 1 }
    return ( val, hash( of: val ) )
  }
}

public class MemoizedHashSequence: HashSequence {
  public typealias Element = (Int,[UInt8])
  var memo: [Int:[UInt8]] = [:]

  public override init( bytes: String, rounds: Int ) {
    super.init( bytes: bytes, rounds: rounds )
  }

  public override func hash( of val: Int ) -> [UInt8] {
    if let result = memo[ val ] {
      return result
    }

    let result = super.hash( of: val )
    memo[ val ] = result
    return result
  }
}

