import Foundation
import FootlessParser
import Lib

struct Position {
  let x: Int
  let y: Int
}

struct Node {
  let position: Position
  let size: Int
  var used: Int
  var available: Int {
    return size - used
  }

  func canMove( to rhs: Node ) -> Bool {
    return used > 0 && used <= rhs.available
  }

  // We *could* move to `rhs`, if it were empty.
  func canPossiblyMove( to rhs: Node ) -> Bool {
    return used <= rhs.size
  }

  var neighbors: [Position] {
    return [
      Position(x: position.x - 1, y: position.y),
      Position(x: position.x + 1, y: position.y),
      Position(x: position.x, y: position.y - 1),
      Position(x: position.x, y: position.y + 1)
    ]
  }
}

let parser: Parser<Character,Node> = {
  let number = { Int($0)! } <^> oneOrMore(digit)
  let size = number <* char("T")
  let name = curry(Position.init) <^> (string("/dev/grid/node-x") *> number) <*> (string("-y") *> number)

  return curry(Node.init) <^> name <*> (oneOrMore(whitespace) *> size) <*> (oneOrMore(whitespace) *> size) <* ((oneOrMore(whitespace) *> size) <* oneOrMore(any()))
}()

let nodes = STDIN.map { try! parse( parser, $0 ) }

// PART 1
// Find the number of "viable pairs"
// - Node A is not empty (its Used is not zero).
// - Nodes A and B are not the same node.
// - The data on node A (its Used) would fit on node B (its Avail).
let part1 = nodes.lazyCombos( n: 2 ).filter { 
  $0[0].canMove( to: $0[1] ) || $0[1].canMove( to: $0[0] )
}.count
print( "PART 1: \(part1)" )

// PART 2
// Find the minimum number of moves to get the data from /dev/grid/node-x35-y0
// into /dev/grid/node-x0-y0

struct Grid {
  var position: Position
  var nodes: [[Node]] = [[Node]]()

  init( nodes input: [Node] ) {
    for node in input {
      if node.position.x >= nodes.count {
        nodes.append( [Node]() )
      }

      nodes[ node.position.x ].append( node )
    }

    position = Position( x: nodes.count - 1, y: 0 )
  }

  func neighbors( at node: Node ) -> [Node] {
    let neighbors = self[ node.position ].neighbors.filter { n in
      n.x >= 0 && n.x < nodes.count &&
      n.y >= 0 && n.y < nodes[ n.x ].count
    }

    return neighbors.map { self[$0] }
  }

  subscript( _ position: Position ) -> Node {
    get {
      return nodes[ position.x ][ position.y ]
    }
    set {
      nodes[ position.x ][ position.y ] = newValue
    }
  }

}

extension Grid: CustomStringConvertible {
  var description: String {
    var result = ""
    for y in 0..<nodes[0].count {
      for x in 0..<nodes.count {
        let p = Position( x: x, y: y )
        let node = self[ p ]

        if node.used == 0 {
          result += "_ "
        } else {
          let adjacent = neighbors( at: node )

          let possibilities = adjacent.filter { i in node.canPossiblyMove( to: i ) }

          if possibilities.count < adjacent.count {
            print( "\(p) adjacent: \(adjacent) possibilities: \(possibilities)" )
            result += "# "
          } else if adjacent.filter( { i in node.canMove( to: i ) }).count == 0 {
            result += ". "
          } else {
            result += "^ "
          }
        }
      }

      result += "\n"
    }

    return result
  }
}

var grid = Grid( nodes: nodes )
print( grid )
// Part 2 was solved by hand by examining the grid.

