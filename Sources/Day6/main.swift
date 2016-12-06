import Foundation
import Lib

typealias Position = [Character: Int]

let data = Input().reduce( Array<Position>(repeating: [:], count: 8 ) ) { (message: [Position], line : String) in
  return line.characters.enumerated().reduce( message ) { (message, i) in
    var message = message
    message[ i.0 ][ i.1 ] = ( message[ i.0 ][ i.1 ] ?? 0 ) + 1 
    return message
  }
}

let part1 = data.flatMap { position in
  position.sorted { $0.value > $1.value }.map { $0.0 }.prefix( 1 )
}

print( "PART 1" )
print( part1 )

let part2 = data.flatMap { position in
  position.sorted { $0.value < $1.value }.map { $0.0 }.prefix( 1 )
}

print( "PART 2" )
print( part2 )
