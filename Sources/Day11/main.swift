import Foundation
import Lib

// Elevator stops on each floor, counting as one step.
// Elevator may carry 2 {M | R} in any combination without danger of irradiation.
// Elevator must carry at least 1 {M | R} in order to function.
// M can only be on a floor iff there are no R or its compatible R is there.
// Final state: All items are on the 4th floor.

// Initial State
// 
// F4  .   .   .   .   .   .   .   .   .   .
// F3  .   .   .   .   .   .   .   .   .   .
// F2  .   .   .   .   .   .   .   .  PoM PrM
// F1 PoG ThG ThM PrG RuG RuM CoG CoM  .   .

enum Element: Int {
  case polonium
  case thulium
  case promethium
  case ruthenium
  case cobalt
  case elerium
  case dilithium
  case hydrogen
  case lithium
}

enum Type: Int {
  case microchip = 100
  case generator = 200
}

struct Item: Hashable {
  let type: Type
  let element: Element

  var hashValue: Int {
    return element.rawValue &+ type.rawValue
  }

  static func == (lhs: Item, rhs: Item) -> Bool {
    return lhs.element == rhs.element && lhs.type == rhs.type
  }
}

struct Pair: Hashable, Comparable {
  let chip: Int
  let generator: Int

  var hashValue: Int {
    return chip &* 10 &+ generator
  }

  static func == (l: Pair, r: Pair) -> Bool {
    return l.chip == r.chip && l.generator == r.generator
  }
  
  static func < (l: Pair, r: Pair) -> Bool {
    return l.hashValue < r.hashValue
  }
}

// The list of pairs on a given floor.
struct Pairs: Hashable {
  let elevator: Int
  let array: [Pair]

  var hashValue: Int {
    return array.reduce( elevator ) { $0 &* 100 &+ $1.hashValue }
  }

  static func == (l: Pairs, r: Pairs) -> Bool {
    return l.elevator == r.elevator && l.array.count == r.array.count && l.array.elementsEqual( r.array, by: == )
  }
}

typealias State = Set<Pairs>

struct Building {
  var elevator: Int = 0
  var floors: [Set<Item>]
  let elements: [Element]

  var pairs: Pairs {
    var result = [Pair]()
    for element in elements {
      let item0 = Item( type: .microchip, element: element )
      let item1 = Item( type: .generator, element: element )
      let chip = floors[0].contains(item0) ? 1 : floors[1].contains(item0) ? 2 : floors[2].contains(item0) ? 3 : 4
      let generator = floors[0].contains(item1) ? 1 : floors[1].contains(item1) ? 2 : floors[2].contains(item1) ? 3 : 4

      result.append( Pair( chip: chip, generator: generator ) )
    }

    return Pairs( elevator: elevator, array: result.sorted() )
  }

  var isValid: Bool {
    for floor in floors where floor.count > 0 {
      for item in floor where item.type == .microchip {
        // A building is valid if
        // a .microchip shares a floor with its matching .generator
        if floor.contains( Item( type: .generator, element: item.element ) ) { 
          continue 
        }

        // a .microchip shares the floor with no other generator
        if nil == floor.index( where: { $0.type == .generator } ) {
          continue
        }

        // otherwise its invalid
        return false
      }
    }

    return true
  }

  var isFinished: Bool {
    return floors[0].isEmpty && floors[1].isEmpty && floors[2].isEmpty 
  }

  func moves() -> [Building] {
    var result: [Building] = []

    // Up
    if elevator < 3 {
      if floors[elevator].count > 1 {
        for items in floors[elevator].combos(n:2) {
          var next = self
          next.elevator = next.elevator &+ 1
          for item in items { 
            next.floors[ next.elevator ].insert( item )
            next.floors[ self.elevator ].remove( item )
          }

          result.append(next)
        }
      }

      for item in floors[elevator] {
        var next = self
        next.elevator = next.elevator &+ 1
        next.floors[ next.elevator ].insert( item )
        next.floors[ self.elevator ].remove( item )
        result.append(next)
      }
    }

    // Down -- only move down if a row below us has something in it.
    if ( elevator == 1 && ( !floors[ 0 ].isEmpty ) ) ||
       ( elevator == 2 && ( !floors[ 0 ].isEmpty || !floors[ 1 ].isEmpty ) ) ||
       ( elevator == 3 && ( !floors[ 0 ].isEmpty || !floors[ 1 ].isEmpty || !floors[ 2 ].isEmpty ) ) {

      for item in floors[elevator] {
        var next = self
        next.elevator = next.elevator &- 1
        next.floors[ next.elevator ].insert( item )
        next.floors[ self.elevator ].remove( item )
        result.append(next)
      }

      if floors[elevator].count > 1 {
        for items in floors[elevator].combos(n:2) {
          var next = self
          next.elevator = next.elevator &- 1
          for item in items { 
            next.floors[ next.elevator ].insert( item )
            next.floors[ self.elevator ].remove( item )
          }

          result.append(next)
        }
      }
    }

    return result
  }
}

func solve( initial: Building ) -> (Int,[Building]) {
  var buildings: [(Int,Building,[Building])] = [(0, initial, [initial])]
  var state = State()

  while !buildings.isEmpty {
    let (num, building, moves) = buildings.removeFirst()
    let validMoves = building.moves().filter { $0.isValid }

    for move in validMoves {
      if move.isFinished { 
        var moves = moves
        moves.append( move )
        return (num + 1, moves) 
      }

      // Have we seen this state before?
      let pairs = move.pairs
      guard !state.contains( pairs ) else { continue }

      var moves = moves
      moves.append( move )
      state.insert( pairs )
      buildings.append( (num + 1, move, moves ) )
    }
  }

  return (-1,[])
}

extension Element: CustomStringConvertible {
  var description: String {
    switch self {
    case .polonium:
      return "Po"
    case .thulium:
      return "Th"
    case .promethium:
      return "Pr"
    case .ruthenium:
      return "Ru"
    case .cobalt:
      return "Co"
    case .elerium:
      return "El"
    case .dilithium:
      return "Di"
    case .hydrogen:
      return " H"
    case .lithium:
      return "Li"
    }
  }
}

extension Type: CustomStringConvertible {
  var description: String {
    switch self {
    case .microchip:
      return "M"
    case .generator:
      return "G"
    }
  }
}

extension Item: CustomStringConvertible {
  var description: String {
    return "\(element)\(type)"
  }
}

extension Building: CustomStringConvertible {
  var description: String {
    var result = ""
      for (i, floor) in floors.enumerated().reversed() {
        result.append( elevator == i ? "E " : "  " )
        for element in elements {
          let microchip = Item( type: .microchip, element: element )
          let generator = Item( type: .generator, element: element )

          if floor.contains( microchip ) {
            result.append( "\(microchip) " )
          } else { 
            result.append( " .. " )
          }

          if floor.contains( generator ) {
            result.append( "\(generator) " )
          } else { 
            result.append( " .. " )
          }
        }

        result.append( "\n" )
      }
      return result
  }
}

var sample = Building(elevator: 0,
                      floors: [ Set( [Item(type: .microchip, element: .hydrogen),
                                      Item(type: .microchip, element: .lithium)] ),
                                Set( [Item(type: .generator, element: .hydrogen)] ),
                                Set( [Item(type: .generator, element: .lithium)] ),
                                Set() ],
                      elements: [.hydrogen, .lithium])

var part1 = Building(elevator: 0, 
                     floors: [ Set( [Item(type: .generator, element: .polonium),
                                     Item(type: .generator, element: .thulium),
                                     Item(type: .microchip, element: .thulium),
                                     Item(type: .generator, element: .promethium),
                                     Item(type: .generator, element: .ruthenium),
                                     Item(type: .microchip, element: .ruthenium),
                                     Item(type: .generator, element: .cobalt),
                                     Item(type: .microchip, element: .cobalt)] ),
                               Set( [Item(type: .microchip, element: .polonium),
                                     Item(type: .microchip, element: .promethium)] ),
                               Set(),
                               Set() ],
                     elements: [.polonium, .thulium, .promethium, .ruthenium, .cobalt])

var part2 = Building(elevator: 0, 
                     floors: [ Set( [Item(type: .generator, element: .polonium),
                                     Item(type: .generator, element: .thulium),
                                     Item(type: .microchip, element: .thulium),
                                     Item(type: .generator, element: .promethium),
                                     Item(type: .generator, element: .ruthenium),
                                     Item(type: .microchip, element: .ruthenium),
                                     Item(type: .generator, element: .elerium),
                                     Item(type: .microchip, element: .elerium),
                                     Item(type: .generator, element: .dilithium),
                                     Item(type: .microchip, element: .dilithium),
                                     Item(type: .generator, element: .cobalt),
                                     Item(type: .microchip, element: .cobalt)] ),
                               Set( [Item(type: .microchip, element: .polonium),
                                     Item(type: .microchip, element: .promethium)] ),
                               Set(),
                               Set() ],
                     elements: [.polonium, .thulium, .promethium, .ruthenium, .cobalt, .elerium, .dilithium])

var (num, moves) = solve(initial: sample)
print( moves.map{ $0.description }.joined( separator: "\n" ) )
print( num )

(num, moves) = solve( initial: part1 )
print( moves.map{ $0.description }.joined( separator: "\n" ) )
print( num )

(num, moves) = solve( initial: part2 )
print( moves.map{ $0.description }.joined( separator: "\n" ) )
print( num )
