createSearchDoc = (phraseHash, doc) ->
    current = Spomet.Searches.findOne
        phraseHash: phraseHash
        base: doc.findable.base
        type: doc.findable.type
        version: doc.findable.version
    
    if current?
        current
    else
        res = 
            phraseHash: phraseHash
            score: 0
            type: doc.findable.type
            base: doc.findable.base
            version: doc.findable.version
            subDocs: {}
            queried: new Date()
            interim: false
        id = Spomet.Searches.insert res
        Spomet.Searches.findOne {_id: id}

updateSearchDoc = (current, phraseHash, doc, hits, score) ->
    subDocs = current.subDocs
    
    subDocs[doc.findable.path] =
        docId: doc.docId
        path: doc.findable.path
        hits: hits
        score: score
        
    scoreSum = _.values(subDocs).reduce ((s, e) -> s + e.score), 0
    
    Spomet.Searches.update {_id: current._id}, 
        $set: 
            score: scoreSum
            subDocs: subDocs
            interim: false
    
Spomet.find = (phrase, options) ->
    phraseHash = Spomet.phraseHash phrase
    cur = Spomet.Searches.find {phraseHash: phraseHash, interim: false}
    unless cur.count() is 0
        Spomet.Searches.remove {phraseHash: phraseHash, interim: true}
        {phrase: phrase, hash: phraseHash, cached: true}
    else
        docs = {}
        findCallback = (docId, hits, score) ->
            unless docs[docId]?
                docs[docId] = Spomet.Documents.collection.findOne {docId: docId}
            
            current = createSearchDoc phraseHash, docs[docId]
            updateSearchDoc current, phraseHash, docs[docId], hits, score
            
        Spomet.Index.find phrase, findCallback, options
        {phrase: phrase, hash: phraseHash, cached: false}
        
cleanupSearches = () ->
    #
    # it might become necessary to keep searches a little bit longer
    # removing searches and executing searches might interfere with
    # each other, which might result in poor user experience
    #
    Spomet.Searches.remove {}
    Spomet.Searches._ensureIndex {phraseHash: 1}
    Spomet.Searches._ensureIndex {phraseHash: 1, base: 1, type: 1, version: 1}
    
Spomet.add = (findable, callback) ->
    cleanupSearches()
    Spomet.Index.add findable, callback
 
 
removeTokens = (indexTokens) ->
    result = {}
    indexTokens.forEach (e) ->
        id = e.indexName + e.token
        result[id] = 
            token: e.token
            indexName: e.indexName
    _.values result
               
Spomet.remove = (docId) ->
    cleanupSearches()
    doc = Spomet.Documents.collection.findOne {docId: docId}
    if doc?
        removeTokens(doc.indexTokens).forEach (rToken) ->
            Spomet.Index.remove docId, rToken.indexName, rToken.token
        
        Spomet.Documents.collection.remove {_id: doc._id}

Spomet.removeBase = (baseId) ->
    cleanupSearches()
    c = Spomet.Documents.collection.find {'findable.base': baseId}
    c.forEach (e) ->
        removeTokens(e.indexTokens).forEach (rToken) ->
            Spomet.Index.remove e.docId, rToken.indexName, rToken.token
        Spomet.Documents.collection.remove {_id: e._id}

Spomet.reset = () ->
    cleanupSearches()
    Index.reset()
    
Meteor.methods
    spometFind: (phrase, indexNames) ->
        indexes = Spomet.options.indexes
        if indexNames?
            indexes = Spomet.options.indexes.filter (e) ->
                e.name in indexNames
            
        Spomet.find phrase, indexes
    spometAdd: (findable) ->
        Spomet.add findable
    spometRemove: (findable) ->
        if findable?.docId?
            Spomet.remove findable.docId
        else if findable?
            Spomet.remove findable
    spometRemoveBase: (baseId) ->
        Spomet.removeBase baseId
    spometUpdate: (findable) ->
        Spomet.remove findable.previousVersionDocId
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
stopWords = ['there','not','this','that','them','then','and','the','any','all','other','und','ich','wir','sie','als']
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
            
    
Meteor.publish 'search-results', (opts) ->
    if opts?.phrase?
        [selector, queryOpts] = Spomet.buildSearchQuery opts
        Spomet.Searches.find selector, queryOpts
        