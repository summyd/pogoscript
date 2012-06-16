script = require './scriptAssertions.pogo'

describe 'for'
    it 'can be returned from'
        script.'count to three () =
                    for (n = 0, n < 10, n = n + 1)
                        if (n > 2)
                            return "three"

                print (count to three ())' should output '''three'''
        
    it "returns in functions within for don't return from for"
        script.'items = [[1, 2, 3], [1, 2], [1]]

                for each @(item) in (items)
                  item count () = return (item.length)

                  print (item count ())' should output '3
                                                        2
                                                        1'
        
    it 'can loop'
        script.'count to three () =
                    for (n = 0, n < 10, n = n + 1)
                        print (n)

                count to three ()' should output '0
                                                  1
                                                  2
                                                  3
                                                  4
                                                  5
                                                  6
                                                  7
                                                  8
                                                  9'
