resultAddOrUpdate = (phraseHash, docId, hits, score) ->
    cur = Spomet.Search.findOne {phraseHash: phraseHash, docId: docId}
    if cur?
        Spomet.Search.update {_id: cur._id}, {$set: {score: score, hits: hits}}
    else
        doc = Spomet.Documents.collection.findOne {docId: docId}
        res = 
            phraseHash: phraseHash
            docId: docId
            score: score
            type: doc.findable.type
            base: doc.findable.base
            path: doc.findable.path
            version: doc.findable.version
            hits: hits
            queried: new Date()
        Spomet.Search.insert res
    
Spomet.find = (phrase) ->
    phraseHash = CryptoJS.MD5(phrase).toString()
    cur = Spomet.Search.find {phraseHash: phraseHash}
    unless cur.count() is 0
        {phrase: phrase, hash: phraseHash, cached: true}
    else
        Spomet.Index.find phrase, (docId, hits, score) -> 
            #console.log hits
            resultAddOrUpdate phraseHash, docId, hits, score
        {phrase: phrase, hash: phraseHash, cached: false}
        
cleanupSearches = () ->
    Spomet.Search.remove {}
    Spomet.Search._ensureIndex {phraseHash: 1}
    Spomet.Search._ensureIndex {phraseHash: 1, docId: 1}

Spomet.add = (findable, callback) ->
    cleanupSearches()
    Spomet.Index.add findable, callback
    
Spomet.remove = (docId) ->
    cleanupSearches()
    doc = Spomet.Documents.collection.findOne {docId: docId}
    if doc?
        removeTokens = (indexTokens) ->
            result = {}
            indexTokens.forEach (e) ->
                id = e.indexName + e.token
                result[id] = 
                    token: e.token
                    indexName: e.indexName
            _.values result
        
        removeTokens(doc.indexTokens).forEach (rToken) ->
            Spomet.Index.remove docId, rToken.indexName, rToken.token
        
        Spomet.Documents.collection.remove {_id: doc._id}


Spomet.reset = () ->
    cleanupSearches()
    Index.reset()
    
Meteor.methods
    spometFind: (phrase) ->
        Spomet.find phrase
    spometAdd: (findable) ->
        Spomet.add findable
        
Meteor.publish 'common-terms', () ->
    Spomet.CommonTerms.find {},
        sort: 
            documentsCount: -1
            tlength: -1
        fields:
            _id: 1
            token: 1
            documents: 1
            documentsCount: 1
            tlength: 1
        limit: Spomet.options.keyWordsCount
            
    
Meteor.publish 'search-results', (phrase, options) ->
    phraseHash = CryptoJS.MD5(phrase).toString()
    selector = {phraseHash: phraseHash}
    
    opts = {}
    unless options?.sort? 
        opts.sort = {score: -1}
        if options?.offset?
            selector.score = {$lte: options.offset}
    else
        opts.sort[options.sort.sortBy] = options.sort.sortDirection
        if options?.offset?
            if options.sort.sortDirection is -1
                selector[options.sort.sortBy] = {$lte: options.offset}
            else if options.sort.sortDirection is 1
                selector[options.sort.sortBy] = {$gte: options.offset}
            
    unless options?.limit? then opts.limit = Spomet.options.resultsCount
    Spomet.Search.find selector, opts
    