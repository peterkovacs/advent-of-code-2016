import Foundation
import FootlessParser

if let line = readLine(strippingNewline: true) {
  print( try parse( adding( decompress(), to: 0 ), line ) )
  print( try parse( adding( recursiveDecompress(), to: 0 ), line ) )
}
