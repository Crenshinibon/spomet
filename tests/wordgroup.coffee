assert = require 'assert'

suite 'WordGroup', () ->
    
    test 'tokenize', (done, server) ->
        assertToken = (tokens, i, indexName, token, pos) ->
            assert.equal tokens[i].indexName, indexName
            assert.equal tokens[i].token, token
            assert.equal tokens[i].pos, pos
        
        server.eval () ->
            tokenizer = new WordGroupIndex.Tokenizer
            
            'das ist ein kleiner text'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            
            emit 'tokens1', tokenizer.tokens
        
        server.once 'tokens1', (t) ->
            #console.log t
            
            assertToken t, 0, 'wordgroup', 'dasist', 0
            assertToken t, 1, 'wordgroup', 'istein', 4
            assertToken t, 2, 'wordgroup', 'einkleiner', 8
            assertToken t, 3, 'wordgroup', 'kleinertext', 12
            assert.equal t.length, 4
            
        #edge cases
        server.eval () ->
            tokenizer = new Spomet.WordGroupIndex.Tokenizer
            #no text
            tokenizer.finalize()
            emit 'tokens2', tokenizer.tokens
            
            tokenizer = new Spomet.WordGroupIndex.Tokenizer
            #one word
            'oneword'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens3', tokenizer.tokens
            
            tokenizer = new Spomet.WordGroupIndex.Tokenizer
            #leading space
            ' two words'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens4', tokenizer.tokens
            
            tokenizer = new Spomet.WordGroupIndex.Tokenizer
            #trailing space
            'two words '.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens5', tokenizer.tokens
            
            tokenizer = new Spomet.WordGroupIndex.Tokenizer
            #multiple spaces
            '  three   cool    words  '.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens6', tokenizer.tokens
            
        
        server.once 'tokens2', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens3', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens4', (t) ->
            assert.equal t.length, 1
            assertToken t, 0, 'wordgroup', 'twowords', 1
        
        server.once 'tokens5', (t) ->
            assert.equal t.length, 1
            assertToken t, 0, 'wordgroup', 'twowords', 0
            
        server.once 'tokens6', (t) ->
            assert.equal t.length, 2
            assertToken t, 0, 'wordgroup', 'threecool', 2
            assertToken t, 1, 'wordgroup', 'coolwords', 10
            done()
            
            
        
    ###    
    test 'add', (done, server) ->
        
        server.eval () ->
            Spomet.WordGroupIndex.collection.remove {}
            
            f = new Spomet.Findable 'This is some text to be searched for', '/', 'SOMEID', 1
            Spomet.WordGroupIndex.add f, (message) ->
                elements = Spomet.WordGroupIndex.collection.find {term: {$ne: null}}
                emit 'size', elements.count()
                emit 'message', message
                emit 'elements', elements.fetch()
        
        server.once 'message', (m) ->
            console.log m
        
        server.once 'size', (i) ->
            assert.ok i > 0
            
        server.once 'elements', (e) ->
            #e.forEach (e) ->
            #    console.log e 
            assert.equal e[1].documents[0].base, 'SOMEID'
            done()
            
    test 'find', (done, server) ->
        
        server.eval () ->
            Spomet.WordGroupIndex.collection.remove {}
            
            f1 = new Spomet.Findable 'This is some totally different text - with even more text in it.', '/', 'SOMEID1', 1
            f2 = new Spomet.Findable 'I absolutely disagree with you.', '/comments', 'SOMEID2', 1
            f3 = new Spomet.Findable 'I can\'help but pity you. Ex Ex Ex. Te, Te, Te. You shoul pull yourself togther, though.', '/', 'SOMEID2', 1
            f4 = new Spomet.Findable 'This is some text to be searched for', '/title', 'SOMEID3', 1
            
            Spomet.WordGroupIndex.add f1, () ->
                Spomet.WordGroupIndex.add f2, () ->
                    Spomet.WordGroupIndex.add f3, () ->
                        Spomet.WordGroupIndex.add f4, () ->
                            emit 'toshort', Spomet.WordGroupIndex.find('ext')
                            emit 'found', Spomet.WordGroupIndex.find('some is to be')
            
        server.once 'toshort', (r) ->
            assert.equal 0, r.length
            
        server.once 'found', (r) ->
            #console.log r
            assert.equal 2, r.length
            done()
    ###
            