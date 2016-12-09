import PackageDescription

let package = Package( name: "AdventOfCode2016",
                       targets: [
                         Target( name: "Day1", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day2", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day3", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day4", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day5", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day6", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day7", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day8", dependencies: [ "Lib", "FootlessParser" ] ),
                         Target( name: "Day9", dependencies: [ "Lib", "FootlessParser" ] ),
                       ],
                       dependencies: [
                         .Package( url: "https://github.com/IBM-Swift/CommonCrypto.git", majorVersion: 0 ),
                       ]
                      )

