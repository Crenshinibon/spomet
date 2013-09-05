searchResultAddOrAppend = (result, phraseHash, seen, index) ->
    if seen[result.docId]?
        Spomet.Search.update {phraseHash: phraseHash, docId: result.docId}, {$inc: {score: result.score}}
    else
        res = 
            phraseHash: phraseHash
            docId: result.docId
            score: result.score
            type: result.type
            base: result.base
            path: result.path
            positions: [result.position]
            version: result.version
            queried: new Date()
            index: index
            
        Spomet.Search.insert res
        seen[result.docId] = res
    
Spomet.find = (phrase) ->
    phraseHash = CryptoJS.MD5(phrase).toString()
    
    cur = Spomet.Search.find {phraseHash: phraseHash}
    unless cur.count() is 0
        {phrase: phrase, hash: phraseHash, cached: true}
    else
        seen = {}
        
        Spomet.options.indexes.forEach (index) ->
            results = index.find phrase
            results.forEach (res) ->
                searchResultAddOrAppend res, phraseHash, seen, '', index
                
        options.completeCallback _.values seen
        {phrase: phrase, hash: phraseHash, cached: true}
        
cleanupSearches = () ->
    Spomet.Search.remove {}

Spomet.add = (findable, callback) ->
    cleanupSearches()
    
    Spomet.options.indexes.forEach (index) ->
        index.add findable
        
    callback? 'Added to all indexes'
    
Spomet.remove = (delEntity) ->
    
    
Spomet.shrink = () ->
    
Spomet.discardOutdated = () ->
    
Spomet.rebuilt = (validEntities) ->
    
Spomet.reset = () ->
    cleanupSearches()
    Index.reset()
    
Meteor.methods
    spometFind: (phrase) ->
        Spomet.find phrase
    spometAdd: (findable) ->
        Spomet.add(findable)


Meteor.publish 'search-results', (phrase) ->
    opts = {sort: [['score','desc']], limit: Spomet.options.resultsCount}
    phraseHash = CryptoJS.MD5(phrase).toString()
    Spomet.Search.find {phraseHash: phraseHash}, opts
    
Meteor.publish 'common-terms', () ->
    opts = {sort: [['docsCount','desc']], limit: Spomet.options.keywordsCount}
    Spomet.FullWordIndex.collection.find {}, opts
    
    