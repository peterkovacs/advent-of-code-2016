//
// Expects input on stdin
// Day2 1 < input.txt for part one
// Day2 2 < input.txt for part two

import Foundation
import FootlessParser

struct Input: Sequence, IteratorProtocol {
  typealias Element = String
  mutating func next() -> String? {
    return readLine( strippingNewline: true )
  }
}

enum Direction: Character {
  case u = "U"
  case d = "D"
  case l = "L"
  case r = "R"
}

struct Key {
  let number: Int

  func next(in direction: Direction) -> Key {
    switch( direction ) {
    case .r:
      if number % 3 != 0 {
        return Key( number: number + 1 )
      }
    case .u:
      if number > 3 {
        return Key( number: number - 3 )
      }
    case .d:
      if number < 7 {
        return Key( number: number + 3 )
      }
    case .l:
      if number % 3 != 1 {
        return Key( number: number - 1 )
      }
    }
    return self
  }
}

let direction = { Direction(rawValue: $0)! } <^> oneOf("UDLR".characters)
let parser = zeroOrMore( direction )

if CommandLine.argc == 1 || CommandLine.arguments[1] == "1" {
  var previousKey = Key(number:5)

  let result = Input().map { (line: String) -> Key in
    previousKey = try! parse( parser, line ).reduce( previousKey ) { (key, direction) in
      return key.next(in: direction)
    }
    return previousKey
  }

  print( "PART 1" )
  print( result )
}

// Part 2
// Keypad actually looks like:
//     1
//   2 3 4
// 5 6 7 8 9
//   A B C
//     D
  

struct ComplexKey {
  let number: Int

  func next(in direction: Direction) -> ComplexKey {
    switch( direction ) {
    case .r:
      if ![ 1, 4, 9, 12, 13 ].contains( number ) {
        return ComplexKey( number: number + 1 )
      }
    case .l:
      if ![ 1, 2, 5, 10, 13 ].contains( number ) {
        return ComplexKey( number: number - 1 )
      }
    case .u:
      if [ 3, 13 ].contains( number ) {
        return ComplexKey( number: number - 2 )
      } else if ![ 1, 2, 4, 5, 9 ].contains( number ) {
        return ComplexKey( number: number - 4 )
      }
    case .d:
      if [ 1, 11 ].contains( number ) {
        return ComplexKey( number: number + 2 )
      } else if ![ 5, 9, 10, 12, 13 ].contains( number ) {
        return ComplexKey( number: number + 4 )
      }
    }
    return self
  }
}

if CommandLine.arguments[1] == "2" {
  var previousKey = ComplexKey(number:5)
  let result = Input().map { (line: String) -> ComplexKey in
    previousKey = try! parse( parser, line ).reduce( previousKey ) { (key, direction) in
      return key.next(in: direction)
    }
    return previousKey
  }
  print( "PART 2" )
  print( result )
}
