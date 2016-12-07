import Foundation
import Lib
import FootlessParser

struct ABBA: Sequence, IteratorProtocol {
  var data: [String.CharacterView]
  var element: Int
  var index: String.CharacterView.Index

  init( data: [String] ) {
    self.data = data.map { $0.characters }
    self.element = self.data.startIndex
    self.index = self.data[ element ].startIndex
  }

  mutating func next() -> String? {
    while element != data.endIndex {
      let a0 = index
      let b0 = data[element].index(a0, offsetBy: 1)
      let b1 = data[element].index(b0, offsetBy: 1)
      let a1 = data[element].index(b1, offsetBy: 1)

      guard a1 < data[element].endIndex else {
        element = element.advanced(by: 1)
        guard element < data.endIndex else { return nil }
        index = data[element].startIndex
        continue
      }

      index = b0

      if data[element][a0] == data[element][a1] && 
         data[element][b0] == data[element][b1] && 
         data[element][a0] != data[element][b0] {
        return String( data[element][a0...a1] )
      }
    }

    return nil
  }
}

struct ABA: Sequence, IteratorProtocol {
  var data: [String.CharacterView]
  var element: Int
  var index: String.CharacterView.Index

  init( data: [String] ) {
    self.data = data.map { $0.characters }
    self.element = self.data.startIndex
    self.index = self.data[ element ].startIndex
  }

  mutating func next() -> String? {
    while element != data.endIndex {
      let a0 = index
      let b0 = data[element].index(a0, offsetBy: 1)
      let a1 = data[element].index(b0, offsetBy: 1)

      guard a1 < data[element].endIndex else {
        element = element.advanced(by: 1)
        guard element < data.endIndex else { return nil }
        index = data[element].startIndex
        continue
      }

      index = b0

      if data[element][a0] == data[element][a1] && data[element][a0] != data[element][b0] {
        return String( data[element][a0...a1] )
      }
    }

    return nil
  }
}

extension String {
  func bab() -> String {
    let c = Array( characters )
    return String([c[1], c[0], c[1]])
  }
}

class IP {
  var supernet: [String] = []
  var hypernet: [String] = []

  func parser() -> Parser<Character,IP> {
    let supernet = { (o: String) in
      self.supernet.append( o )
    } <^> oneOrMore( alphanumeric )

    let hypernet = { (o: String) in
      self.hypernet.append( o )
    } <^> ( char( "[" ) *> oneOrMore( alphanumeric ) ) <* char( "]" )

    return zeroOrMore(hypernet <|> supernet) >>- { _ in pure(self) }
  }
}

extension IP {
  var isTLS: Bool {
    return Array(ABBA( data: supernet ).prefix(1)).count > 0 && Array(ABBA( data: hypernet ).prefix(1)).count == 0
  }

  var isSSL: Bool {
    return ABA( data: supernet ).reduce( false ) { result, aba in
      return result || hypernet.reduce( result ) { result, addr in
        return result || addr.contains( aba.bab() )
      }
    }
  }
}

let parsed = Input().map { try? parse( IP().parser(), $0 ) } 
let tls = parsed.filter { $0?.isTLS ?? false }
let ssl = parsed.filter { $0?.isSSL ?? false }

print( tls.count )
print( ssl.count )
