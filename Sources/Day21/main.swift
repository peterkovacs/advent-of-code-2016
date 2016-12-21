import Foundation
import FootlessParser
import Lib

enum Command {
  case swapPosition(Int,Int)
  case swapLetter(Int,Int)
  case rotateLeft(Int)
  case rotateRight(Int)
  case rotateLetter(Int)
  case reverse(Int,Int)
  case move(Int,Int)
}

struct Password: CustomStringConvertible {
  var password: [Int]
  
  func execute( _ command: Command ) -> Password {
    switch( command ) {
    case let .swapPosition(x, y):
      return swapPosition( x, y )
    case let .swapLetter(x, y):
      return swapLetter( x, y )
    case let .rotateLeft(x):
      return rotateLeft(x)
    case let .rotateRight(x):
      return rotateRight(x)
    case let .rotateLetter(x):
      return rotateLetter(x)
    case let .reverse(x, y):
      return reverse( x, y )
    case let .move(x, y):
      return move(x, y)
    }
  }

  func reverse( _ command: Command ) -> Password {
    switch( command ) {
    case let .swapPosition(x, y):
      return swapPosition( y, x )
    case let .swapLetter(x, y):
      return swapLetter( y, x )
    case let .rotateLeft(x):
      return rotateRight(x)
    case let .rotateRight(x):
      return rotateLeft(x)
    case let .rotateLetter(x):
      return rotateLetter( reverse: x )
    case let .reverse( x, y ):
      return reverse( x, y )
    case let .move( x, y ):
      return move( y, x )
    }
  }

  func swapPosition( _ a: Int, _ b: Int ) -> Password {
    var result = self
    swap(&result.password[a], &result.password[b])
    return result
  }

  func swapLetter( _ a: Int, _ b: Int ) -> Password {
    return Password( password: password.reduce([]) { $0 + [ $1 == a ? b : $1 == b ? a : $1 ] } )
  }

  func rotateLeft( _ num: Int ) -> Password { 
    var result = [Int](repeating: 0, count: password.count)
    for i in 0..<password.count {
      result[i] = password[ (i + num) % password.count ]
    }
    return Password( password: result )
  }

  func rotateRight( _ num: Int ) -> Password { 
    var result = [Int](repeating: 0, count: password.count)
    for i in 0..<password.count {
      result[i] = password[ (2*password.count + (i - num)) % password.count ]
    }
    return Password( password: result )
  }

  func rotateLetter( _ letter: Int ) -> Password {
    guard let index = password.index( of: letter ) else { fatalError( "\(letter) not found" ) }

    if index > 3 {
      return rotateRight( index + 2 )
    } else {
      return rotateRight( index + 1 )
    }
  }

  func rotateLetter( reverse letter: Int ) -> Password {
    guard let index = password.index( of: letter ) else { fatalError( "\(letter) not found" ) }

    // We know where the letter ended up, so we just need to make a mapping of
    // position to a rotate.
    switch index {
    case 0:
      return rotateLeft(1)
    case 1:
      return rotateLeft(1)
    case 2:
      return rotateRight(2)
    case 3:
      return rotateLeft(2)
    case 4: 
      return rotateRight(1)
    case 5:
      return rotateLeft(3)
    case 6:
      return self
    case 7:
      return rotateLeft(4)
    default:
      fatalError( "Invalid Index \(index)" )
    }
  }

  func reverse( _ start: Int, _ end: Int ) -> Password {
    var result = [Int]()

    if start > 0 {
      result.append( contentsOf: password.prefix( start ) )
    }

    result.append( contentsOf: password[ start...end ].reversed() )

    if end < password.endIndex {
      result.append( contentsOf: password.dropFirst( end + 1 ) )
    }

    return Password( password: result )
  }

  func move( _ from: Int, _ to: Int ) -> Password {
    var result = password
    let l = result.remove( at: from )
    result.insert( l, at: to )
    return Password( password: result )
  }

  var description: String {
    let scalars = password.map { String(Character(UnicodeScalar( $0 + (0x60 as Int) )!) ) }

    return scalars.joined()
  }
}

let parser: Parser<Character,Command> = {
  let index = { Int($0)! } <^> oneOrMore( digit )
  let letter = { Int(UnicodeScalar( "\($0)".unicodeScalars.first! ).value - 0x60) } <^> oneOf( "abcdefgh".characters )
  let swapPosition = curry({ Command.swapPosition( $0, $1 ) }) <^> (string( "swap position ") *> index ) <*> (string( " with position ") *> index)
  let swapLetter = curry({ Command.swapLetter( $0, $1 ) }) <^> (string( "swap letter ") *> letter ) <*> (string( " with letter ") *> letter)
  let rotateLeft = { Command.rotateLeft( $0 ) } <^> (string( "rotate left " ) *> index ) <* string( " step" ) <* optional(char("s"))
  let rotateRight = { Command.rotateRight( $0 ) } <^> (string( "rotate right " ) *> index ) <* string( " step" ) <* optional(char("s"))
  let rotateLetter = { Command.rotateLetter( $0 ) } <^> (string( "rotate based on position of letter " ) *> letter )
  let reverse = curry({ Command.reverse( min($0,$1), max($0,$1) ) }) <^> (string( "reverse positions " ) *> index ) <*> ( string( " through " ) *> index )
  let move = curry({ Command.move( $0, $1 ) }) <^> (string( "move position " ) *> index ) <*> ( string( " to position " ) *> index )
  return swapPosition <|> swapLetter <|> rotateLeft <|> rotateRight <|> rotateLetter <|> reverse <|> move
}()

let commands = Input().map { try! parse( parser, $0 )  }

let part1 = commands.reduce( Password( password: [ 1, 2, 3, 4, 5, 6, 7, 8 ] ) ) { $0.execute( $1 ) }
print( "PART 1 \(part1)" )

let part2 = commands.reversed().reduce( Password( password: [ 6, 2, 7, 4, 3, 5, 1, 8 ] ) ) { $0.reverse( $1 ) }
print( "PART 2 \(part2)" )
