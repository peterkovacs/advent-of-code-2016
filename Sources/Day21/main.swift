import Foundation
import FootlessParser
import Lib

struct Password: CustomStringConvertible {
  var password: [Character]
  
  func swapPosition( _ a: Int, _ b: Int ) -> Password {
    var result = self
    swap(&result.password[a], &result.password[b])
    return result
  }

  func swapLetter( _ a: Character, _ b: Character ) -> Password {
    return Password( password: password.map { switch $0 {
        case a: return b
        case b: return a
        default: return $0
      }
    } )
  }

  func rotateLeft( _ num: Int ) -> Password { 
    let rotate = num % password.count

    if rotate > 0 {
      var result = [Character]()
      result.append( contentsOf: password.dropFirst( rotate ) )
      result.append( contentsOf: password.prefix( rotate ) )
      return Password( password: result )
    } else { 
      return self
    }
  }

  func rotateRight( _ num: Int ) -> Password { 
    let rotate = num % password.count

    if rotate > 0 {
      var result = [Character]()
      result.append( contentsOf: password.dropFirst( password.count - rotate ) )
      result.append( contentsOf: password.prefix( password.count - rotate ) )
      return Password( password: result )
    } else { 
      return self
    }
  }

  func rotateLetter( _ letter: Character ) -> Password {
    guard let index = password.index( of: letter ) else { fatalError( "\(letter) not found" ) }

    if index > 3 {
      return rotateRight( index + 2 )
    } else {
      return rotateRight( index + 1 )
    }
  }

  func rotateLetter( reverse letter: Character ) -> Password {
    guard let index = password.index( of: letter ) else { fatalError( "\(letter) not found" ) }

    if index == 0 {
      return rotateLeft( 1 )
    } else if index % 2 == 0 {
      return rotateLeft( ( (index + password.count) / 2 + 1 ) % password.count )
    } else {
      return rotateLeft( index / 2 + 1 )
    }
  }

  func reverse( _ start: Int, _ end: Int ) -> Password {
    precondition( start >= password.startIndex )
    precondition( end < password.endIndex )

    var result = [Character]()

    result.append( contentsOf: password.prefix( start ) )
    result.append( contentsOf: password[ start...end ].reversed() )
    result.append( contentsOf: password.dropFirst( end + 1 ) )

    return Password( password: result )
  }

  func move( _ from: Int, _ to: Int ) -> Password {
    var result = password
    let l = result.remove( at: from )
    result.insert( l, at: to )
    return Password( password: result )
  }

  var description: String {
    return password.reduce( "" ) { $0 + String($1) }
  }
}

typealias Transform = (Password) -> Password
typealias Transforms = (forward: Transform, reverse: Transform)
let parser: Parser<Character,Transforms> = {
  let index = { Int($0)! } <^> oneOrMore( digit )
  let letter = oneOf( "abcdefgh".characters )

  let swapPosition = curry({ (a:Int, b:Int) -> Transforms in
    let c: Transform = { Password.swapPosition( $0 )( a, b ) }
    return ( forward: c, reverse: c )
  }) <^> (string( "swap position ") *> index ) <*> (string( " with position ") *> index)

  let swapLetter = curry({ (a:Character, b:Character) -> Transforms in 
    let c: Transform = { Password.swapLetter( $0 )( a, b ) }
    return ( forward: c, reverse: c )
  }) <^> (string( "swap letter ") *> letter ) <*> (string( " with letter ") *> letter)

  let rotateLeft = { (a:Int) -> Transforms in 
    return ( forward: { Password.rotateLeft( $0 )( a ) }, 
             reverse: { Password.rotateRight( $0 )( a ) } )
  } <^> (string( "rotate left " ) *> index ) <* string( " step" ) <* optional(char("s"))

  let rotateRight = { (a:Int) -> Transforms in 
    return ( forward: { Password.rotateRight( $0 )( a ) }, 
             reverse: { Password.rotateLeft( $0 )( a ) } )
  } <^> (string( "rotate right " ) *> index ) <* string( " step" ) <* optional(char("s"))

  let rotateLetter = { (a:Character) -> Transforms in 
    return ( forward: { Password.rotateLetter(_:)( $0 )( a ) }, 
             reverse: { Password.rotateLetter(reverse:)( $0 )( a ) } )
  } <^> (string( "rotate based on position of letter " ) *> letter )

  let reverse = curry({ (a:Int, b:Int) -> Transforms in 
    let c: Transform = { Password.reverse( $0 )( min(a,b), max(a,b) ) }
    return ( forward: c, reverse: c )
  }) <^> (string( "reverse positions " ) *> index ) <*> ( string( " through " ) *> index )

  let move = curry({ (a:Int, b:Int) -> Transforms in 
    return ( forward: { Password.move( $0 )( a, b ) },
             reverse: { Password.move( $0 )( b, a ) } )
  }) <^> (string( "move position " ) *> index ) <*> ( string( " to position " ) *> index )

  return swapPosition <|> swapLetter <|> rotateLeft <|> rotateRight <|> rotateLetter <|> reverse <|> move
}()

let commands = STDIN.map { try! parse( parser, $0 )  }

let part1 = commands.reduce( Password( password: Array("abcdefgh".characters) ) ) { $1.forward( $0 ) }
print( "PART 1 \(part1)" )

let part2 = commands.reversed().reduce( Password( password: Array( "fbgdceah".characters ) ) ) { $1.reverse( $0 ) }
print( "PART 2 \(part2)" )
