import Foundation

public let STDIN = sequence( state: (), next: { _ in readLine( strippingNewline: true ) } )
