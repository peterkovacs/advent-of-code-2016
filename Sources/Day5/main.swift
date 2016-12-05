import Foundation
import CryptoSwift

struct HashSequence: Sequence, IteratorProtocol {
  var val: Int = 0

  func hash( number: Int ) -> ( Int, [UInt8] ) {
    var digest = MD5()
    _ = try! digest.update( withBytes: "abbhdwsy".utf8.map({$0}) )
    _ = try! digest.update( withBytes: String(number).utf8.map({$0}) )

    return ( number, try! digest.finish() )
  }

  func valid( _ data: (Int,[UInt8]) ) -> Bool {
    return data.1[0] == 0 && data.1[1] == 0 && data.1[2] < 16
  }

  // I couldn't get an infinite sequence of this hash to work lazily with a
  // filter. Therefore, I'm doing the filtering directly in this method.
  mutating func next() -> (Int,[UInt8])? {
    while( true ) {
      defer { val = val + 1 }
      let result = hash( number: val )
      if valid( result ) {
        return result
      }
    }
  }
}

let result = Array( HashSequence().prefix( 8 ) )

print( "PART 1" )
print( result.map { String(format: "%x", ($0.1[2] & 0xf)) } .joined() )

print( "PART 2" )
var part2 = [UInt8?]( repeating: nil, count: 8 )
for (_,i) in HashSequence() {
  if Int(i[2] & 0xf) < 8 && part2[ Int(i[2] & 0xf) ] == nil {
    part2[ Int(i[2] & 0xf) ] = (i[3] >> 4) & 0xf
  }

  if part2.filter({ $0 == nil }).count == 0 {
    break
  }
}

print( part2.map { String(format: "%x", $0!) } .joined() )
