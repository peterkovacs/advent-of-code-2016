import Foundation

public func adding<T,A: IntegerArithmetic>( _ x: Parser<T,A>, to start: A ) -> Parser<T,A> {
  let p: Parser<T,A> = Parser { input in
    var (first, remainder) = try x.parse(input)
    var result = start + first

    while true {
      do {
        let next = try x.parse( remainder )
        result += next.output
        remainder = next.remainder 
      } catch {
        return (result, remainder)
      }
    }
  }

  return optional(p, otherwise: start)
}


public func decompress() -> Parser<Character, Int> {
  // (#x#)
  let tagParser = 
    tuple <^> (char("(") *> (                  {Int($0)!} <^> oneOrMore(digit))) <*> 
                             ( char( "x" ) *> ({Int($0)!} <^> oneOrMore(digit))  <* char(")"))
  // exactly 1 of anything else.
  let anyParser: Parser<Character,(Int,Int)> = { _ in (0, 1) } <^> any()
  // either tag or a single character
  let parser = tagParser <|> anyParser

  return Parser { input in
    let (tag, remainder) = try parser.parse( input )

    guard nil != remainder.index( remainder.startIndex, offsetBy: IntMax(tag.0), limitedBy: remainder.endIndex ) else {
      throw ParseError.Mismatch( remainder, "decompress", "EOF" )
    }

    if tag.0 > 0 {
      return ( tag.0 * tag.1, remainder.dropFirst(tag.0) )
    } else {
      return ( tag.1, remainder )
    }
  }
}

public func recursiveDecompress() -> Parser<Character, Int> {
  // (#x#)
  let tagParser = 
    tuple <^> (char("(") *> (                  {Int($0)!} <^> oneOrMore(digit))) <*> 
                             ( char( "x" ) *> ({Int($0)!} <^> oneOrMore(digit))  <* char(")"))
  // exactly 1 of anything else.
  let anyParser: Parser<Character,(Int,Int)> = { _ in (0, 1) } <^> any()
  // either tag or a single character
  let parser = tagParser <|> anyParser

  // our lazy recursive parser.
  let recurse = lazy( adding( recursiveDecompress(), to: 0 ) <* eof() )
    
  return Parser { input in
    let (tag, remainder) = try parser.parse( input )

    guard let endIndex = remainder.index( remainder.startIndex, offsetBy: IntMax(tag.0), limitedBy: remainder.endIndex ) else {
      throw ParseError.Mismatch( remainder, "decompress", "EOF" )
    }

    if remainder.startIndex < endIndex {
      let ( result, _ ) = try recurse.parse( remainder[ remainder.startIndex..<endIndex ] )
      return ( tag.1 * result, remainder.dropFirst(tag.0) )
    } else {
      return ( tag.1, remainder )
    }
  }
}


