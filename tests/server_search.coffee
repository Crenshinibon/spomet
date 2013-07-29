assert = require 'assert'

suite 'Server Find', () ->
    test 'find something', (done, server) ->
        
        server.eval () ->
            Spomet.reset()
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', '0.1'
            e2 = new Spomet.Findable 'more harder to find', '/', 'OID2', '0.1'
            e3 = new Spomet.Findable 'much more much more harder to find', '/', 'OID3', '0.1'
            
            Spomet.add e1, () ->
                Spomet.add e2, () ->
                    Spomet.add e3, () ->
                        Spomet.find 'much more', 'user', (m, d) ->
                            emit 'callback', m, d
                            
        server.once 'callback', (message, d) ->
            assert.equal 'Complete', message
            assert.ok d['OID2/0.1']?
            assert.ok d['OID3/0.1']?
            
            server.eval () ->
                Meteor.setTimeout () ->
                    emit 'result', Spomet.CurrentSearch.find({user: 'user'}).fetch()
                , 1000
                       
        server.on 'result', (ra) ->
            #console.log ra
            assert.equal 2, ra.length
            assert.ok (ra.some (e) -> e.base is 'OID2')
            assert.ok (ra.some (e) -> e.base is 'OID3')
            done()
