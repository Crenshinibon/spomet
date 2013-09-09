@ThreeGramIndex =
    name: 'threegram'
    layerBoost: 0.8
    collection: new Meteor.Collection('spomet-threegramindex')

if Meteor.isServer
    Spomet.ThreeGramIndex = @ThreeGramIndex

class @ThreeGramIndex.Tokenizer
    index: ThreeGramIndex
    collection: ThreeGramIndex.collection
    
    constructor: () ->
        @_currentToken = []
        @_first = true
        @_latestPos = 0
        @tokens = []
    
    tokenize: (text) ->
        text.split('').forEach (c, i) ->
            @parseCharacter c, i
        @finalize()
    
    parseCharacter: (c, pos) =>
        v = @validCharacter c
        if @_first
            @_currentToken.push ' '
            @_first = false
            
        if v?
            @_currentToken.push v
            if pos > 0
                @tokens.push new Index.Token @index.name, @_currentToken.join(''), pos - 1
                @_currentToken = @_currentToken[1..]
            
            @_latestPos = pos
                
    finalize: () =>
        unless @_currentToken.length < 2
            @_currentToken.push ' '
            @tokens.push new Index.Token @index.name, @_currentToken.join(''), @_latestPos
        
    
    validCharacter: (c) =>
        if c?.match /[a-zA-Z'\-äüöÄÜÖ\s\d]/
            c
        else
            null

@ThreeGramIndex.find = (phrase) ->
    found = {}
    
    tokenizer = new ThreeGramIndex.Tokenizer
    tokenizer.tokenize phrase
    
    tokenizer.tokens.forEach (token) ->
        @collection.find({token: token}).forEach (t) ->
            if found[t.docId]
                found[t.docId].push token
            else
                found[t.docId] = [token]
    
###
    find: (phrase) ->
        res = []
        if phrase?
            phrase = @normalize phrase
            tokens = @tokenize phrase
            res = @lookupAndRate tokens, phrase
        res
        
    lookupAndRate: (tokens, phrase) ->
        results = {}
        
        mostCommonTermCountQuery = Spomet.Index.mostCommonTermCount tokens
        meta = @collection.findOne {type: 'meta'}
        if meta?
            for own key, value of tokens
                term = @collection.findOne {term: key}
                if term?
                    documentsCountWithTerm = term.documents.length
                    term.documents.forEach (e) ->
                        score = Spomet.Index.rate(
                            e.currentTermCount, 
                            e.documentLength, 
                            e.mostCommonTermCount, 
                            meta.documentsCount, 
                            documentsCountWithTerm) 
                        score = score * Spomet.ThreeGramIndex.layerBoost / phrase.length * value / mostCommonTermCountQuery
                        
                        docId = Spomet.documentId e.version, e.base, e.path            
                        unless results[docId]?
                            results[docId] = new Spomet.Result e.version, e.base, e.path, score
                        else
                            results[docId].score += score
                            
        _.values results
    
    tokenize: (text) ->
        text = " #{text} "
        tokens = {}
        
        #iterate over every character
        current = []
        for i in [0 .. text.length]
            l = text[i]
            if (i >= 3)
                ng = current.join ''
                if tokens[ng]?
                    tokens[ng] = tokens[ng] + 1
                else
                    tokens[ng] = 1
                
                current = current[1..]
                current.push l
            else
                current.push l
            
        tokens
        
    
    normalize: (text) ->
        text = text.toLowerCase().replace /[^a-z]/g, ' '
        text = text.replace /\s{2,}/g, ' '
        text.trim()

    add: (findable, callback) ->
        iCallback = (message, error) ->
            callback?("Document: #{findable.base}#{findable.path} added to 3Gram index.")
        
        normed = @normalize findable.text
        tokens = @tokenize normed
        Spomet.Index.add findable, normed, tokens, @collection, iCallback
            
###
