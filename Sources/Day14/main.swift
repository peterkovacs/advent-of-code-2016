import Foundation

print( Array(KeyGenerator( salt: CommandLine.arguments[1], rounds: Int(CommandLine.arguments[2])! ).prefix(64)) )
