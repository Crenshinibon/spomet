@FullWordIndex =
    name: 'fullword'
    indexBoost: 1.0
    collection: Spomet.CommonTerms

Spomet.FullWordIndex = @FullWordIndex
Spomet.options.indexes.push @FullWordIndex

Meteor.methods
    disableFullWordIndex: () ->
        i = Spomet.options.indexes.indexOf FullWordIndex
        if i isnt -1 then Spomet.options.indexes.splice i, 1
    enableFullWordIndex: () ->
        Spomet.options.indexes.push FullWordIndex

class @FullWordIndex.Tokenizer
    indexName: FullWordIndex.name
    index: FullWordIndex
    collection: FullWordIndex.collection
    indexBoost: FullWordIndex.indexBoost
    
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
                @tokens.push 
                    indexName: @index.name
                    token: @_currentToken.join ''
                    tlength: @_currentToken.length
                    pos: @_currentTokenPos
                
                @_tokenStarted = false
                @_currentToken = []
    
    finalize: () =>
        unless @_currentToken.length is 0
            @tokens.push 
                indexName: @index.name
                token: @_currentToken.join ''
                tlength: @_currentToken.length
                pos: @_currentTokenPos
            
    validCharacter: (c) =>
        if c?.match /[a-zA-Z'\-äüöÄÜÖß\d]/
            c
        else
            null

    