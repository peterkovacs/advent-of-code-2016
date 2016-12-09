import Foundation
import FootlessParser

if let line = readLine(strippingNewline: true) {
  print( try parse( zeroOrMore( decompress() ), line ).reduce( 0, + ) )
  print( try parse( zeroOrMore( recursiveDecompress() ), line ).reduce( 0, + ) )
}
