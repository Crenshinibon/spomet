assert = require 'assert'

suite 'pubsub', () ->
    test 'pubsub', (done, server, client) ->
        server.eval () ->
            @col = new Meteor.Collection 'test'
            col.insert {test: 'test'}
            col.insert {test: 'fest'}
            
            Meteor.publish 'test', () ->
                col.find {test: 'fest'}
            
            
        server.once 'stopped', () ->
            assert.equal 2, times
            done()
            
            
        client.eval () ->
            Meteor.subscribe 'test', () ->
                emit 'ready'
            @col = new Meteor.Collection 'test'
                    
            col.find().observe
                added: (e) ->
                    emit 'result', e
        times = 0    
        client.on 'result', (e) ->
            console.log e
            times += 1
            if times is 1
                assert.equal e.test, 'fest'
                
        client.once 'ready', () ->
            assert.equal times, 1
            done()