assert = require 'assert'

suite 'FullWords', () ->
    test 'tokenize', (done, server) ->
        assertElement = (tokens, i, indexName, token, pos) ->
            assert.equal tokens[i].indexName, indexName
            assert.equal tokens[i].token, token
            assert.equal tokens[i].pos, pos
        
        server.eval () ->
            tokenizer = new Spomet.FullWordIndex.Tokenizer 
            
            'das ist ein kleiner text ein kleiner text'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            
            emit 'tokens', tokenizer.tokens
        
        server.once 'tokens', (t) ->
            assert.equal t.length, 8
            assertElement t, 0, 'fullword', 'das', 0
            assertElement t, 1, 'fullword', 'ist', 4
            assertElement t, 2, 'fullword', 'ein', 8
            assertElement t, 3, 'fullword', 'kleiner', 12
            assertElement t, 4, 'fullword', 'text', 20
            assertElement t, 5, 'fullword', 'ein', 25
            assertElement t, 6, 'fullword', 'kleiner', 29
            assertElement t, 7, 'fullword', 'text', 37
        
        #edge cases
        server.eval () ->
            tokenizer = new Spomet.FullWordIndex.Tokenizer
            #empty
            tokenizer.finalize()
            emit 'tokens1', tokenizer.tokens
            
            tokenizer = new Spomet.FullWordIndex.Tokenizer
            #multiple spaces
            ' small  text    rules '.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens2', tokenizer.tokens
            
        
        server.once 'tokens1', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens2', (t) ->
            assert.equal t.length, 3
            assertElement t, 0, 'fullword', 'small', 1
            assertElement t, 1, 'fullword', 'text', 8
            assertElement t, 2, 'fullword', 'rules', 16
            done()
    
    ###                    
    test 'add', (done, server) ->
        
        server.eval () ->
            Spomet.FullWordIndex.collection.remove {}
            
            f = new Spomet.Findable 'This is some text to be searched for', '/', 'SOMEID', 1
            Spomet.FullWordIndex.add f, (message) ->
                elements = Spomet.FullWordIndex.collection.find {term: {$ne: null}}
                emit 'message', message
                emit 'size', elements.count()
                emit 'elements', elements.fetch()
        
        server.once 'message', (m) ->
            console.log m
        
        server.once 'size', (i) ->
            assert.ok i > 0
            
        server.once 'elements', (e) ->
            assert.equal e[1].documents[0].base, 'SOMEID'
            done()
            
    test 'find', (done, server) ->
        
        server.eval () ->
            Spomet.FullWordIndex.collection.remove {}
            
            f1 = new Spomet.Findable 'This is some totally different text - with even more text text in it.', '/', 'SOMEID1', 1
            f2 = new Spomet.Findable 'I absolutely disagree with you.', '/comments', 'SOMEID2', 1
            f3 = new Spomet.Findable 'I can\'t help but pity you. Ex Ex Ex. Te, Te, Te. You shoul pull yourself togther, though.', '/', 'SOMEID2', 1
            f4 = new Spomet.Findable 'This is some text to be searched for', '/title', 'SOMEID3', 1
            
            Spomet.FullWordIndex.add f1, () ->
                emit 'f1added', Spomet.FullWordIndex.collection.find({term: {$ne: null}}).fetch()
                Spomet.FullWordIndex.add f2, () ->
                    emit 'f2added', Spomet.FullWordIndex.collection.find({term: {$ne: null}}).fetch()
                    Spomet.FullWordIndex.add f3, () ->
                        emit 'f3added', Spomet.FullWordIndex.collection.find({term: {$ne: null}}).fetch()
                        Spomet.FullWordIndex.add f4, () ->
                            emit 'f4added', Spomet.FullWordIndex.collection.find({term: {$ne: null}}).fetch()
                            
                            emit 'meta', Spomet.FullWordIndex.collection.findOne({type: 'meta'})
                            results = Spomet.FullWordIndex.find('ext')
                            emit 'searched1', results
            
                            results = Spomet.FullWordIndex.find('text')
                            emit 'searched2', results
        
        server.once 'meta', (r) ->
            #console.log r
            assert.equal 4, r.documentsCount
            
        server.once 'f1added', (r) ->
            #console.log r
            assert.equal 12, r.length
        
        server.once 'f2added', (r) ->
            #console.log r
            assert.equal 16, r.length
        
        server.once 'f3added', (r) ->
            #console.log r
            assert.equal 27, r.length
        
        server.once 'f4added', (r) ->
            #console.log r
            assert.equal 31, r.length        
        
        server.once 'searched1', (r) ->
            assert.equal 0, r.length
            
        server.once 'searched2', (r) ->
            #console.log r
            assert.equal 2, r.length
            done()
            
        ###
            