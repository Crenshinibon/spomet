assert = require 'assert'

suite 'Client Find', () ->
    test 'find something', (done, server, client) ->
        server.eval () ->
            Spomet.reset()
            
            e1 = 
                text: 'this should be easily found'
                path: '/', 
                base: 'OID1'
            e2 = 
                text: 'much more harder to find'
                path: '/'
                base: 'OID2'
            e3 = 
                text: 'more harder to find, is that really the case'
                path: '/'
                base: 'OID3'
            
            Spomet.add e1
            Spomet.add e2
            Spomet.add e3
            
        client.eval () ->
            Spomet.Searches.find().observe
                added: (result) ->
                    emit 'result', result
                            
            e = Spomet.Searches.find().fetch()
            emit 'empty', e
            Spomet.defaultSearch.find 'much more'
            
            checkEmpty = () ->
                e = Spomet.Searches.find().fetch()
                emit 'emptyAgain', e
            Meteor.setTimeout checkEmpty, 50
        
        client.once 'empty', (r) ->
            assert.equal 0, r.length
        
        client.once 'emptyAgain', (r) ->
            assert.equal 0, r.length
            done()
        count = 0
        client.on 'result', (result) ->
            if count is 0
                assert.equal result.base, 'OID2'
            if count is 1
                assert.equal result.base, 'OID3'
                done()
            count += 1
  
        
                    