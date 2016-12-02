import PackageDescription

let package = Package( name: "AdventOfCode2016",
                       dependencies: [
                         .Package( url: "https://github.com/peterkovacs/FootlessParser.git", majorVersion: 1 )
                       ]
                      )

