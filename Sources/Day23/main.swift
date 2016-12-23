import Foundation
import FootlessParser
import Lib

typealias Register = Int

enum Value {
  case register(Register)
  case int(Int)
}

enum Instruction {
  case cpy(Value, Value)
  case inc(Value)
  case dec(Value)
  case jnz(Value, Value)
  case tgl(Value)
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
    let cpy: Parser<Character,Instruction>  = { val in { reg in return Instruction.cpy( val, .register(reg) ) } } <^> ( string( "cpy " ) *> value ) <*> ( oneOrMore( whitespace ) *> register )
    let inc: Parser<Character,Instruction>  = { Instruction.inc( .register($0) ) } <^> ( string( "inc " ) *> register )
    let dec: Parser<Character,Instruction>  = { Instruction.dec( .register($0) ) } <^> ( string( "dec " ) *> register )
    let jnz: Parser<Character,Instruction> = { reg in { int in return Instruction.jnz( reg, int ) } } <^> ( string( "jnz " ) *> value ) <*> ( oneOrMore( whitespace ) *> value )
    let tgl: Parser<Character,Instruction> = { Instruction.tgl( $0 ) } <^> ( string( "tgl " ) *> value )

    return cpy <|> inc <|> dec <|> jnz <|> tgl
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
      case .tgl(let what):
        tgl( x: what )
      }
    }
  }

  func tgl( x: Value ) {
    tgl( x: read( from: x ) )
  }

  func tgl( x: Int ) {
    let loc = pc + x
    if loc >= 0 && loc < code.count {
      let instruction = code[ loc ]
      switch instruction {
      case .cpy(let from, let to):
        code[loc] = .jnz(from, to)
      case .inc(let what):
        code[loc] = .dec(what)
      case .dec(let what):
        code[loc] = .inc(what)
      case .jnz(let check, let by):
        code[loc] = .cpy( check, by )
      case .tgl(let what):
        code[loc] = .inc(what)
      }
    }

    pc = pc.advanced(by: 1)
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
}

let cpu = CPU()
for line in STDIN {
  try cpu.load( line )
}

if CommandLine.arguments[1] == "1" {
  cpu.reset( a: 7, b: 0, c: 0, d: 0 )
  cpu.execute()
  print( cpu.registers )
} else {
  cpu.reset( a: 12, b: 0, c: 0, d: 0 )
  cpu.execute()
  print( cpu.registers )
}

