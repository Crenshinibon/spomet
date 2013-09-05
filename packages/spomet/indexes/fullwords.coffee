@FullWordIndex =
    name: 'fullword'
    layerBoost: 1.0
    collection: new Meteor.Collection('spomet-fullwordindex')        

#This is needed to make it possible to export WordGroupIndex during test
FullWordIndex = @FullWordIndex

class @FullWordIndex.Tokenizer
    tokens: {}
    index: FullWordIndex
    collection: FullWordIndex.collection
    
    _tokenStarted: false
    _currentToken: []
    _currentTokenPos: 0

    parseCharacter: (c, pos) =>
        v = @validateCharacter c
        if v?
            unless @_tokenStarted
                @_currentTokenPos = pos
        
            @_tokenStarted = true
            @_currentToken.push v
        else
            if @_tokenStarted
                @tokens[@_currentToken.join ''] = @_currentTokenPos
            
                @_tokenStarted = false
                @_currentToken = []
        
    
    validateCharacter: (c) =>
        v = c?.toLowerCase()
        if v?.match /[a-z'\-äüö\d]/
            v
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
    