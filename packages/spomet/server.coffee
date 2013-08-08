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

Spomet.find = (phrase, userId, sessionId, options) ->
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
    if userId?
        Spomet.updateLatestPhrases(phrase, userId)
    
    #clear latest search
    if userId?
        Spomet.CurrentSearch.remove {user: userId}
    else
        Spomet.CurrentSearch.remove {session: sessionId}
        
    #built up new results set
    seen = {}
    
    wgr = Spomet.WordGroupIndex.find phrase
    wgr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, sessionId, options.combineOnBase, seen
    options.wordGroupCallback wgr
    
    fwr = Spomet.FullWordIndex.find phrase
    fwr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, sessionId, options.combineOnBase, seen
    options.fullWordsCallback fwr
    
    tgr = Spomet.ThreeGramIndex.find phrase
    tgr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, sessionId, options.combineOnBase, seen
    options.threeGramCallback tgr
    
    options.completeCallback _.values seen
    
Spomet.searchResultAddOrAppend = (result, userId, sessionId, combineOnBase, seen) ->
    id = if combineOnBase then result.base else result.docId
    if seen[id]?
        Spomet.CurrentSearch.update {lookupId: id, user: userId, session: sessionId}, {$inc: {score: result.score}}
    else
        res = 
            user: userId
            session: sessionId
            lookupId: id
            docId: result.docId 
            score: result.score 
            base: result.base 
            path: result.path
            version: result.version
            queried: new Date()
        Spomet.CurrentSearch.insert res
        seen[id] = res

#clear search result after one hour
Spomet.anonymousResultTimeout = 60 * 60 * 1000
#look every 10 minutes
Spomet.anonymousResultInterval = 10 * 60 * 1000
cleanupAnonSearch = () ->
    d = new Date(new Date().getTime() - Spomet.anonymousResultTimeout)
    Spomet.CurrentSearch.remove {userId: null, queried: {$lt: d}}, {multiple: true}
Meteor.setInterval cleanupAnonSearch, Spomet.anonymousResultInterval

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
    spometFind: (phrase, sessionId, opts) ->
        Spomet.find phrase, @userId, sessionId, opts
    spometAdd: (findable) ->
        Spomet.add(findable)
)

Meteor.publish 'current-search-results', () ->
    opts = {sort: [['score','desc']], limit: 20}
    if @userId?
        Spomet.CurrentSearch.find {user: @userId}, opts 
    else
        Spomet.CurrentSearch.find {session: @_session.id}, opts

Meteor.publish 'latest-phrases', () ->
    opts = {sort: [['queried','desc']], limit: 20}
    if @userId?
        Spomet.LatestPhrases.find {user: @userId}, opts