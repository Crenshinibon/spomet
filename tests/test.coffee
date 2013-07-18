assert = require 'assert'

suite 'Test', () ->
    test 'coffee', (done, server) ->
        server.eval () ->
            e = some_fun()
            emit 'fun_called', e
            emit 'test_package', test_package()
                    
        server.once 'fun_called', (e) ->
            assert.equal e, 'some fun called'
            console.log e
        
        server.once 'test_package', (e) ->
            assert.equal e[0], 'found'
            console.log e
            done()
            
    
    test 'coffee package', (done, server) ->
        server.eval () ->
            e = Spomet.find('some phrase')
            emit 'found', e

        server.once 'found', (e) ->
            assert.equal e.length, 1
            done()