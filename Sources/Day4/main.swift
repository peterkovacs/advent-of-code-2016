// Day 4
// Expects input on STDIN.

import Foundation
import FootlessParser
import Lib

struct Data {
  let words: [String]
  let sectorId: Int
  let checksum: String
}

let number = { Int($0)! } <^> oneOrMore( digit )
let checksum = { String($0)! } <^> ( char("[") *> oneOrMore( alphanumeric ) ) <* char("]")
let word = { String($0)! } <^> oneOrMore( alphanumeric )
let parser = curry({ Data( words: $0, sectorId: $1, checksum: $2 ) }) <^> ( oneOrMore( word <* char("-") ) ) <*> number <*> checksum
let data = Input().map { try! parse( parser, $0 ) }

extension Data {
  // A room is real (not a decoy) if the checksum is the five most common
  // letters in the encrypted name, in order, with ties broken by
  // alphabetization.
  func isValid() -> Bool {
    return String(mostCommonLetters(count:5)) == checksum
  }

  func letterCounts() -> [Character:Int] {
    return words.reduce( [:] ) { (d,word) -> [Character:Int] in
      return word.characters.reduce( d ) { (dict,letter) -> [Character:Int] in
        var dict = dict
        dict[ letter ] = ( dict[ letter ] ?? 0 ) + 1
        return dict
      }
    }
  }

  func mostCommonLetters( count: Int ) -> [Character] {
    return letterCounts().sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }.prefix( upTo: count ).map{ $0.key }
  }
}

print( "PART 1" )
print( data.filter { $0.isValid() }.map { $0.sectorId }.reduce( 0, + ) )

// This probably doesn't work for non-ascii.
func + (lhs: Character, rhs: Int) -> Character {
  struct Const {
    static let a = Int("a".unicodeScalars.first!.value)
  }
  guard let value = String(lhs).unicodeScalars.first?.value else { return lhs }

  let result = Const.a + ((( Int(value) - Const.a ) + rhs ) % 26)
  guard let scalar = UnicodeScalar( result ) else { return lhs }

  return Character(scalar)
}


extension Data {
  func decrypted() -> Data {
    let words = self.words.map { word in
      return String( word.characters.map { $0 + self.sectorId } )
    }

    return Data( words: words, sectorId: sectorId, checksum: checksum )
  }
}

print( "PART 2" )
print( data.map { $0.decrypted() }.filter { $0.words == [ "northpole", "object", "storage" ] } )
