createSearchDoc = (phraseHash, docId) ->
    if Spomet.Search.find({phraseHash: phraseHash, docId: docId}).count() is 0
        doc = Spomet.Documents.collection.findOne {docId: docId}
        res = 
            phraseHash: phraseHash
            docId: docId
            score: 0
            type: doc.findable.type
            base: doc.findable.base
            path: doc.findable.path
            version: doc.findable.version
            hits: []
            queried: new Date()
            interim: false
        Spomet.Search.insert res

updateSearchDoc = (phraseHash, docId, hits, score) ->
    cur = Spomet.Search.findOne {phraseHash: phraseHash, docId: docId}
    Spomet.Search.update {_id: cur._id}, {$set: {score: score, hits: hits, interim: false}}
    
Spomet.find = (phrase) ->
    phraseHash = Spomet.phraseHash(phrase)
    cur = Spomet.Search.find {phraseHash: phraseHash, interim: false}
    unless cur.count() is 0
        {phrase: phrase, hash: phraseHash, cached: true}
    else
        Spomet.Index.find phrase, (docId, hits, score) -> 
            createSearchDoc phraseHash, docId
            updateSearchDoc phraseHash, docId, hits, score
        {phrase: phrase, hash: phraseHash, cached: false}
        
cleanupSearches = () ->
    #
    # it might become necessary to keep searches a little bit longer
    # removing searches and executing searches might interfere with
    # each other, which might result in poor user experience
    #
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

Meteor.publish 'documents', () ->
    Spomet.Documents.collection.find {},
        fields:
            _id: 1
            docId: 1
            'findable.type': 1
            'findable.base': 1
            'findable.path': 1
            'findable.version': 1

#should be extended
stopWords = ['there','this','that','them','then','and','the','any','all','other','und','ich','wir','sie','als']
Meteor.publish 'common-terms', () ->
    Spomet.CommonTerms.find {tlength: {$gt: 2}, token: {$nin: stopWords}},
        sort: 
            documentsCount: -1
            tlength: -1
        fields:
            _id: 1
            token: 1
            documents: 1
            documentsCount: 1
            tlength: 1
        limit: Spomet.options.keywordsCount
            
    
Meteor.publish 'search-results', (phrase, sort, offset, limit) ->
    if phrase?
        [selector, opts] = Spomet.buildSearchQuery phrase, sort, offset, limit
        Spomet.Search.find selector, opts