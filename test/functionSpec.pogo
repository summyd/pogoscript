script = require './scriptAssertions'

shouldOutput = script.shouldOutput
shouldThrow = script.shouldThrow

describe 'functions'
  describe 'definitions'
    it 'functions can be defined by placing the arguments to the left of the equals sign "="'
      'succ (n) =
         n + 1
      
       print (succ (1))' shouldOutput '2'
    
    describe 'functions with no arguments'
      it 'a function can be defined to have no parameters with empty parens "()"'
          'say hi () =
             print "hi"
      
           say hi ()' shouldOutput "'hi'"
      
      it "a function's parameters shadow variables in outer scope"
        'foo (a) =
           print (a)
        
         a = "outer a"
         foo "inner a"
         print (a)' shouldOutput "'inner a'
                                  'outer a'"

  describe 'splats'
      it 'a function can be defined with a single splat parameter'
        'foo (args, ...) =
           print (args)
         
         foo 1 2' shouldOutput '[ 1, 2 ]'
      
      it 'a function can be called with more than one splat argument'
        'foo (args, ...) =
           print (args)
     
         foo 1 [2, 3] ... [4, 5] ... 6' shouldOutput '[ 1, 2, 3, 4, 5, 6 ]'
      
      it "a function's splat parameter shadows variables in outer scope"
        'foo (a, ...) =
           print (a.0)
         
         a = "outer a"
         
         foo "inner a"
         print (a)' shouldOutput "'inner a'
                                  'outer a'"

  describeOptionalsWithDelimiter (block) =
    block ':'
    block '='
  
  describeOptionalsWithDelimiter @(delim)
    describe "optional arguments with #(delim)"
      it 'functions can take optional arguments'
        "print (size #(delim) 10)" shouldOutput '{ size: 10 }'

      it 'a function can be defined to take an optional argument'
        "open tcp connection (host #(delim) nil, port #(delim) nil) =
           print (host)
           print (port)
         
         open tcp connection (host #(delim) 'pogoscript.org', port #(delim) 80)" shouldOutput "'pogoscript.org'
                                                                                               80"
      
      it 'if the optional parameter has a default value
        and no optional arguments are passed by the caller,
        then that default value is used'
          
        "open tcp connection (port #(delim) 80) =
           print (port)
         
         open tcp connection ()" shouldOutput "80"
      
      it 'if the optional parameter has a default value
        and other optional arguments are passed by the caller
        but not that one, then that default value is used'
          
        "open tcp connection (port #(delim) 80) =
           print (port)
         
         open tcp connection (host #(delim) 'pogoscript.org')" shouldOutput "80"
      
      it "a function's optional parameter shadows variables in outer scope"
        "foo (bar #(delim) nil) =
           print (bar)
         
         bar = 'outer bar'
         foo (bar #(delim) 'inner bar')
         print (bar)" shouldOutput "'inner bar'
                                    'outer bar'"
      
      it "a function's optional parameter shadows variables in outer scope,
        even if it has a default value"
          
        "foo (bar #(delim) 80) =
           print (bar)
         
         bar = 'outer bar'
         foo (bar #(delim) 'inner bar')
         print (bar)" shouldOutput "'inner bar'
                                    'outer bar'"
      
      it "when a block is passed as an optional argument, it does not redefine self"
        "foo (bar #(delim) nil) =
             bar ()
         
         obj = {
           field = 'field value'
           method () =
             foo (bar () #(delim) print (self.field))
         }

         obj.method ()" shouldOutput "'field value'"

  describe 'redefining self'
    it 'redefines self with the => operator'
      'print self () = =>
         print (self.x)
       
       print self.call ({x = "self"})' shouldOutput "'self'"

  describe 'calling anonymous functions'
    it 'can call an anonymous function'
      'print "thang"
       @{ print "thing" } ()
       print "thong"' shouldOutput "'thang'
                                    'thing'
                                    'thong'"

  describe 'returning promises'
    it 'can return a promise'
      'f () = p 8
       print (f()!)' shouldOutput '8'

    it 'can return a promise by resolving one'
      'f () = p 8!
       print (f()!)' shouldOutput '8'

    it 'can return a promise by resolving one, then returning a value'
      'f () =
         p 8!
         4

       print (f()!)' shouldOutput '4'

    it 'can resolve multiple times, but the function only runs once'
      'a() =
         p ()!
         print "running a"
         "a"

       b = a()

       print (b!)
       print (b!)' shouldOutput "'running a'
                                 'a'
                                 'a'"

    it 'can be executed multiple times'
      'a() =
         p ()!
         print "running a"
         "a"

       print (a()!)
       print (a()!)' shouldOutput "'running a'
                                   'a'
                                   'running a'
                                   'a'"

    describe 'forcing return of promises'
      context 'when the function is defined with a !'
        it 'returns a promise if the body is not in a block'
          'f()! = 6
           
           f().then @(result)
             print (result)' shouldOutput '6'

        it 'returns a promise if the body is in a block'
          'f()! =
             6
           
           f().then @(result)
             print (result)' shouldOutput '6'

        it 'can define a new variable inside a promise function'
          'f()! =
             t = 6
           
           f().then @(result)
             print (result)' shouldOutput '6'

    describe 'throwing exceptions'
      context 'when the exception is thrown before a promise is resolved in the body'
        it 'only throws the exception when the promise is resolved'
          'a() =
             @throw @new Error "uh oh"
             p "result"!

           b = a()

           try
             b!
           catch (error)
             print (error.message)' shouldOutput "'uh oh'"

      context 'when the exception is thrown after a promise is resolved in the body'
        it 'only throws the exception when the promise is resolved'
          'a() =
             p "result"!
             @throw @new Error "uh oh"

           b = a()

           try
             b!
           catch (error)
             print (error.message)' shouldOutput "'uh oh'"

    describe 'callback functions'
      it 'can call a method with a callback'
        'func (cb) =
           setTimeout @{ cb(nil, "result") } 1

         print (func (^)!)' shouldOutput "'result'"

      it 'can call a method with a callback and options'
        'func (cb, opts) =
           setTimeout @{ cb(nil, opts) } 1

         print (func (a = "a", ^)!)' shouldOutput "{ a: 'a' }"
