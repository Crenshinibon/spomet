assert = require 'assert'

suite '3Gram', () ->
    
    test 'tokenize', (done, server) ->
        
        assertToken = (tokens, i, indexName, token, pos) ->
            assert.equal tokens[i].indexName, indexName
            assert.equal tokens[i].token, token
            assert.equal tokens[i].pos, pos
        
        
        server.eval () ->
            tokenizer = new Spomet.ThreeGramIndex.Tokenizer
            
            'this is some text'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            
            emit 'tokens', tokenizer.tokens
            
        server.once 'tokens', (t) ->
            assert.equal t.length, 17
            
            assertToken t, 0, 'threegram', ' th', 0
            assertToken t, 1, 'threegram', 'thi', 1
            assertToken t, 2, 'threegram', 'his', 2
            assertToken t, 3, 'threegram', 'is ', 3
            assertToken t, 4, 'threegram', 's i', 4
            assertToken t, 5, 'threegram', ' is', 5
            assertToken t, 6, 'threegram', 'is ', 6
            assertToken t, 7, 'threegram', 's s', 7
            assertToken t, 8, 'threegram', ' so', 8
            assertToken t, 9, 'threegram', 'som', 9
            assertToken t, 10, 'threegram', 'ome', 10
            assertToken t, 11, 'threegram', 'me ', 11
            assertToken t, 12, 'threegram', 'e t', 12
            assertToken t, 13, 'threegram', ' te', 13
            assertToken t, 14, 'threegram', 'tex', 14
            assertToken t, 15, 'threegram', 'ext', 15
            assertToken t, 16, 'threegram', 'xt ', 16
            
        #edge cases
        server.eval () ->
            tokenizer = new Spomet.ThreeGramIndex.Tokenizer
            #empty
            tokenizer.finalize()
            emit 'tokens1', tokenizer.tokens
            
            tokenizer = new Spomet.ThreeGramIndex.Tokenizer
            #one letter
            tokenizer.parseCharacter 'c', 0
            tokenizer.finalize()
            emit 'tokens2', tokenizer.tokens
            
            tokenizer = new Spomet.ThreeGramIndex.Tokenizer
            #two letters
            tokenizer.parseCharacter 'g', 0
            tokenizer.parseCharacter 'o', 1
            tokenizer.finalize()
            emit 'tokens3', tokenizer.tokens
            
            tokenizer = new Spomet.ThreeGramIndex.Tokenizer
            #one space
            tokenizer.parseCharacter ' ', 0
            tokenizer.finalize()
            emit 'tokens4', tokenizer.tokens
            
            tokenizer = new Spomet.ThreeGramIndex.Tokenizer
            #multiple spaces
            ' ab  die   post'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            tokenizer.finalize()
            emit 'tokens5', tokenizer.tokens
            
        server.once 'tokens1', (t) ->
            assert.equal t.length, 0
            
        server.once 'tokens2', (t) ->
            assert.equal t.length, 1
            assertToken t, 0, 'threegram', ' c ', 0 
        
        server.once 'tokens3', (t) ->
            assert.equal t.length, 2
            assertToken t, 0, 'threegram', ' go', 0 
            assertToken t, 1, 'threegram', 'go ', 1 
        
        server.once 'tokens4', (t) ->
            assert.equal t.length, 1
            assertToken t, 0, 'threegram', '   ', 0 
        
        server.once 'tokens5', (t) ->
            assert.equal t.length, 15
            assertToken t, 0, 'threegram', '  a', 0
            assertToken t, 1, 'threegram', ' ab', 1
            assertToken t, 2, 'threegram', 'ab ', 2
            assertToken t, 3, 'threegram', 'b  ', 3
            assertToken t, 4, 'threegram', '  d', 4
            assertToken t, 5, 'threegram', ' di', 5
            assertToken t, 6, 'threegram', 'die', 6
            assertToken t, 7, 'threegram', 'ie ', 7
            assertToken t, 8, 'threegram', 'e  ', 8
            assertToken t, 9, 'threegram', '   ', 9
            assertToken t, 10, 'threegram', '  p', 10
            assertToken t, 11, 'threegram', ' po', 11
            assertToken t, 12, 'threegram', 'pos', 12
            assertToken t, 13, 'threegram', 'ost', 13
            assertToken t, 14, 'threegram', 'st ', 14
            
            done()
