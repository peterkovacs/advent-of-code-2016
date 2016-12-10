import Foundation
import FootlessParser
import Lib

let result = Lib.Input().map { try! parse( Bot.parser, $0 ) }

// print( result )
// print( Bot.bots )

Bot.execute( result )

print( Bot.bins[0]![0] * Bot.bins[1]![0] * Bot.bins[2]![0] )
