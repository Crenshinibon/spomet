@WordGroupIndex =
    name: 'wordgroup'
    layerBoost: 2
    collection: new Meteor.Collection('spomet-wordgroupindex')
    
#This is needed to make it possible to export WordGroupIndex during test
WordGroupIndex = @WordGroupIndex
    
class @WordGroupIndex.Tokenizer
    index: WordGroupIndex
    collection: WordGroupIndex.collection
    
    constructor: () ->
        @tokens = []
        @_currentWord = []
        @_prevWord = []
        @_tokenStartPos = 0
    
    parseCharacter: (c, pos) =>
        
        v = @validCharacter c
        if v?
            #space encountered
            if v.match /\s/
                if @_prevWord.length is 0 and @_currentWord.length > 0
                    @shift(pos)
                else if @_prevWord.length > 0 and @_currentWord.length > 0
                    @tokens.push new Index.Token @index.name, @_prevWord.concat(@_currentWord).join(''), @_tokenStartPos
                    @shift(pos)
            else
                @_currentWord.push v
                        
    finalize: () =>
        if @_prevWord.length isnt 0 and @_currentWord.length isnt 0
            @tokens.push new Index.Token @index.name, @_prevWord.concat(@_currentWord).join(''), @_tokenStartPos
        
    shift: (pos) =>
        @_tokenStartPos = pos - @_currentWord.length 
        @_prevWord = @_currentWord[..]
        @_currentWord = []
    
    validCharacter: (c) =>
        if c?.match /[a-zA-Z'\-äüöÄÜÖ\s\d]/
            c
        else
            null
    
    ###
    find: (phrase) ->
        res = []
        if phrase?
            phrase = @normalize phrase
            tokens = @tokenize phrase, true
            if _.values(tokens).length > 1
                res = @lookupAndRate tokens
        res
            
    lookupAndRate: (tokens) ->
        results = {}
        
        mostCommonTermCountQuery = Spomet.Index.mostCommonTermCount tokens
        meta = @collection.findOne {type: 'meta'}
        if meta?
            for own key, value of tokens
                term = @collection.findOne {term: key}
                #term known?
                if term?
                    documentsCountWithTerm = term.documents.length
                    term.documents.forEach (e) ->
                        score = Spomet.Index.rate(
                            e.currentTermCount, 
                            e.documentLength, 
                            e.mostCommonTermCount, 
                            meta.documentsCount, 
                            documentsCountWithTerm) 
                        score = score * Spomet.WordGroupIndex.layerBoost / Math.log _.values(tokens).length
                        
                        docId = Spomet.documentId e.version, e.base, e.path
                        unless results[docId]?
                            results[docId] = new Spomet.Result e.version, e.base, e.path, score
                        else
                            results[docId].score += score
        _.values results
    
    tokenize: (text, incReverse) ->
        tokens = {}
        
        addToken = (token) ->
            if tokens[token]?
                tokens[token] += 1 
            else
                tokens[token] = 1
        
        words = text.split(' ')
        if words.length > 1
            prev = words[0]
            for i in [1 .. words.length]
                cur = words[i]
                addToken prev + cur
                if incReverse?
                    addToken cur + prev
                prev = cur
        tokens
        
    
    normalize: (text) ->
        text = text.toLowerCase().replace /[^a-z'äüö]/g, ' '
        text = text.replace /\s{2,}/g, ' '
        text.trim()
    
    add: (findable, callback) ->
        iCallback = (message, error) ->
            callback?("Document: #{findable.base}#{findable.path} added to WordGroup index.")
            
        normed = @normalize findable.text
        tokens = @tokenize normed
        
        if _.values(tokens).length > 1
            Spomet.Index.add findable, normed, tokens, @collection, iCallback
        else
            callback?("Document: #{findable.base}#{findable.path} NOT indexed. It contains only one word.")
###