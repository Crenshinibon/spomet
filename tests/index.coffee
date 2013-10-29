assert = require 'assert'

suite 'Index', () ->
    test 'add', (done, server) ->
        server.eval () ->
            Spomet.reset()
            
            doc = 
                text: 'some simple text'
                path: '/'
                base: 'oid1'
                type: 'post'
                
            docSpec = Spomet.Index.add doc
            emit 'added', Spomet._docId docSpec
            
            emit 'threegram', Spomet.ThreeGramIndex.collection.find().fetch()
            emit 'fullword', Spomet.FullWordIndex.collection.find().fetch()
            emit 'wordgroup', Spomet.WordGroupIndex.collection.find().fetch()
            emit 'custom', Spomet.CustomIndex.collection.find().fetch()
            emit 'docs', Spomet.Documents.collection.find({meta: {$exists: false}}).fetch()
                
        server.once 'added', (docId) ->
            assert.equal docId, 'post-oid1-/-1'
        
        server.once 'threegram', (index) ->
            assert.equal index.length, 16
            
        server.once 'fullword', (index) ->
            assert.equal index.length, 3
            
        server.once 'wordgroup', (index) ->
            assert.equal index.length, 2
        
        server.once 'custom', (index) ->
            assert.equal index.length, 4
            
        server.once 'docs', (docs) ->
            assert.equal 1, docs.length
            assert.equal docs[0].docId, 'post-oid1-/-1'
            assert.equal docs[0].text, 'some simple text'
            
            iTokens = docs[0].indexTokens
            assert.equal iTokens.length, 25
            done()
    
    test 'find', (done, server) ->
        server.eval () ->
            Spomet.reset()
            
            doc1 = 
                text: 'can be found'
                path: '/'
                base: 'oid1'
                type: 'post'
            Spomet.Index.add doc1
            
            doc2 = 
                text: 'this not'
                path: '/'
                base: 'oid2'
                type: 'post'
            Spomet.Index.add doc2
            
            doc3 = 
                text: 'quite hard to find'
                path: '/'
                base: 'oid3'
                type: 'post'
            Spomet.Index.add doc3
            
            
            Spomet.Index.find 'hard', (docId, hits, score) ->
                emit 'every', docId, hits, score
            
            
        prevScore = 0
        server.on 'every', (docId, hits, score) ->
            assert.ok hits.length < 7
            assert.ok score > prevScore
            assert.equal docId, 'post-oid3-/-1'
            prevScore = score
            done()
            