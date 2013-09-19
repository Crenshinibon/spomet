@WordGroupIndex =
    name: 'wordgroup'
    indexBoost: 2
    collection: new Meteor.Collection('spomet-wordgroupindex')
    
Spomet.WordGroupIndex = @WordGroupIndex
Spomet.options.indexes.push @WordGroupIndex

Meteor.methods
    disableWordGroupIndex: () ->
        i = Spomet.options.indexes.indexOf WordGroupIndex
        if i isnt -1 then Spomet.options.indexes.splice i, 1
    enableWordGroupIndex: () ->
        Spomet.options.indexes.push WordGroupIndex
        
class @WordGroupIndex.Tokenizer
    indexName: WordGroupIndex.name
    index: WordGroupIndex
    collection: WordGroupIndex.collection
    indexBoost: WordGroupIndex.indexBoost
    
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
                    token = @_prevWord.concat(@_currentWord).join ''
                    @tokens.push 
                        indexName: @index.name
                        token: token
                        tlength: token.length
                        pos: @_tokenStartPos
                    @shift(pos)
            else
                @_currentWord.push v
                        
    finalize: () =>
        if @_prevWord.length isnt 0 and @_currentWord.length isnt 0
            token =  @_prevWord.concat(@_currentWord).join ''
            @tokens.push 
                indexName: @index.name
                token: token
                tlength: token.length
                pos: @_tokenStartPos
        
    shift: (pos) =>
        @_tokenStartPos = pos - @_currentWord.length 
        @_prevWord = @_currentWord[..]
        @_currentWord = []
    
    validCharacter: (c) =>
        v = c.toLowerCase()
        if v?.match /[a-z'\-äüö\s\d]/
            v
        else
            null
    