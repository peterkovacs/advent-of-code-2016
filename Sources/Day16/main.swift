import Foundation
import FootlessParser

// 
// let a = data 
// let b = a
// b = ~b
// data = a + 0 + b
// make a checksum for data[0..<disk size]
// each slice of two:
//   00, 11 -> 1
//   10, 01 -> 0
// repeat until end up with *odd* number of checksum bits.
// 

func dragon( data: [UInt8] ) -> [UInt8] {
  var result = data
  result.reserveCapacity( data.count * 2 + 1 )
  result.append( 0 )
  result.append( contentsOf: data.reversed().map { ($0 ^ 1) as UInt8 } )
  return result
}

func checksum( data: ArraySlice<UInt8> ) -> [UInt8] {
  var result = [UInt8]()
  result.reserveCapacity( data.count / 2 + 1 )

  for i in stride( from: 0, to: data.count, by: 2 ) {
    switch ( data[i], data[ i + 1 ] ) {
    case (0,0), (1, 1):
      result.append( 1 )
    default:
      result.append( 0 )
    }
  }

  if result.count % 2 == 0 {
    return checksum( data: ArraySlice<UInt8>(result) )
  } else {
    return result
  }
}

let zero = { _ in 0 as UInt8 } <^> char("0")
let one = { _ in 1 as UInt8 } <^> char("1")
let parser = oneOrMore( zero <|> one )
var data = try parse( parser, CommandLine.arguments[1] )
let length = Int( CommandLine.arguments[2] )!

while( data.count < length ) {
  data = dragon( data: data )
}

print( checksum( data: data[ 0..<length ] ).map { "\($0)" }.joined() )
