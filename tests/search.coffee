assert = require 'assert'

suite 'Server Find', () ->
    test 'find something', (done, server) ->
        
        server.eval () ->
            Spomet.LatestPhrases.remove {}
            Spomet.CurrentSearch.remove {}
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', '0.1'
            e2 = new Spomet.Findable 'much more harder to find', '/', 'OID2', '0.1'
            
            Spomet.add e1
            Spomet.add e2
            
            Spomet.find 'much more', 'user', (m, d) ->
                emit 'callback', m, d
        
        server.on 'callback', (message, d) ->
            console.log message, d
            
            if message is 'Complete'
                done()