assert = require 'assert'

suite 'Server Find', () ->
    
    test 'add remove', (done, server) ->
        
        server.eval () ->
            Spomet.reset()
            
            e1 = new Spomet.Findable 'this is should be easily found', '/', 'OID1', 'post', 1
            Spomet.add e1
            e2 = new Spomet.Findable 'this is is', '/', 'OID2', 'post', 1
            Spomet.add e2
            e3 = new Spomet.Findable 'much more much more harder to find', '/', 'OID3', 'post', 1
            Spomet.add e3
            
            emit 'tg1', Spomet.ThreeGramIndex.collection.find().fetch()
            emit 'fw1', Spomet.FullWordIndex.collection.find().fetch()
            emit 'wg1', Spomet.WordGroupIndex.collection.find().fetch()
            emit 'docs1', Spomet.Documents.collection.find().fetch()
            
            emit 'docCount1', Spomet.FullWordIndex.collection.findOne {token: 'is'}
            
            Spomet.remove e2.docId
            
            emit 'tg2', Spomet.ThreeGramIndex.collection.find().fetch()
            emit 'fw2', Spomet.FullWordIndex.collection.find().fetch()
            emit 'wg2', Spomet.WordGroupIndex.collection.find().fetch()
            emit 'docs2', Spomet.Documents.collection.find().fetch()
            
            emit 'docCount2', Spomet.FullWordIndex.collection.findOne {token: 'is'}
            
        server.once 'tg1', (tokens) ->
            doc1Tokens = tokens.filter (e) ->
                e.token in [' th','thi','his','is ','s i',' is','is ']
            doc1Tokens.forEach (e) ->
                assert.ok e.documents.some (d) ->
                    d.docId is 'post-OID2-/-1'
        
        server.once 'fw1', (tokens) ->
            doc1Tokens = tokens.filter (e) ->
                e.token in ['this','is']
            doc1Tokens.forEach (e) ->
                assert.ok e.documents.some (d) ->
                    d.docId is 'post-OID2-/-1'
        
        server.once 'wg1', (tokens) ->
            doc1Tokens = tokens.filter (e) ->
                e.token is 'thisis'
            doc1Tokens.forEach (e) ->
                assert.ok e.documents.some (d) ->
                    d.docId is 'post-OID2-/-1'
                    
        server.once 'docs1', (docs) ->
            assert.ok docs.some (d) ->
                d.docId is 'post-OID2-/-1'
                
        server.once 'docCount1', (indexToken) ->
            assert.equal indexToken.documentsCount, 2
        
        server.once 'tg2', (tokens) ->
            doc1Tokens = tokens.filter (e) ->
                e.token in [' th','thi','his','is ','s i',' is','is ']
            doc1Tokens.forEach (e) ->
                assert.ok e.documents.every (d) ->
                    d.docId isnt 'post-OID2-/-1'
            
        server.once 'fw2', (tokens) ->
            doc1Tokens = tokens.filter (e) ->
                e.token in ['this','is']
            doc1Tokens.forEach (e) ->
                assert.ok e.documents.every (d) ->
                    d.docId isnt 'post-OID2-/-1'
                    
        server.once 'wg2', (tokens) ->
            doc1Tokens = tokens.filter (e) ->
                e.token is 'thisis'
            doc1Tokens.forEach (e) ->
                assert.ok e.documents.every (d) ->
                    d.docId isnt 'post-OID2-/-1'
        
        server.once 'docs2', (docs) ->
            assert.ok docs.every (d) ->
                d.docId isnt 'post-OID2-/-1'
        
        server.once 'docCount2', (indexToken) ->
            assert.equal indexToken.documentsCount, 1
            done()
        
    
    test 'find something', (done, server) ->
        
        server.eval () ->
            Spomet.reset()
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', 'post', 1
            e2 = new Spomet.Findable 'harder to find', '/', 'OID2', 'post', 1
            e3 = new Spomet.Findable 'much more harder to find', '/', 'OID3', 'post', 1
            
            Spomet.add e1
            Spomet.add e2
            Spomet.add e3
            
            Spomet.Searches.find().observe
                added: (added) ->
                    emit 'added', added
            
            ret = Spomet.find 'much more eas'
            emit 'returned', ret
            
            results = Spomet.Searches.find({},{sort: [['score','desc']]}).fetch()
            emit 'found', results
            
        server.on 'added', (added) ->
            if added.docId?
                assert.ok added.docId in ['post-OID1-/-1','post-OID3-/-1']
                    
                    
        server.once 'returned', (ret) ->
            assert.ok not ret.cached
        
        server.once 'found', (found) ->
            assert.equal 2, found.length
            assert.equal found[0].docId, 'post-OID3-/-1'
            assert.equal found[0].hits.length, 14
            assert.equal found[1].docId, 'post-OID1-/-1'
            assert.equal found[1].hits.length, 4
            done()
        