Spomet.updateLatestPhrases = (phrase, userId) ->
    lf = Spomet.LatestPhrases.findOne {phrase: phrase, user: userId}
    if lf?
        Spomet.LatestPhrases.update {_id: lf._id}, {$set: {queried: new Date}}
    else
        Spomet.LatestPhrases.insert
            phrase: phrase
            user: userId
            queried: new Date

Spomet.defaultOptions =
        combineOnBase: false
        wordGroupCallback: (results) ->
        fullWordsCallback: (results) ->
        threeGramCallback: (results) ->
        completeCallback: (results) ->

Spomet.find = (phrase, userId, options) ->
    unless options
        options = Spomet.defaultOptions
    else
        unless options.combineOnBase
            options.combineOnBase = Spomet.defaultOptions.combineOnBase
        unless options.wordGroupCallback 
            options.wordGroupCallback = Spomet.defaultOptions.wordGroupCallback
        unless options.fullWordsCallback 
            options.fullWordsCallback = Spomet.defaultOptions.fullWordsCallback
        unless options.threeGramCallback
            options.threeGramCallback = Spomet.defaultOptions.threeGramCallback
        unless options.completeCallback
            options.completeCallback = Spomet.defaultOptions.completeCallback
    
    
    #store the latest phrase or update it's timestamp
    Spomet.updateLatestPhrases(phrase, userId)
    
    #clear latest search
    Spomet.CurrentSearch.remove {user: userId}
        
    #built up new results set
    seen = {}
    
    wgr = Spomet.WordGroupIndex.find phrase
    wgr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, options.combineOnBase, seen
    options.wordGroupCallback wgr
    
    fwr = Spomet.FullWordIndex.find phrase
    fwr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, options.combineOnBase, seen
    options.fullWordsCallback fwr
    
    tgr = Spomet.ThreeGramIndex.find phrase
    tgr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, options.combineOnBase, seen
    options.threeGramCallback tgr
    
    options.completeCallback _.values seen
    
Spomet.searchResultAddOrAppend = (result, userId, combineOnBase, seen) ->
    id = if combineOnBase then result.base else result.docId
    if seen[id]?
        Spomet.CurrentSearch.update {lookupId: id, user: userId}, {$inc: {score: result.score}}
    else
        res = {user: userId, lookupId: id, docId: result.docId, score: result.score, base: result.base, path: result.path, version: result.version}
        Spomet.CurrentSearch.insert res
        seen[id] = res

Spomet.add = (findable, callback) ->
    Spomet.ThreeGramIndex.add findable, () ->
        Spomet.FullWordIndex.add findable, () ->
            Spomet.WordGroupIndex.add findable, () ->
                callback?("Added to all indexes.")
        
Spomet.remove = (delEntity) ->
    
Spomet.shrink = () ->
    
Spomet.discardOutdated = () ->
    
Spomet.rebuilt = (validEntities) ->
    
Spomet.reset = () ->
    Spomet.LatestPhrases.remove {}
    Spomet.CurrentSearch.remove {}
    Spomet.ThreeGramIndex.collection.remove {}
    Spomet.FullWordIndex.collection.remove {}
    Spomet.WordGroupIndex.collection.remove {}
    
Meteor.methods(
    spomet_find: (phrase) ->
        if @userId?
            Spomet.find phrase, @userId
        else
            Spomet.find phrase, 'anon'
    spomet_add: (findable) ->
        Spomet.add(findable)
)

Meteor.publish 'current-search-results', () ->
    opts = {sort: [['score','desc']], limit: 10}
    if @userId?
        Spomet.CurrentSearch.find {user: @userId}, opts 
    else
        Spomet.CurrentSearch.find {user: 'anon'}, opts

Meteor.publish 'latest-phrases', () ->
    opts = {sort: [['queried','desc']], limit: 20}
    if @userId?
        Spomet.LatestPhrases.find {user: @userId}, opts
    else
        Spomet.LatestPhrases.find {user: 'anon'}, opts