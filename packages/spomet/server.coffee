Spomet.Search = new Meteor.Collection 'spomet-search'

resultAddOrUpdate = (phraseHash, docId, hits, score) ->
    cur = Spomet.Search.findOne {phraseHash: phraseHash, docId: docId}
    if cur?
        Spomet.Search.update {_id: cur._id}, {score: score, hits: hits}
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


Meteor.publish 'search-results', (phrase) ->
    opts = {sort: [['score','desc']], limit: Spomet.options.resultsCount}
    phraseHash = CryptoJS.MD5(phrase).toString()
    Spomet.Search.find {phraseHash: phraseHash}, opts
    
Meteor.publish 'common-terms', () ->
    opts = {sort: [['docsCount','desc']], limit: Spomet.options.keywordsCount}
    Spomet.FullWordIndex.collection.find {}, opts
    
    