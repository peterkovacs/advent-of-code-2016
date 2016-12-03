import Foundation
import FootlessParser
import Lib

typealias Triangle = (Int,Int,Int)
let number = { Int($0)! } <^> oneOrMore( digit )
let parser = tuple <^> ((oneOrMore(whitespace) *> number) <* oneOrMore(whitespace)) <*> (number <* oneOrMore(whitespace)) <*> number

func isTriangle( tuple: Triangle ) -> Bool {
  return (tuple.0 + tuple.1) > tuple.2 &&
  (tuple.1 + tuple.2) > tuple.0 &&
  (tuple.0 + tuple.2) > tuple.1 
}

let tuples = Input().map { try! parse( parser, $0 ) }
let possible = tuples.filter(isTriangle)

print( possible.count )

let stridable = stride( from: 0, to: tuples.count, by: 3 )
let rotated = stridable.flatMap { (i:Int) -> [Triangle] in
  let collection = tuples[ i...(i+2) ]
  return [( collection[i].0, collection[i+1].0, collection[i+2].0 ),
          ( collection[i].1, collection[i+1].1, collection[i+2].1 ),
          ( collection[i].2, collection[i+1].2, collection[i+2].2 )]
}
let rotatedPossible = rotated.filter(isTriangle)
print( rotatedPossible.count )
