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

// From the wikipedia page on Dragon Curves:
// This pattern also gives a method for determining the direction of the nth
// turn in the turn sequence of a Heighway dragon iteration. First, express n
// in the form k2m where k is an odd number. The direction of the nth turn is
// determined by k mod 4 i.e. the remainder left when k is divided by 4. If k
// mod 4 is 1 then the nth turn is R; if k mod 4 is 3 then the nth turn is L.

// There is a simple one line non-recursive method of implementing the above k
// mod 4 method of finding the turn direction in code. Treating turn n as a
// binary number, calculate the following boolean value:

// bool turn = (((n & −n) << 1) & n) != 0;

// Therefore we can easily calculate the nth bit using the `subscript` function
// below.

// Strangely, this method is actually slower (~ 400 msec) than directly
// generating the data.

struct Dragon {
  let count: Int
  let data: [[UInt8]]

  init( data: [UInt8] ) {
    self.count = data.count
    self.data = [ data, data.reversed().map { ($0 ^ 1) as UInt8 } ]
  }

  func joiner( at: Int ) -> UInt8 {
    let i = at + 1
    return ((( i & -i ) << 1 ) & i) != 0 ? 1 as UInt8 : 0 as UInt8
  }

  func checksum( size: Int ) -> [UInt8] {
    var result = [UInt8]()

    // Calculate largest power of 2 that divides data.count.
    let chunksize = size & ~(size - 1)
    result.reserveCapacity( chunksize )

    // OPTIMIZE: we know how many 1s are in data[0]+data[1] (its exactly data.count)
    // So we could calculate the number of these groups that appear in the
    // chunk + add in any joiners present.  Then we can increment by at least count + 1 each time.
    for i in stride( from: 0, to: size, by: chunksize ) {
      if (i..<(i+chunksize)).reduce(0, { $0 + (self[$1] == 0 ? 1 : 0) }) & 1 == 0 {
        result.append( 1 )
      } else {
        result.append( 0 )
      }
    }

    return result
  }

  subscript( i: Int ) -> UInt8 {
    let index = i % ( count+1 )
    let chunk = ( i / ( count+1 ) )

    if index < count {
      let which = chunk & 1
      return data[which][index]
    } else {
      return joiner( at: chunk )
    }
  }
}

let zero = { _ in 0 as UInt8 } <^> char("0")
let one = { _ in 1 as UInt8 } <^> char("1")
let parser = oneOrMore( zero <|> one )
var data = try parse( parser, CommandLine.arguments[1] )
let length = Int( CommandLine.arguments[2] )!

let dragon = Dragon( data: data )
print( dragon.checksum( size: length ).map{ "\($0)" }.joined() )
