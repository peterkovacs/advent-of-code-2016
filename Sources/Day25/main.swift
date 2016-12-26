import Foundation
import FootlessParser
import Lib

typealias Register = Int

enum Value {
  case register(Register)
  case int(Int)

  static func ==(lhs: Value, rhs: Value) -> Bool {
    if case .register( let l ) = lhs, case .register( let r ) = rhs {
      return l == r
    } else if case .int( let l ) = lhs, case .int( let r ) = rhs {
      return l == r
    } else {
      return false
    }
  }
}

enum Instruction {
  case cpy(Value, Value)
  case inc(Value)
  case dec(Value)
  case jnz(Value, Value)
  case out(Register)
}

class CPU {
  public var code: [Instruction] = []
  public var pc: Int = 0
  public var registers: [Int] = [Int]( repeating: 0, count: 4 )
  public var transmit: [Int] = [Int]( repeating: 0, count: 32 )
  public var index: Int = 0

  func reset( a: Int, b: Int, c: Int, d: Int ) {
    registers = [ a, b, c, d ]
    transmit = [Int](repeating: 0, count: 100)
    index = transmit.startIndex
    pc = 0
  }

  lazy var parser: Parser<Character, Instruction> = {
    let number = { (num: String) -> Int in return Int(num)! } <^> ( extend <^> optional( string( "-" ), otherwise: "" ) <*> oneOrMore( digit ) )
    let register = { Int(UnicodeScalar("\($0)".unicodeScalars.first!).value - 0x61) } <^> oneOf( "abcd".characters )
    let value = ( { Value.register($0) } <^> register ) <|> ( { Value.int( $0 ) } <^> number )
    let cpy: Parser<Character,Instruction>  = { val in { reg in return Instruction.cpy( val, .register(reg) ) } } <^> ( string( "cpy " ) *> value ) <*> ( oneOrMore( whitespace ) *> register )
    let inc: Parser<Character,Instruction>  = { Instruction.inc( .register($0) ) } <^> ( string( "inc " ) *> register )
    let dec: Parser<Character,Instruction>  = { Instruction.dec( .register($0) ) } <^> ( string( "dec " ) *> register )
    let jnz: Parser<Character,Instruction> = { reg in { int in return Instruction.jnz( reg, int ) } } <^> ( string( "jnz " ) *> value ) <*> ( oneOrMore( whitespace ) *> value )
    let out: Parser<Character,Instruction> = { Instruction.out( $0 ) } <^> ( string( "out " ) *> register )

    return cpy <|> inc <|> dec <|> jnz <|> out
  }()

  func load( _ line: String ) throws {
    code.append( try parse( parser, line ) )
  }

  func optimize() -> Bool {
    if pc + 4 < code.endIndex {
      if case .inc(let a) = code[ pc ], case .register(let registera) = a,
         case .dec(let b) = code[ pc + 1], !(a == b), case .register(let registerb) = b,
         case .jnz(let jnz, let `where`) = code[ pc + 2 ], jnz == b,
           case .int(let val) = `where`, -2 == val,
         case .dec(let c) = code[ pc + 3 ], !(b == c), !(a == c), case .register(let registerc) = c,
         case .jnz(let jnz2, let where2) = code[pc + 4], jnz2 == c,
         case .int(let val2) = where2, -5 == val2 {
           registers[registera] = registers[registera] + registers[registerb] * registers[registerc]
           registers[registerb] = 0
           registers[registerc] = 0
           pc = pc.advanced(by: 5)
           return true
         }
    }
    return false
  }

  func execute() {
    while pc != code.endIndex {
      let instruction = code[ pc ]

      if optimize() {
        continue
      }

      switch instruction {
      case .cpy(let from, let to):
        cpy( from: from, to: to )
      case .inc(let what):
        inc( register: what )
      case .dec(let what):
        dec( register: what )
      case .jnz(let check, let by):
        jnz( check: check, by: by )
      case .out(let what):
        out( register: what )
      }
    }
  }

  func out( register: Register ) {
    transmit[ index ] = registers[register]
    index = index + 1

    // We've gathered enough data, halt the program.
    if index == transmit.endIndex {
      pc = code.endIndex
    } else {
      pc = pc.advanced(by: 1)
    }
  }

  func cpy( from: Value, to: Value ) {
    switch to {
    case .register(let register):
      registers[register] = read( from: from )
    case .int(_):
      break
    }

    pc = pc.advanced( by: 1 )
  }

  func inc( register: Value ) {
    switch register {
    case .register(let x):
      registers[ x ] += 1
    case .int(_):
      break
    }
    pc = pc.advanced( by: 1 )
  }

  func dec( register: Value ) {
    switch register {
    case .register(let x):
      registers[ x ] -= 1
    case .int(_):
      break
    }

    pc = pc.advanced( by: 1 )
  }

  func read( from: Value ) -> Int {
    switch from {
    case .register(let x):
      return registers[x]
    case .int(let x):
      return x
    }
  }

  func jnz( check: Value, by: Value ) {
    if read( from: check ) != 0 {
      pc = pc.advanced(by: read( from: by ))
    } else {
      pc = pc.advanced(by: 1)
    }
  }

  func checkSignal() -> Bool {
    for i in stride( from: transmit.startIndex, to: transmit.endIndex, by: 2 ) {
      if transmit[i] != 0 || transmit[i+1] != 1 {
        return false
      }
    }
    return true
  }
}

let cpu = CPU()
for line in STDIN {
  try cpu.load( line )
}

// The first bit has a period of 2 and starts with 1.
// We can reduce our search space by incrementing by 2.
// We can reduce our search space further by changing our offset/increment, but
// this terminates quickly enough so as not to be a problem (presumably from
// our peephole optimization)
var initial = 1
while true {
  cpu.reset( a: initial, b: 0, c: 0, d: 0 )
  cpu.execute()
  if cpu.checkSignal() {
    print( initial )
    break
  }
  initial += 2
}
