Deps.autorun () ->
    Meteor.subscribe 'documents'
    Meteor.subscribe 'common-terms'

Spomet.add = (findable) ->
    Meteor.call 'spometAdd', findable, () ->
    
Spomet.update = (findable) ->
    Meteor.call 'spometUpdate', findable, () ->
    
Spomet.remove = (findable) ->
    Meteor.call 'spometRemove', findable, () ->

class Spomet.Search
    
    constructor: () ->
        @collection = new Meteor.Collection null
        @subHandle = null
    
    set: (key, value) =>
        upd = {}
        upd[key] = value
        
        sel = {}
        sel[key] = {$exists: true}
        existing = @collection.findOne sel
        if existing?
            @collection.update {_id: existing._id}, upd
        else
            @collection.insert upd
              
    get: (key) =>
        sel = {}
        sel[key] = {$exists: true}
        existing = @collection.findOne sel
        if existing?
            existing[key]
        else
            null
    
    reSubscribe: () =>
        if @subHandle
            @subHandle.stop()
        search = @
        
        Deps.autorun () ->
            search.subHandle = Meteor.subscribe 'search-results', 
                search.get 'current-phrase', 
                search.get 'search-sort',
                search.get 'search-offset',
                search.get 'search-limit'
    
    setCurrentPhrase: (phrase) =>
        @set 'current-phrase', phrase
        @reSubscribe()
        
    getCurrentPhrase: () =>
        @get 'current-phrase'
    
    setSort: (sort) =>
        @set 'search-sort', sort
        @reSubscribe()
        
    getSort: () =>
        @get 'search-sort'
    
    setOffset: (offset) =>
        @set 'search-offset', offset
        @reSubscribe()
        
    getOffset: () =>
        @get 'search-offset'
        
    setLimit: (limit) =>
        @set 'search-limit', limit
        @reSubscribe()
        
    getLimit: () =>
        @get 'search-limit'
        
    setSearching: (searching) =>
        @set 'searching', searching
    
    isSearching: () =>
        @get 'searching'
    
    
    find: (phrase) =>
        if phrase? and phrase.length > 0
            @clearSearch phrase
            @createIntermediaryResults phrase
            
            search = @
            Meteor.call 'spometFind', phrase, () ->
                search.setSearching null
            
    
    clearSearch: (newPhrase) ->
        @set 'searching', if newPhrase then true else null
        @set 'current-phrase', newPhrase
        @set 'search-offset', null
        @set 'search-limit', null
        @reSubscribe()
    
    createIntermediaryResults: (phrase) ->
        words = phrase.split ' '
        cur = Spomet.CommonTerms.find {token: {$in: words}} 
        cur.forEach (e) ->
            e.documents.forEach (d) ->
                doc = Spomet.Documents.collection.findOne {docId: d.docId}
                res = 
                    phraseHash: Spomet.phraseHash phrase
                    docId: d.docId
                    score: 0
                    type: doc.findable.type
                    base: doc.findable.base
                    path: doc.findable.path
                    version: doc.findable.version
                    hits: []
                    queried: new Date()
                    interim: true
                Spomet.Searches.insert res

    results: () ->
        phrase = @getCurrentPhrase()
        if phrase?
            [selector, opts] = Spomet.buildSearchQuery phrase, 
                @getSort(), 
                @getOffset(), 
                @getLimit()
                
            Spomet.Searches.find selector, opts

