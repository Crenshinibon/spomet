assert = require 'assert'

suite 'Index', () ->
    test 'rate', (done, server) ->
        server.eval () ->
            a = Spomet.Index.rate 2, 25, 4, 2, 1
            emit 'rate', a
        server.once 'rate', (a) ->
            assert.equal 2 / Math.log(4 * 25) * Math.log(3 / 1), a
            done()
    
    test 'add', (done, server) ->
        server.eval () ->
            Spomet.reset()
            
            doc = new Spomet.Findable('some simple text', '/', 'oid1', 'post', 1)
            Spomet.Index.add doc, (docId, message) ->
                emit 'added', docId
                
                emit 'threegram', Spomet.ThreeGramIndex.collection.find().fetch()
                emit 'fullword', Spomet.FullWordIndex.collection.find().fetch()
                emit 'wordgroup', Spomet.WordGroupIndex.collection.find().fetch()
                emit 'docs', Spomet.Documents.collection.find().fetch()
                
        server.once 'added', (docId) ->
            assert.equal docId, 'post-oid1-/-1'
        
        server.once 'threegram', (index) ->
            assert.equal index.length, 16
            
        server.once 'fullword', (index) ->
            assert.equal index.length, 3
            
        server.once 'wordgroup', (index) ->
            assert.equal index.length, 2
            
        server.once 'docs', (docs) ->
            assert.equal 1, docs.length
            assert.equal docs[0].docId, 'post-oid1-/-1'
            assert.equal docs[0].findable.text, 'some simple text'
            
            iTokens = docs[0].indexTokens
            assert.equal iTokens.length, 3
            done()
    