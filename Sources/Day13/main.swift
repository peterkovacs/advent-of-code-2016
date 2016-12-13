import Foundation
import Lib

typealias State = Set<Point>

struct Point: Hashable {
  let x: Int
  let y: Int

  public var isWall: Bool {
    // 1352 is puzzle input
    let result = 1352 + (x * x + 3 * x + 2 * x * y + y + y * y)
    return result.bits & 0x1 == 0x1
  }

  public var hashValue: Int {
    return x ^ y
  }

  static func == (l: Point, r: Point) -> Bool {
    return l.x == r.x && l.y == r.y
  }
}

func moves( from: Point ) -> [Point] {
  return [ (-1, 0), (1, 0), (0, 1), (0, -1) ].map { Point( x: from.x + $0.0, y: from.y + $0.1 ) } .filter { $0.x >= 0 && $0.y >= 0 }.filter { !$0.isWall } 
}

func solve( from: Point, max: Int? ) -> Int {
  var state = State()
  var queue: [(Int,Point)] = [(0,from)]

  state.insert( from )

  while !queue.isEmpty {
    let (num, move) = queue.removeFirst()
    let validMoves = moves( from: move )

    for move in validMoves {
      if max != nil && num >= max! { continue }

      if max == nil && move.x == 31 && move.y == 39 {
        return num + 1
      }

      guard !state.contains( move ) else { continue }

      state.insert( move )
      queue.append( (num+1, move) )
    }
  }

  return -(state.count)
}

print( solve( from: Point( x: 1, y: 1 ), max: nil ) )
print( solve( from: Point( x: 1, y: 1 ), max: 50 ) )
