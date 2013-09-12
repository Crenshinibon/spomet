assert = require 'assert'

suite 'Index', () ->
    test 'tfidf', (done, server) ->
        server.eval () ->
            a = Spomet.Index.tfidf 2, 25, 4, 2, 1
            emit 'rate', a
        server.once 'rate', (a) ->
            assert.equal 2 / Math.log(4 * 25) * Math.log(3 / 1), a
            done()
    
    test 'add', (done, server) ->
        server.eval () ->
            Spomet.reset()
            
            doc = new Spomet.Findable 'some simple text', '/', 'oid1', 'post', 1
            Spomet.Index.add doc, (docId, message) ->
                emit 'added', docId
                
                emit 'threegram', Spomet.ThreeGramIndex.collection.find().fetch()
                emit 'fullword', Spomet.FullWordIndex.collection.find().fetch()
                emit 'wordgroup', Spomet.WordGroupIndex.collection.find().fetch()
                emit 'docs', Spomet.Documents.collection.find({meta: {$exists: false}}).fetch()
                
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
            assert.equal iTokens.length, 21
            done()
    
    test 'findWithIndex', (done, server) ->
        server.eval () ->
            Spomet.reset()
            
            doc1 = new Spomet.Findable 'can be found', '/', 'oid1', 'post', 1
            Spomet.Index.add doc1
            doc2 = new Spomet.Findable 'this not', '/', 'oid2', 'post', 1
            Spomet.Index.add doc2
            doc3 = new Spomet.Findable 'quite hard to find', '/', 'oid3', 'post', 1
            Spomet.Index.add doc3
            
            
            res = Spomet.Index.findWithIndex Spomet.ThreeGramIndex, 
                'hard', 
                (token, docId, pos) -> 
                    emit 'found', token, docId, pos
            emit 'all', res
            
        counter = 0
        server.on 'found', (token, docId, pos) ->
            counter += 1
            assert.ok token in [' ha', 'har', 'ard', 'rd ']
            assert.equal docId, 'post-oid3-/-1'
            assert.ok pos in [6,7,8,9]
            assert.ok counter < 5
            
        server.on 'all', (res) ->
            docMatches = res['post-oid3-/-1']
            assert.ok docMatches? 
            docMatches.forEach (e) ->
                assert.ok e.token in [' ha', 'har', 'ard', 'rd ']
                assert.ok e.pos in [6,7,8,9]
            done()
    
    test 'find', (done, server) ->
        server.eval () ->
            Spomet.reset()
            
            doc1 = new Spomet.Findable 'can be found', '/', 'oid1', 'post', 1
            Spomet.Index.add doc1
            doc2 = new Spomet.Findable 'this not', '/', 'oid2', 'post', 1
            Spomet.Index.add doc2
            doc3 = new Spomet.Findable 'quite hard to find', '/', 'oid3', 'post', 1
            Spomet.Index.add doc3
            
            
            res = Spomet.Index.find 'hard', (docId, hits, score) ->
                emit 'every', docId, hits, score
            emit 'all1', res
            
            res = Spomet.Index.find 'can be hard'
            emit 'all2', res
            
        prevScore = 0
        server.on 'every', (docId, hits, score) ->
            assert.ok hits.length < 6
            assert.ok score > prevScore
            assert.equal docId, 'post-oid3-/-1'
            prevScore = score
            
        server.once 'all1', (res) ->
            assert.equal res.length, 1
            assert.equal res[0].docId, 'post-oid3-/-1'
            tokens = res[0].hits.map (h) -> h.token
            assert.ok tokens.every (t) -> t in ['hard', ' ha', 'har', 'ard', 'rd ']
            
        server.once 'all2', (res) ->
            assert.equal res.length, 2
            res.sort (a, b) -> b.score - a.score
            assert.equal res[0].docId, 'post-oid1-/-1'
            assert.equal res[1].docId, 'post-oid3-/-1'
            done()
            