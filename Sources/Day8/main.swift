import Foundation
import FootlessParser
import Lib

enum Command {
  case rect( Int, Int )
  case rotateRow( Int, Int )
  case rotateCol( Int, Int )
}

struct Screen: CustomStringConvertible {
  // The screen is 50 pixels wide and 6 pixels tall, all of which start off
  // We will use the least significant 6 bits to represent the pixels on each
  // col. The most significant bit is the top of the rectangle.
  var pixels: [Int] = [Int](repeating:0, count: 50)

  static let RECT = [ 0b0, 0b100000, 0b110000, 0b111000, 0b111100, 0b111110, 0b111111 ]
  static let ROWS = [ 0b100000, 0b010000, 0b001000, 0b000100, 0b000010, 0b000001 ]

  // rect AxB turns on all of the pixels in a rectangle at the top-left of the
  // screen which is A wide and B tall.
  mutating func rect( width a: Int, height b: Int ) {
    for x in 0..<a {
      pixels[x] = pixels[x] | Screen.RECT[b]
    }
  }

  // rotate row y=A by B shifts all of the pixels in row A (0 is the top row)
  // right by B pixels. Pixels that would fall off the right end appear at the
  // left end of the row.
  mutating func rotate( row: Int, by: Int ) {
    let copy = pixels
    for x in 0..<pixels.count {
      let col = ( pixels.count + ( x - by ) ) % pixels.count
      pixels[x] = (copy[x] & ~Screen.ROWS[row]) | (copy[col] & Screen.ROWS[row])
    }
  }

  // rotate column x=A by B shifts all of the pixels in column A (0 is the left
  // column) down by B pixels. Pixels that would fall off the bottom appear at
  // the top of the column
  mutating func rotate( column: Int, by: Int ) {
    pixels[column] = ( pixels[column] >> by ) | ((pixels[column] & ((1 << by) - 1)) << (Screen.ROWS.count - by))
  }

  var on: Int {
    return pixels.map { $0.bits } .reduce( 0, + ) 
  }

  var description: String {
    var result = ""
    result.reserveCapacity( 51 * 6 * 3 )

    for y in 0..<Screen.ROWS.count {
      for x in 0..<pixels.count {
        if ( pixels[x] & Screen.ROWS[y] ) > 0 {
          result.append( "█" )
        } else {
          result.append( " " )
        }
      }
      result.append( "\n" )
    }

    return result
  }

  mutating func execute( _ command: Command ) {
    switch command {
    case .rect( let x, let y ):
      rect( width: x, height: y )
    case .rotateRow( let x, let y ):
      rotate( row: x, by: y )
    case .rotateCol( let x, let y ):
      rotate( column: x, by: y )
    }
  }
}

let number = { Int($0)! } <^> oneOrMore( digit )
let rect = curry({ Command.rect( $0, $1 ) }) <^> ( string( "rect " ) *> number ) <*> ( char("x") *> number )
let rotateRow = curry({ Command.rotateRow( $0, $1 ) }) <^> ( string( "rotate row y=" ) *> number ) <*> ( string(" by ") *> number )
let rotateCol = curry({ Command.rotateCol( $0, $1 ) }) <^> ( string( "rotate column x=" ) *> number ) <*> ( string(" by ") *> number )
let parser = rect <|> rotateRow <|> rotateCol
let result = STDIN.map { try! parse( parser, $0 ) }

var screen = Screen()
for command in result {
  screen.execute( command )
}
print( screen )
print( screen.on )
