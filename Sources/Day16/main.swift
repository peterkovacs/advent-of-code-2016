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

// it seems like we could figure out what the nth bit is in our final data set
// by figuring out which multiple of our original data size + 1 we are in.
//
// If we're the last bit, then we need to calculate the "joiner" value.
// If we're not, then we just figure out if we're in our original data or its
// reversed/negated counterpart. And you can do that just by checking if the
// dividend is even or not.
// 
// I'm not sure how to calculate the joiner, but its easy enough to generate -- you can do it with the same method.
// But you still end up with DiskSize / OriginalInput.count+1 elements in your array.
// 
// There definitely does seem to be a pattern to the data, but I can't find anything that actually repeats.


func dragon( data: [UInt8] ) -> [UInt8] {
  var result = data
  result.reserveCapacity( data.count * 2 + 1 )
  result.append( 0 )
  result.append( contentsOf: data.reversed().map { ($0 ^ 1) as UInt8 } )
  return result
}

func checksum( data: ArraySlice<UInt8> ) -> [UInt8] {
  var result = [UInt8]()

  // Calculate largest power of 2 that divides data.count.
  let chunksize = data.count & ~(data.count - 1)
  result.reserveCapacity( chunksize )

  for i in stride( from: 0, to: data.count, by: chunksize ) {
    if data[ i..<(i+chunksize) ].reduce(0, { $0 + ($1 == 0 ? 1 : 0) }) % 2 == 0 {
      result.append( 1 )
    } else {
      result.append( 0 )
    }
  }

  return result
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
