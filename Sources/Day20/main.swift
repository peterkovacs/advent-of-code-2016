import Foundation
import FootlessParser
import Lib

let number = { Int($0)! } <^> oneOrMore( digit )
let range = tuple <^> number <*> (char("-") *> number)

let list = STDIN.map { (line: String) -> (Int, Int) in try! parse( range, line ) }.sorted { $0.0 < $1.0 }


typealias State = ((Int,Int)?,Array<(Int,Int)>.Iterator)
let test = sequence( state: ((0,0), list.makeIterator()) ) { (state: inout State) -> (Int,Int)? in
  while true {
    guard let prev = state.0 else { return nil }
    guard let next = state.1.next() else { defer { state.0 = nil }; return state.0 }

    if prev.1 + 1 >= next.0 {
      state.0 = ( prev.0, max( next.1, prev.1 ) )
    } else {
      defer { state.0 = next }
      return state.0
    }
  }
}


let blacklist = Array(test)

let lowest = blacklist.reduce(0) { $0 < $1.0 || $0 > $1.1 ? $0 : $1.1 + 1 }
print( "PART 1: \(lowest)" )

let available = blacklist.reduce( Int(UInt32.max) ) { $0 - ($1.1 - $1.0 + 1) } + 1
print( "PART 2: \(available)" )
