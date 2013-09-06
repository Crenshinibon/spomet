assert = require 'assert'

suite 'SharedIndex', () ->
    test 'rate', (done, server) ->
        
        server.eval () ->
            a = Spomet.Index.rate 2, 25, 4, 2, 1
            emit 'rate', a
        server.once 'rate', (a) ->
            assert.equal 2 / Math.log(4 * 25) * Math.log(3 / 1), a
            done()
