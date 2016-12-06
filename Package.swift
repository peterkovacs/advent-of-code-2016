import PackageDescription

let package = Package( name: "AdventOfCode2016",
                       targets: [
                         Target( name: "Day2", dependencies: [ "Lib" ] ),
                         Target( name: "Day3", dependencies: [ "Lib" ] ),
                         Target( name: "Day4", dependencies: [ "Lib" ] ),
                         Target( name: "Day6", dependencies: [ "Lib" ] ),
                       ],
                       dependencies: [
                         .Package( url: "https://github.com/peterkovacs/FootlessParser.git", majorVersion: 1 ),
                         .Package( url: "https://github.com/IBM-Swift/CommonCrypto.git", majorVersion: 0 ),
                       ]
                      )

