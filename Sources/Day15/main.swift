import Foundation
import FootlessParser
import Lib

typealias F = (Int) -> Int

// Return a function that describes where the disc will be at time start + t,
// where t == time it takes to fall to disc's position.
// 
// We simply have to find the start time where all the discs will be at
// position 0.

let parser: Parser<Character,F> = {
  let number = { Int($0)! } <^> oneOrMore( digit )
  return curry({ num, pos, loc in return { t in ( t + num + loc ) % pos } }) <^> 
    ( string( "Disc #" ) *> number ) <*>
    ( string( " has " ) *> number ) <*>
    ( string( " positions; at time=0, it is at position " ) *> number) <* char(".")
}()

var discs = Input().map { try! parse( parser, $0 ) }
let part1 = (0...Int.max).lazy.filter { i in discs.first { $0(i) != 0 } == nil }.prefix(1)
print( part1.first! )

discs.append( { t in ( t + 0 + 7 ) % 11 } )
let part2 = (0...Int.max).lazy.filter { i in discs.first { $0(i) != 0 } == nil }.prefix(1)
print( part2.first! )
