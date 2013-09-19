@ThreeGramIndex =
    name: 'threegram'
    indexBoost: 0.3
    collection: new Meteor.Collection('spomet-threegramindex')
    
Spomet.ThreeGramIndex = @ThreeGramIndex
Spomet.options.indexes.push @ThreeGramIndex

Meteor.methods
    disableThreeGramIndex: () ->
        i = Spomet.options.indexes.indexOf ThreeGramIndex
        if i isnt -1 then Spomet.options.indexes.splice i, 1
    enableThreeGramIndex: () ->
        Spomet.options.indexes.push ThreeGramIndex

class @ThreeGramIndex.Tokenizer
    indexName: ThreeGramIndex.name
    index: ThreeGramIndex
    collection: ThreeGramIndex.collection
    indexBoost: ThreeGramIndex.indexBoost
    
    constructor: () ->
        @_currentToken = []
        @_first = true
        @_latestPos = 0
        @tokens = []
    
    parseCharacter: (c, pos) =>
        v = @validCharacter c
        if @_first
            @_currentToken.push ' '
            @_first = false
            
        if v?
            @_currentToken.push v
            if pos > 0
                @tokens.push 
                    indexName: @index.name
                    token: @_currentToken.join ''
                    tlength: @_currentToken.length
                    pos: pos - 1
                @_currentToken = @_currentToken[1..]
            
            @_latestPos = pos
                
    finalize: () =>
        unless @_currentToken.length < 2
            @_currentToken.push ' '
            @tokens.push 
                indexName: @index.name
                token: @_currentToken.join ''
                tlength: @_currentToken.length
                pos: @_latestPos
            
    
    validCharacter: (c) =>
        v = c.toLowerCase()
        if v?.match /[a-z'\-äüö\s\d]/
            v
        else
            null

