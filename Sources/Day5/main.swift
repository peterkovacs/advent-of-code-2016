import Foundation
import CommonCrypto

struct HashSequence: Sequence, IteratorProtocol {
  var val: Int = 0
  var bytes: [UInt8] = "abbhdwsy".utf8.map({$0})
  var digest: [UInt8] = [UInt8]( repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH) )

  mutating func hash( number: Int ) -> ( Int, [UInt8] ) {
    var bytes = self.bytes
    bytes.append( contentsOf: String(number).utf8.map({$0}) )

    _ = bytes.withUnsafeBufferPointer {
      CC_MD5( $0.baseAddress, CC_LONG(bytes.count), &digest )
    }

    return ( number, digest )
  }

  static func valid( _ data: (Int,[UInt8]) ) -> Bool {
    return data.1[0] == 0 && data.1[1] == 0 && data.1[2] < 16
  }

  mutating func next() -> (Int,[UInt8])? {
    defer { val = val + 1 }
    return hash( number: val )
  }
}

let sequence = HashSequence().lazy.filter( HashSequence.valid )

print( "PART 1" )
print( sequence.prefix(8).map { String(format: "%x", ($0.1[2] & 0xf)) } .joined() )

print( "PART 2" )
var part2 = [UInt8?]( repeating: nil, count: 8 )
for (_,i) in sequence {
  if Int(i[2] & 0xf) < 8 && part2[ Int(i[2] & 0xf) ] == nil {
    part2[ Int(i[2] & 0xf) ] = (i[3] >> 4) & 0xf
  }

  if part2.filter({ $0 == nil }).count == 0 {
    break
  }
}

print( part2.map { String(format: "%x", $0!) } .joined() )
