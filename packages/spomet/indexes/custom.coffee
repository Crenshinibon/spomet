@CustomIndex =
    name: 'custom'
    indexBoost: 0.9
    collection: new Meteor.Collection('spomet-customindex')
    
Spomet.CustomIndex = @CustomIndex
Spomet.options.indexes.push @CustomIndex

Meteor.methods
    disableCustomIndex: () ->
        i = Spomet.options.indexes.indexOf CustomIndex
        if i isnt -1 then Spomet.options.indexes.splice i, 1
    enableCustomIndex: () ->
        Spomet.options.indexes.push CustomIndex

class @CustomIndex.Tokenizer
    indexName: CustomIndex.name
    index: CustomIndex
    collection: CustomIndex.collection
    indexBoost: CustomIndex.indexBoost
    tokenLength: 3
    
    constructor: () ->
        @_currentToken = []
        @_latestPos = 0
        @tokens = []
    
    parseCharacter: (c, pos) =>
        v = @validCharacter c
        if v?
            space = v.match /\s/
            if @_currentToken.length is 0 and not space
                @_latestPos = pos
            
            if @_currentToken.length < @tokenLength
                if space
                    @_currentToken = []
                else
                    @_currentToken.push v
                    
            if @_currentToken.length is @tokenLength
                @tokens.push 
                    indexName: @indexName
                    token: @_currentToken.join ''
                    tlength: @tokenLength
                    pos: @_latestPos
                @_currentToken = []
                
                
    finalize: () =>
        
    
    validCharacter: (c) =>
        v = c.toLowerCase()
        if v?.match /[a-z'\-äüö\d\s]/
            v
        else
            null

