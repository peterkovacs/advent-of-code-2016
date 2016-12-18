import Foundation
import FootlessParser

// 
// Expecting puzzle input on STDIN
// value for row[n][i] is row[n-1][i-1] ^ row[n-1][i+1]

let trap = { _ in 1 } <^> char("^")
let safe = { _ in 0 } <^> char(".")
let parser = oneOrMore( trap <|> safe )
var row = try! parse( parser, readLine( strippingNewline: true )! )
var next = [Int](repeating: 0, count: row.count)
var safeRooms = row.count - row.reduce( 0, +)

func next( row: [Int], in next: inout [Int] ) {
  next[0] = row[1]
  next[row.count-1] = row[row.count - 2]

  for i in 1..<(row.count - 1) {
    next[i] = row[i-1] ^ row[i+1]
  }
}

for _ in 1..<40 {
  next( row: row, in: &next )
  safeRooms = safeRooms + (next.count - next.reduce(0, +))
  row = next
}

print( "PART 1: \(safeRooms)" )

for _ in 40..<400000 {
  next( row: row, in: &next )
  safeRooms = safeRooms + (next.count - next.reduce(0, +))
  row = next
}

print( "PART 2: \(safeRooms)" )
