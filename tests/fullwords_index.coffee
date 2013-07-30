assert = require 'assert'

suite 'FullWords', () ->
    test 'tokenize', (done, server) ->
        
        server.eval () ->
            a = Spomet.FullWordIndex.tokenize 'das ist ein kleiner text ein kleiner text'
            emit 'tokens', a
        
        server.once 'tokens', (t) ->
            assert.equal t['das'], 1
            assert.equal t['ist'], 1
            assert.equal t['ein'], 2
            assert.equal t['kleiner'], 2
            assert.equal t['text'],2
            done()
            
    test 'normalize', (done, server) ->
        
        server.eval () ->
            a = Spomet.FullWordIndex.normalize 'Hier. Kommt ein \\Text mit\n\t    ähnlichen Dingen. ?!; //// ℓ»ÖÜ ſ}()text'
            emit 'normal', a
        
        server.once 'normal', (a) ->
            assert.equal a, 'hier kommt ein text mit ähnlichen dingen öü text'
            done()
                        
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
            
        
            