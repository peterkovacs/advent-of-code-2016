import Foundation
import FootlessParser

enum Output {
  case bin(Int)
  case bot(Int)
}

enum Input {
  case value(Int, Int)
  case bot(Int)
}

class Bot: CustomStringConvertible {
  static var bots: Dictionary<Int, Bot> = [:]
  static var bins: Dictionary<Int, [Int]> = [:]

  let number: Int
  let low: Output
  let high: Output
  var chips: [Int] = []
  
  init( number: Int, low: Output, high: Output ) {
    self.number = number
    self.low = low
    self.high = high

    Bot.bots[ number ] = self
  }

  var description: String {
    return "Bot(\(number) -> \(low), \(high) chips: \(chips)"
  }
}

extension Bot {
  func give( chip: Int, to: Output ) {
    switch to {
    case .bot(let bot):
      Bot.bots[ bot ]!.take( chip: chip )
    case .bin(let num):
      if var bin = Bot.bins[ num ] {
        bin.append( chip )
      } else {
        Bot.bins[ num ] = [ chip ]
      }
    }
  }

  func take( chip: Int ) {
    chips.append( chip )

    if chips.count == 2 {
      chips.sort()

      if chips[0] == 17 && chips[1] == 61 {
        print( "Bot \(number) processing 17 & 61" )
      }

      give( chip: chips[0], to: self.low )
      give( chip: chips[1], to: self.high )

      chips = []
    }
  }

  static func execute( _ input: [Input] ) {
    for i in input {
      switch i {
      case .value( let chip, let bot ):
        Bot.bots[ bot ]!.take( chip: chip )
      case .bot(_):
        break
      }
    }
  }
}

extension Bot {
  static var parser: Parser<Character,Input> {
    let number = { Int($0)! } <^> oneOrMore( digit )
    let output = ( { Output.bot( $0 ) } <^> ( string( "bot " ) *> number ) ) <|> { Output.bin( $0 ) } <^> ( string( "output " ) *> number )

    let bot = curry({ (number:Int, low:Output, high:Output) -> Input in 
      Bot.bots[ number ] = Bot(number: number, low: low, high: high) 
      return Input.bot( number )
    }) <^> 
      ( string( "bot " ) *> number ) <*> 
      ( string( " gives low to " ) *> output ) <*> 
      ( string( " and high to " ) *> output )
    
    let pickup = 
      curry({ Input.value($0, $1) }) <^> 
      ( string( "value " ) *> number ) <*>
      ( string( " goes to bot " ) *> number )

    return bot <|> pickup
  }
}

