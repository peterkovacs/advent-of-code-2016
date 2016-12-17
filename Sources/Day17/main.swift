import Foundation
import Lib

enum Direction: Int {
  case up = 0
  case down
  case left
  case right
}

struct Path: ByteRepresentable {
  public let path: [Direction]
  static let bytes: [UInt8] = [ 0x55, 0x44, 0x4c, 0x52 ]

  var byteRepresentation: [UInt8] {
    return path.map { Path.bytes[ $0.rawValue ] }
  }

  var position: (Int, Int) { 
    var result = (1, 1)
    
    for i in path {
      switch i {
      case .up:
        result = ( result.0, result.1 - 1 )
      case .down:
        result = ( result.0, result.1 + 1 )
      case .left:
        result = ( result.0 - 1, result.1 )
      case .right:
        result = ( result.0 + 1, result.1 )
      }
    }

    return result
  }

  var isSolved: Bool {
    let position = self.position
    return position.0 == 4 && position.1 == 4
  }

  func move( _ to: Direction ) -> Path? {
    var path = self.path
    path.append( to )

    let result = Path( path: path )
    switch result.position {
    case (0,_), (_,0), (5,_), (_,5):
      return nil
    default:
      return result
    }
  }
}

extension Direction: CustomStringConvertible {
  var description: String {
    switch self {
      case .up: return "U"
      case .down: return "D"
      case .left: return "L"
      case .right: return "R"
    }
  }
}

extension Path: CustomStringConvertible {
  var description: String {
    return path.map{ $0.description }.joined()
  }
}

struct Solver {
  let hash: MD5<Path>

  public init( passcode: String ) {
    hash = MD5<Path>( bytes: passcode, rounds: 0 )
  }

  func moves( from: Path ) -> [Path] {
    let bytes = hash.hash( of: from )

    var result = [Path]()
    if let up = from.move( .up ), ((bytes[0] & 0xf0) >> 4) > 10 {
      result.append( up )
    }
    if let down = from.move( .down ), (bytes[0] & 0xf) > 10 {
      result.append( down )
    }
    if let left = from.move( .left ), ((bytes[1] & 0xf0) >> 4) > 10 {
      result.append( left )
    }
    if let right = from.move( .right ), (bytes[1] & 0xf) > 10 {
      result.append( right )
    }

    return result
  }

  func longest( from: Path ) -> Path {
    var queue: [Path] = [from]
    var longest: Path = from

    while !queue.isEmpty {
      let move = queue.removeFirst()
      let validMoves = moves( from: move )

      for next in validMoves {
        if next.isSolved { 
          if longest.path.count < next.path.count {
            longest = next
          }
        } else {
          queue.append( next )
        }
      }
    }

    return longest
  }

  func shortest( from: Path ) -> Path {
    var queue: [Path] = [from]

    while !queue.isEmpty {
      let move = queue.removeFirst()
      let validMoves = moves( from: move )

      for next in validMoves {
        if next.isSolved { 
          return next
        }

        queue.append( next )
      }
    }

    return from
  }
}

let solver = Solver(passcode: CommandLine.arguments[1])
print( solver.shortest( from: Path(path: []) ) )
print( solver.longest( from: Path(path: []) ).path.count )
