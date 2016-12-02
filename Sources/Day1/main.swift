import Foundation
import FootlessParser

enum Direction: Character {
  case left = "L"
  case right = "R"
}

struct Command {
  let direction: Direction
  let distance: Int
}

enum Cardinal {
  case north, south, east, west
}

struct Elf {
  let facing: Cardinal
  let x: Int
  let y: Int

  func turn( to: Direction ) -> (Int) -> Elf {
    switch facing {
    case .north:
      switch to {
      case .left: 
        return { Elf( facing: .west, x: self.x - $0, y: self.y ) }
      case .right:
        return { Elf( facing: .east, x: self.x + $0, y: self.y ) }
      }
    case .south: 
      switch to {
      case .left: 
        return { Elf( facing: .east, x: self.x + $0, y: self.y ) }
      case .right:
        return { Elf( facing: .west, x: self.x - $0, y: self.y ) }
      }
    case .east: 
      switch to {
      case .left: 
        return { Elf( facing: .north, x: self.x, y: self.y + $0 ) }
      case .right:
        return { Elf( facing: .south, x: self.x, y: self.y - $0 ) }
      }
    case .west: 
      switch to {
      case .left: 
        return { Elf( facing: .south, x: self.x, y: self.y - $0 ) }
      case .right:
        return { Elf( facing: .north, x: self.x, y: self.y + $0 ) }
      }
    }
  }

  func move( to: Command ) -> Elf {
    let result = turn( to: to.direction )( to.distance )
    return result
  }
}

let input = try! String( contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("input.txt") )

let directionParser = { Direction(rawValue: $0)! } <^> oneOf("LR".characters)
let distanceParser = { Int($0)! } <^> oneOrMore(digit)
let commandParser = curry( { Command( direction: $0, distance: $1 ) } ) <^> directionParser <*> distanceParser
let parser = oneOrMore( commandParser <* optional( oneOf( "," ) ) <* zeroOrMore( whitespacesOrNewline ) )

let result = try parse( parser, input )
let elf = result.reduce( Elf( facing: .north, x: 0, y: 0 ) ) { (elf: Elf, command: Command) in
  return elf.move( to: command )
}
print( elf )
print( abs(elf.x) + abs(elf.y) )

// Part 2.
// We walk along as if we were an elf, flipping bools in our array to true.
// If we come to a location that already has something on, then we return the elf.

struct Grid: CustomStringConvertible {
  var elf = Elf( facing: .north, x: 0, y: 0 )
  var coordinates: [Cardinal?] = Array( repeating: nil, count: 512 * 512 )

  mutating func move( to: Command ) -> Elf? {
    let applicator = elf.turn( to: to.direction )

    for i in 1...to.distance {
      elf = applicator( i )
      defer { 
        self[elf.x, elf.y] = elf.facing 
      }

      if self[ elf.x, elf.y ] != nil {
        return elf
      }
    }

    return nil
  }

  subscript( x: Int, y: Int ) -> Cardinal? {
    get {
      return coordinates[ ( y + 256 ) * 512 + ( x + 256 ) ]
    }
    set {
      coordinates[ ( y + 256 ) * 512 + ( x + 256 ) ] = newValue
    }
  }

  var description: String {
    var result = ""
    for y in stride( from: 210, through: -30, by: -1 ) {
      for x in stride( from: -10, to: 115, by: 1 ) {
        if x == 0 && y == 0 {
          result.append( "O" )
        } else if x == elf.x && y == elf.y {
          result.append( "E" )
        } else {
          switch self[x,y] {
          case .some(.north), .some(.south):
            result.append( "|" )
          case .some(.east), .some(.west):
            result.append( "-" )
          case .none:
            result.append( " " )
          }
        }
      }
      result.append( "\n" )
    }
    return result
  }
}

var grid = Grid()
for command in result {
  if let elf = grid.move(to: command) {
    print( grid )
    print( abs(elf.x) + abs(elf.y) )
    break
  }
}

