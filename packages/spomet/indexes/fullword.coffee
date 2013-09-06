@FullWordIndex =
    name: 'fullword'
    layerBoost: 1.0
    collection: new Meteor.Collection('spomet-fullwordindex')        

#This is needed to make it possible to export FullWordIndex during test
FullWordIndex = @FullWordIndex

class @FullWordIndex.Tokenizer
    index: FullWordIndex
    collection: FullWordIndex.collection
    
    constructor: () ->
        @_tokenStarted = false
        @_currentToken = []
        @_currentTokenPos = 0
        @tokens = []

    parseCharacter: (c, pos) =>
        v = @validCharacter c
        if v?
            unless @_tokenStarted
                @_currentTokenPos = pos
        
            @_tokenStarted = true
            @_currentToken.push v
        else
            if @_tokenStarted
                @tokens.push new Index.Token @index.name, @_currentToken.join(''), @_currentTokenPos
                
                @_tokenStarted = false
                @_currentToken = []
    
    finalize: () =>
        unless @_currentToken.length is 0
            @tokens.push new Index.Token @index.name, @_currentToken.join(''), @_currentTokenPos
    
    validCharacter: (c) =>
        if c?.match /[a-zA-Z'\-äüöÄÜÖß\d]/
            c
        else
            null


###
    find: (phrase) ->
        res = []
        if phrase?
            phrase = @normalize phrase
            tokens = @tokenize phrase
            res = @lookupAndRate tokens
        res
    
    lookupAndRate: (tokens) ->
        results = {}
    
        mostCommonTermCountQuery = Spomet.Index.mostCommonTermCount tokens
        meta = @collection.findOne {type: 'meta'}
        if meta?
            for own key, value of tokens
                term = @collection.findOne {term: key}
                if term?
                    documentsCountWithTerm = term.documents.length
                    term.documents.forEach (e) ->
                        score = Index.rate(
                            e.currentTermCount, 
                            e.documentLength, 
                            e.mostCommonTermCount, 
                            meta.documentsCount, 
                            documentsCountWithTerm) 
                        score = score * Spomet.FullWordIndex.layerBoost / _.values(tokens).length * value / mostCommonTermCountQuery
                    
                        unless results[docId]?
                            results[docId] = 
                                version: e.version, 
                                base: e.base, 
                                path: e.path,
                                type: e.type, 
                                score: score
                        else
                            results[docId].score += score
        _.values results
###
    