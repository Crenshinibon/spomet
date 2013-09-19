assert = require 'assert'

suite 'Custom', () ->
    
    test 'tokenize', (done, server) ->
        
        assertToken = (tokens, i, indexName, token, pos) ->
            assert.equal tokens[i].indexName, indexName
            assert.equal tokens[i].token, token
            assert.equal tokens[i].pos, pos
        
        
        server.eval () ->
            tokenizer = new Spomet.CustomIndex.Tokenizer
            
            'this is some text'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            
            emit 'tokens', tokenizer.tokens
            
        server.once 'tokens', (t) ->
            assert.equal t.length, 3
            
            assertToken t, 0, 'custom', 'thi', 0
            assertToken t, 1, 'custom', 'som', 8
            assertToken t, 2, 'custom', 'tex', 13
            
        #edge cases
        server.eval () ->
            tokenizer = new Spomet.CustomIndex.Tokenizer
            #empty
            tokenizer.finalize()
            emit 'tokens1', tokenizer.tokens
            
            tokenizer = new Spomet.CustomIndex.Tokenizer
            #one letter
            tokenizer.parseCharacter 'c', 0
            tokenizer.finalize()
            emit 'tokens2', tokenizer.tokens
            
            tokenizer = new Spomet.CustomIndex.Tokenizer
            #two letters
            tokenizer.parseCharacter 'g', 0
            tokenizer.parseCharacter 'o', 1
            tokenizer.finalize()
            emit 'tokens3', tokenizer.tokens
            
            tokenizer = new Spomet.CustomIndex.Tokenizer
            #three letters
            tokenizer.parseCharacter 'g', 0
            tokenizer.parseCharacter 'o', 1
            tokenizer.parseCharacter 'o', 2
            tokenizer.finalize()
            emit 'tokens3a', tokenizer.tokens
            
            
            tokenizer = new Spomet.CustomIndex.Tokenizer
            #one space
            tokenizer.parseCharacter ' ', 0
            tokenizer.finalize()
            emit 'tokens4', tokenizer.tokens
            
            tokenizer = new Spomet.CustomIndex.Tokenizer
            #multiple spaces
            ' ab  die   post'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens5', tokenizer.tokens
            
        server.once 'tokens1', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens2', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens3', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens3a', (t) ->
            assert.equal t.length, 1
            assertToken t, 0, 'custom', 'goo', 0
            
        server.once 'tokens4', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens5', (t) ->
            assert.equal t.length, 2
            assertToken t, 0, 'custom', 'die', 5
            assertToken t, 1, 'custom', 'pos', 11
            done()