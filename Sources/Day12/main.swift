import Foundation
import FootlessParser
import Lib

typealias Register = Int

enum Value {
  case register(Register)
  case int(Int)
}

enum Instruction {
  case cpy(Value, Register)
  case inc(Register)
  case dec(Register)
  case jnz(Value, Int)
}

class CPU {
  public var code: [Instruction] = []
  public var pc: Int = 0
  public var registers: [Int] = [Int]( repeating: 0, count: 4 )

  func reset( a: Int, b: Int, c: Int, d: Int ) {
    registers = [ a, b, c, d ]
    pc = 0
  }

  lazy var parser: Parser<Character, Instruction> = {
    let number = { (num: String) -> Int in return Int(num)! } <^> ( extend <^> optional( string( "-" ), otherwise: "" ) <*> oneOrMore( digit ) )
    let register = { Int(UnicodeScalar("\($0)".unicodeScalars.first!).value - 0x61) } <^> oneOf( "abcd".characters )
    let value = ( { Value.register($0) } <^> register ) <|> ( { Value.int( $0 ) } <^> number )
    let cpy: Parser<Character,Instruction>  = { val in { reg in return Instruction.cpy( val, reg ) } } <^> ( string( "cpy " ) *> value ) <*> ( oneOrMore( whitespace ) *> register )
    let inc: Parser<Character,Instruction>  = { Instruction.inc( $0 ) } <^> ( string( "inc " ) *> register )
    let dec: Parser<Character,Instruction>  = { Instruction.dec( $0 ) } <^> ( string( "dec " ) *> register )
    let jnz: Parser<Character,Instruction> = { reg in { int in return Instruction.jnz( reg, int ) } } <^> ( string( "jnz " ) *> value ) <*> ( oneOrMore( whitespace ) *> number )

    return cpy <|> inc <|> dec <|> jnz
  }()

  func load( _ line: String ) throws {
    code.append( try parse( parser, line ) )
  }

  func execute() {
    while pc != code.endIndex {
      let instruction = code[ pc ]
      switch instruction {
      case .cpy(let from, let to):
        cpy( from: from, to: to )
      case .inc(let what):
        inc( register: what )
      case .dec(let what):
        dec( register: what )
      case .jnz(let check, let by):
        jnz( check: check, by: by )
      }
    }
  }

  func cpy( from: Value, to: Register ) {
    switch from {
    case .register(let register):
      registers[to] = registers[register]
    case .int(let value):
      registers[to] = value
    }

    pc = pc.advanced( by: 1 )
  }

  func inc( register: Register ) {
    registers[ register ] += 1
    pc = pc.advanced( by: 1 )
  }

  func dec( register: Register ) {
    registers[ register ] -= 1
    pc = pc.advanced( by: 1 )
  }

  func jnz( check: Value, by: Int ) {
    switch check {
    case .register(let register):
      if registers[register] != 0 {
        pc = pc.advanced(by: by)
      } else {
        pc = pc.advanced(by: 1)
      }
    case .int(let val):
      if val != 0 {
        pc = pc.advanced(by: by)
      } else {
        pc = pc.advanced(by: 1)
      }
    }
  }
}

let cpu = CPU()
for line in Input() {
  try cpu.load( line )
}
cpu.execute()
print( cpu.registers )

cpu.reset( a: 0, b: 0, c: 1, d: 0 )
cpu.execute()
print( cpu.registers )

