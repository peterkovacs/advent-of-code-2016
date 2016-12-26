import PackageDescription

let package = Package( name: "AdventOfCode2016",
                       targets: [
                         Target( name: "Day1", dependencies: [ "Lib" ] ),
                         Target( name: "Day2", dependencies: [ "Lib" ] ),
                         Target( name: "Day3", dependencies: [ "Lib" ] ),
                         Target( name: "Day4", dependencies: [ "Lib" ] ),
                         Target( name: "Day5", dependencies: [ "Lib" ] ),
                         Target( name: "Day6", dependencies: [ "Lib" ] ),
                         Target( name: "Day7", dependencies: [ "Lib" ] ),
                         Target( name: "Day8", dependencies: [ "Lib" ] ),
                         Target( name: "Day9", dependencies: [ "Lib" ] ),
                         Target( name: "Day10", dependencies: [ "Lib" ] ),
                         Target( name: "Day11", dependencies: [ "Lib" ] ),
                         Target( name: "Day12", dependencies: [ "Lib" ] ),
                         Target( name: "Day13", dependencies: [ "Lib" ] ),
                         Target( name: "Day14", dependencies: [ "Lib" ] ),
                         Target( name: "Day15", dependencies: [ "Lib" ] ),
                         Target( name: "Day17", dependencies: [ "Lib" ] ),
                         Target( name: "Day20", dependencies: [ "Lib" ] ),
                         Target( name: "Day21", dependencies: [ "Lib" ] ),
                         Target( name: "Day22", dependencies: [ "Lib" ] ),
                         Target( name: "Day23", dependencies: [ "Lib" ] ),
                         Target( name: "Day24", dependencies: [ "Lib" ] ),
                       ],
                       dependencies: [
                         .Package( url: "https://github.com/peterkovacs/FootlessParser.git", majorVersion: 1 ),
                         .Package( url: "https://github.com/IBM-Swift/CommonCrypto.git", majorVersion: 0 ),
                       ]
                      )

