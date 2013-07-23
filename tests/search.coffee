assert = require 'assert'

suite 'Searches', () ->
    test 'find something', (done, server, client) ->
        
        server.eval () ->
            e1 = new Spomet.Findable 'this should be easily found', '1'
            e2 = new Spomet.Findable 'much more harder to find', '2'
            
            Spomet.add e1
            Spomet.add e2
            emit 'indexed', e1, e2
        
        server.once 'indexed', (e1, e2) ->
            console.log e1
            console.log e2

        client.eval () ->
            Spomet.find 'easily found', (error, e) ->
                emit 'return', e
        
        client.once 'return', (res) ->
            console.log res
            assert.equal res.length, 1
            done()