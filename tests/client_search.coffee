assert = require 'assert'

suite 'Client Find', () ->
    test 'find something', (done, server, client) ->
        server.eval () ->
            Spomet.reset()
            Accounts.createUser({email: 'test@test.com', password: '12345'})
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', 1
            e2 = new Spomet.Findable 'much more harder to find', '/', 'OID2', 1
            e3 = new Spomet.Findable 'more harder to find, is that really the case', '/', 'OID3', 1
            
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
            #console.log result
            if count is 0
                assert.equal result.base, 'OID2'
            if count is 1
                assert.equal result.base, 'OID3'
                done()
            count += 1
  
        
                    