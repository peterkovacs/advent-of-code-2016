import Foundation

// Part 1 is the Josepheus problem.

// Part 1, represent the input as 2^a+l
// 3005290 = 2^(21) + 908138
// The answer is then 2l + 1

extension Int {
  func divmod( _ by: Int ) -> (quotient: Int, remainder: Int) {
    return ( self / by, self % by )
  }
}

let input = Int( CommandLine.arguments[1] )!
let result: Int? = stride( from: 63, through: 1, by: -1 ).first() { input / (1 << $0) == 1 }.map { (input % (1 << $0) ) * 2 + 1 }
print( "PART 1: \(result!)" )

extension String {
  func withLeftPadding( padding: String = " ", size: Int ) -> String {
    let chrs = size - characters.count
    var result = String( repeating: padding, count: chrs )
    result.append( self )
    return result
  }
}


// 
// Part 2, each elf takes directly across.

var elves: [Int] = Array( 1...3005290 )
var i = 0

// O(n^2), i need to figure out a better way to do this.
while elves.count > 1 {
  let index = ( i + elves.count/2 ) % elves.count

  elves.removeSubrange( index...index )
  if index > i {
    i = ( i + 1 ) % elves.count
  } else {
    i = i % elves.count
  }
}

if let i = elves.first {
  print( "PART 2: \(String(n, radix: 2).withLeftPadding( size: 32 )) \(i)" )
}
