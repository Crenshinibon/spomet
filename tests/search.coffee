assert = require 'assert'

suite 'Server Find', () ->
    test 'find something', (done, server) ->
        
        server.eval () ->
            Spomet.reset()
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', '0.1'
            e2 = new Spomet.Findable 'more harder to find', '/', 'OID2', '0.1'
            e3 = new Spomet.Findable 'much more much more harder to find', '/', 'OID3', '0.1'
            
            Spomet.add e1
            Spomet.add e2
            Spomet.add e3
            
            Spomet.find 'much more', 'user', (m, d) ->
                emit 'callback', m, d
                
            emit 'result', Spomet.CurrentSearch.find({user: 'user'}).fetch()
        
        count = 0
        server.on 'callback', (message, d) ->
            count += 1
            #console.log message, d
            if message is 'Complete'
                assert.equal 6, count
                           
        server.on 'result', (ra) ->
            #console.log ra
            assert.equal 2, ra.length
            assert.ok (ra.some (e) -> e.base is 'OID2')
            assert.ok (ra.some (e) -> e.base is 'OID3')
            done()
            
            
suite 'Client Find', () ->
    test 'find something', (done, server, client) ->
        server.eval () ->
            Spomet.reset()
            Accounts.createUser({email: 'test@test.com', password: '12345'})
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', '0.1'
            e2 = new Spomet.Findable 'much more harder to find', '/', 'OID2', '0.1'
            e3 = new Spomet.Findable 'more harder to find, is that really the case', '/', 'OID3', '0.1'
            
            Spomet.add e1
            Spomet.add e2
            Spomet.add e3
            
        client.eval () ->
            Meteor.loginWithPassword 'test@test.com', '12345', () ->
                Spomet.CurrentSearch.find().observe
                    added: (result) ->
                        emit 'result', result
                            
                e = Spomet.CurrentSearch.find().fetch()
                emit 'empty', e
                Spomet.find 'much more'
                
        client.once 'empty', (r) ->
            console.log 'Empty', r
            assert.equal 0, r.length
            client.eval () ->
        
        count = 0
        client.on 'result', (result) ->
            console.log result
            if count is 0
                assert.equal result.base, 'OID2'
            if count is 1
                assert.equal result.base, 'OID3'
                done()
            count += 1
    
        
                    