import Foundation
import FootlessParser
import Lib

let number = { Int($0)! } <^> oneOrMore( digit )
let range = tuple <^> number <*> (char("-") *> number)

let blacklist: [(Int,Int)] = {
  // Parse the list
  // Sort it by the low value in the tuple
  // Reduce it to eliminate overlaps.
  let list = Input().map { (line: String) -> (Int, Int) in try! parse( range, line ) }.sorted { $0.0 < $1.0 }.reduce( ([(Int,Int)](), (0,0)) ) {
    if $0.1.1 + 1 >= $1.0 {
      return ($0.0, ($0.1.0, max($0.1.1, $1.1)))
    } else {
      return ( $0.0 + [ $0.1 ], $1 )
    }
  }
  return list.0 + [ list.1 ]
}()

let lowest = blacklist.reduce(0) { $0 < $1.0 || $0 > $1.1 ? $0 : $1.1 + 1 }
print( "PART 1: \(lowest)" )

let part2 = blacklist.reduce( Int(UInt32.max) ) { $0 - ($1.1 - $1.0 + 1) } + 1
print( "PART 2: \(part2)" )
