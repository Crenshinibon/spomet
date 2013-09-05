assert = require 'assert'

suite '3Gram', () ->
    test 'tokenize', (done, server) ->
        
        server.eval () ->
            #Spomet.options.indexes = [ThreeGramIndex]
            Spomet.index
            
            tokenizer = new ThreeGramIndex.Tokenizer
            
            'this is some text'.split('').forEach (c, i) ->
                tokenizer.parseCharacter c, i
            emit 'tokens', tokenizer.tokens
            
        server.once 'tokens', (t) ->
            
            console.log t
            done()
    ###        
    test 'normalize', (done, server) ->
        
        server.eval () ->
            a = Spomet.ThreeGramIndex.normalize 'Hier. Kommt ein \\Text mit\n\t    ähnlichen Dingen. ?!; //// ℓ»ÖÜ ſ}()text'
            emit 'normal', a
        
        server.once 'normal', (a) ->
            assert.equal a, 'hier kommt ein text mit hnlichen dingen text'
            done()
                        
    test 'add', (done, server) ->
        
        server.eval () ->
            Spomet.ThreeGramIndex.collection.remove {}
            
            f = new Spomet.Findable 'This is some text to be searched for', '/', 'SOMEID', 1
            Spomet.ThreeGramIndex.add f, (message) ->
                elements = Spomet.ThreeGramIndex.collection.find {term: {$ne: null}}
                emit 'size', elements.count()
                emit 'elements', elements.fetch()
        
        server.once 'size', (i) ->
            assert.ok i > 0
            
        server.once 'elements', (e) ->
            #e.forEach (e) ->
            #    console.log e 
            assert.equal e[1].documents[0].base, 'SOMEID'
            done()
            
    test 'find', (done, server) ->
        
        server.eval () ->
            Spomet.ThreeGramIndex.collection.remove {}
            
            f1 = new Spomet.Findable 'This is some totally different text - with even more text in it.', '/', 'SOMEID1', 1
            f2 = new Spomet.Findable 'I absolutely disagree with you.', '/comments', 'SOMEID2', 1
            f3 = new Spomet.Findable 'I can\'help but pity you. Ex Ex Ex. Te, Te, Te. You shoul pull yourself togther, though.', '/', 'SOMEID2', 1
            f4 = new Spomet.Findable 'This is some text to be searched for', '/title', 'SOMEID3', 1
            
            Spomet.ThreeGramIndex.add f1, () ->
                Spomet.ThreeGramIndex.add f2, () ->
                    Spomet.ThreeGramIndex.add f3, () ->
                        Spomet.ThreeGramIndex.add f4, () ->
                            results = Spomet.ThreeGramIndex.find('ext')
                            emit 'searched', results
            
        server.once 'searched', (r) ->
            assert.equal 3, r.length
            done()
            
    ###
            