assert = require 'assert'

suite 'WordGroup', () ->
    test 'tokenize', (done, server) ->
        
        server.eval () ->
            a = Spomet.WordGroupIndex.tokenize 'das ist ein kleiner text', true
            emit 'tokens1', a
        
        server.once 'tokens1', (t) ->
            assert.equal t['dasist'], 1
            assert.equal t['istdas'], 1
            assert.equal t['istein'], 1
            assert.equal t['einist'], 1
            assert.equal t['einkleiner'], 1
            assert.equal t['kleinerein'], 1
            assert.equal t['kleinertext'], 1
            assert.equal t['textkleiner'], 1
            
        server.eval () ->
            a = Spomet.WordGroupIndex.tokenize 'das ist ein kleiner text'
            emit 'tokens2', a
        
        server.once 'tokens2', (t) ->
            assert.equal t['dasist'], 1
            assert.ok not t['istdas']?
            assert.equal t['istein'], 1
            assert.ok not t['einist']?
            assert.equal t['einkleiner'], 1
            assert.ok not t['kleinerein']?
            assert.equal t['kleinertext'], 1
            assert.ok not t['textkleiner']?
            done()
            
    test 'normalize', (done, server) ->
        
        server.eval () ->
            a = Spomet.WordGroupIndex.normalize 'Hier. Kommt ein \\Text mit\n\t    ähnlichen Dingen. ?!; //// ℓ»ÖÜ ſ}()text'
            emit 'normal', a
        
        server.once 'normal', (a) ->
            assert.equal a, 'hier kommt ein text mit ähnlichen dingen öü text'
            done()
        
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
            