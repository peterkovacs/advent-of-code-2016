import Foundation
import FootlessParser
import Lib

struct Point: Hashable {
  let x: Int
  let y: Int

  var hashValue: Int {
    return x << 16 + y
  }

  static func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
  static func !=(lhs: Point, rhs: Point) -> Bool {
    return !(lhs == rhs)
  }

  func distance( to destination: Point ) -> Int {
    return abs(destination.x - x) + abs(destination.y - y)
  }
}

enum Node: CustomStringConvertible {
  case wall
  case open
  case location(Int)

  var description: String {
    switch self {
    case .wall:
      return "█"
    case .open:
      return " "
    case .location(let x):
      return "\(x)"
    }
  }
}

class Grid: CustomStringConvertible {
  var size: Int = 0
  var nodes: [Node] = []

  subscript( _ x: Int, _ y: Int ) -> Node {
    get {
      return nodes[ y * size + x ]
    } 
    set {
      nodes[ y * size + x ] = newValue
    }
  }

  subscript( _ point: Point ) -> Node {
    get {
      return self[ point.x, point.y ]
    }
    set {
      self[ point.x, point.y ] = newValue
    }
  }

  lazy var parser: Parser<Character,[Node]> = {
    let location = { Node.location(Int($0)!) } <^> oneOrMore( digit )
    let wall = { _ in Node.wall } <^> char( "#" )
    let open = { _ in Node.open } <^> char( "." )
    return oneOrMore( wall <|> open <|> location )
  }()

  func load() {
    for line in STDIN {
      let row: [Node] = try! parse( parser, line )
      size = row.count
      nodes.append(contentsOf: row)
    }
  }

  func isNeighbor( _ point: Point ) -> Bool {
    switch self[ point ] {
    case .open, .location(_):
      return true
    case .wall:
      return false
    }
  }

  func neighbors( of: Point ) -> [Point] {
    return [ 
      Point( x: of.x - 1, y: of.y ),
      Point( x: of.x + 1, y: of.y ),
      Point( x: of.x, y: of.y - 1 ),
      Point( x: of.x, y: of.y + 1 ),
    ].filter { $0.x >= 0 && $0.x < size && $0.y >= 0 && $0.y < rows && isNeighbor( $0 ) }
  }

  func fillInDeadEnds( at point: Point ) {
    if case .open = self[ point ] {
      let adjacent = neighbors( of: point )

      if adjacent.count < 2 {
        self[ point ] = .wall
        adjacent.forEach( fillInDeadEnds )
      }
    }
  }

  func fillInDeadEnds() {
    for y in 0..<rows {
      for x in 0..<size {
        fillInDeadEnds( at: Point(x: x, y: y ) )
      }
    }
  }

  var rows: Int {
    return nodes.count / size
  }

  func location(of: Int) -> Point {
    for y in 0..<rows {
      for x in 0..<size {
        if case .location(of) = self[x,y] {
          return Point(x:x,y:y)
        }
      }
    }

    fatalError()
  }

  var description: String {
    var result = ""

    for y in 0..<rows {
      for x in 0..<size {
        result.append( self[x, y].description )
      }
      result.append( "\n" )
    }

    return result
  }

  func steps(start: Point, goal: Point) -> Int? {
    // set of nodes already evaluated
    var visited = Set<Point>()

    // discovered nodes still to be evaluated
    var queue = [ start ]

    // For each node, which node it can most efficiently be reached from.
    // If a node can be reached from many nodes, path will eventually contain the
    // most efficient previous step.
    var path = [Point:Point]()

    // For each node, the cost of getting from the start node to that node.
    var cost = [Point:Int]()

    cost[start] = 0

    // For each node, the total cost of getting from the start node to the goal
    // by passing by that node. That value is partly known, partly heuristic.
    var heuristicCost = [Point:Int]()

    // For the first node, that value is completely heuristic, i.e. the
    // manhattan distance.
    heuristicCost[start] = start.distance(to:goal)
    
    while !queue.isEmpty {
      // OPTIMIZE: Use a Priority Heap instead.
      queue.sort { (heuristicCost[$0] ?? Int.max) < (heuristicCost[$1] ?? Int.max) }

      let current = queue.removeFirst()
      if current == goal {
        var count = 1
        var current = path[current]!
        while current != start {
          count += 1
          current = path[current]!
        }
        return count
      }

      visited.insert( current )

      for neighbor in neighbors( of: current ) {
        if visited.contains( neighbor ) {
          continue
        }

        let score = cost[current]! + 1
        if !queue.contains( neighbor ) {
          queue.append( neighbor )
        } else if score >= cost[neighbor] ?? Int.max {
          // This is not the better path.
          continue 
        }

        // This path is the best until now, record it
        path[neighbor] = current
        cost[neighbor] = score
        heuristicCost[neighbor] = score + neighbor.distance( to:goal )

      }

    }

    return nil
  }
}

let grid = Grid()
grid.load()
grid.fillInDeadEnds()

var steps = [Point:Int]()

// Find the cost for each pair of nodes.
for pair in (0...7).combos(n: 2) {
  steps[ Point( x: pair[0], y: pair[1] ) ] = grid.steps( start: grid.location(of: pair[0]), goal: grid.location(of: pair[1]) )
}

let part1: Int = {
  var result = Int.max
  // TSP, but since there are only 7! combinations we can brute force
  for permutation in Permutations(1...7) {
    var candidate = 0
    var start = 0

    for end in permutation {
      candidate += steps[ Point( x: min(start,end), y: max(start,end) ) ]!
      start = end
    }
    
    result = min( candidate, result )
  }
  return result
}()

print( "PART 1: \(part1)" )

let part2: Int = {
  var result = Int.max
  // TSP, but since there are only 7! combinations we can brute force
  for permutation in Permutations(1...7) {
    var candidate = 0
    var start = 0

    // Always visit node 0 at end.
    var permutation = permutation
    permutation.append( 0 )

    for end in permutation {
      candidate += steps[ Point( x: min(start,end), y: max(start,end) ) ]!
      start = end
    }
    
    result = min( candidate, result )
  }
  return result
}()

print( "PART 2: \(part2)" )
