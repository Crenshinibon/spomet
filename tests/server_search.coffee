assert = require 'assert'

suite 'Server Find', () ->
    test 'find something', (done, server) ->
        
        server.eval () ->
            Spomet.reset()
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', 1
            e2 = new Spomet.Findable 'more harder to find', '/', 'OID2', 1
            e3 = new Spomet.Findable 'much more much more harder to find', '/', 'OID3', 1
            
            Spomet.add e1
            Spomet.add e2
            Spomet.add e3
            
            Spomet.find 'much more eas', 'user', 'sessionId',
                wordGroupCallback: (results) ->
                    emit 'wgcallback', results
                fullWordsCallback: (results) ->
                    emit 'fwcallback', results
                threeGramCallback: (results) ->
                    emit 'tgcallback', results
                completeCallback: (results) ->
                    emit 'callback', results
                            
        server.once 'wgcallback', (r) ->
            assert.equal 1, r.length
            assert.equal 'OID3', r[0].base
        
        server.once 'fwcallback', (r) ->
            assert.equal 2, r.length
            assert.ok (r.some (e) -> e.base is 'OID3')
            assert.ok (r.some (e) -> e.base is 'OID2')
        
        server.once 'tgcallback', (r) ->
            assert.equal 3, r.length
            assert.ok (r.some (e) -> e.base is 'OID3')
            assert.ok (r.some (e) -> e.base is 'OID2')
            assert.ok (r.some (e) -> e.base is 'OID1')
            
        server.once 'callback', (r) ->
            assert.equal 3, r.length
            assert.ok (r.some (e) -> e.base is 'OID3')
            assert.ok (r.some (e) -> e.base is 'OID2')
            assert.ok (r.some (e) -> e.base is 'OID1')
            
            #maybe should delay this, because of slow db
            server.eval () ->
                cur = Spomet.CurrentSearch.find {user: 'user'}
                emit 'result', cur.fetch()
                
        server.on 'result', (r) ->
            assert.equal 3, r.length
            assert.ok (r.some (e) -> e.base is 'OID1')
            assert.ok (r.some (e) -> e.base is 'OID2')
            assert.ok (r.some (e) -> e.base is 'OID3')
            done()
