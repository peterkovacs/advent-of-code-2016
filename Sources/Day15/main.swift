import Foundation
import FootlessParser
import Lib

let parser: Parser<Character,(width:Int, position:Int)> = {
  let number = { Int($0)! } <^> oneOrMore( digit )
  return curry({ _, pos, loc in (width: pos, position: loc) }) <^> 
    ( string( "Disc #" ) *> number ) <*>
    ( string( " has " ) *> number ) <*>
    ( string( " positions; at time=0, it is at position " ) *> number) <* char(".")
}()

// Note that this only works if the set of disc widths are co-prime.  That is,
// the only common divisor is 1.
func sieve( _ discs: [(width:Int, position:Int)] ) -> Int {
  var base = 0
  var increment = 1

  for (num,disc) in discs.enumerated() {
    let position = ( 2 * disc.width - (disc.position + num + 1) ) % disc.width
    var i = base
    while true {

      if i % disc.width == position {
        base = i
        // Once we know what offset of time solves this disc, then any further
        // solution must be a multiple of the width of the disc.
        increment *= disc.width
        break
      }

      i += increment
    }
  }

  return base
}

var discs = STDIN.map { try! parse( parser, $0 ) }
print( "PART 1: \(sieve( discs ))" )

discs.append( (11, 0) )
print( "PART 2: \(sieve( discs ))" )
