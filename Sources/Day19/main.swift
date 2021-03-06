import Foundation

// Part 1 is the Josepheus problem.

// Part 1, represent the input as 2^a+l
// 3005290 = 2^(21) + 908138
// The answer is then 2l + 1

let input = Int( CommandLine.arguments[1] )!
let part1: Int? = stride( from: 63, through: 1, by: -1 ).first() { input / (1 << $0) == 1 }.map { (input % (1 << $0) ) * 2 + 1 }
print( "PART 1: \(part1!)" )

let part1a = ((input & ~(1 << Int(log2( Double(input) )))) << 1) + 1
print( "PART 1: \(part1a)" )

// 
// Part 2, each elf takes directly across.
//
// Similarly to Part 1, represent the input as 3^a + l
//
// If we're in the first half, then the numbers simply go up normally.
// If we're in the second half, we go up 2n + 1.

let part2: Int? = stride( from: 1, through: 63, by: 1 ).first() { input <= Int(pow(3.0, $0 + 1)) }.map { 
  let power = Int(pow( 3.0, $0 ))
  return input - power + max( input - 2 * power, 0 )
}

print( "PART 2: \(part2!)" )

let part2a = { () -> Int in
  let power = Int(pow( 3.0, Double(Int( log( Double(input) )/log(3.0) ) )))
  return input - power + max( input - 2 * power, 0 )
}()

print( "PART 2: \(part2a)" )
