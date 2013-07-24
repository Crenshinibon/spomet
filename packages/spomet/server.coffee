Spomet.find = (phrase, userId, callback) ->
    #store the latest phrase
    Spomet.LatestPhrases.insert
        phrase: phrase
        user: userId
        queried: new Date
    
    #clear latest search
    Spomet.CurrentSearch.remove {user: userId}
    
    #built up new results set
    seen = {}
    Spomet.WordGroupIndex.find(phrase).forEach (e) ->
        Spomet.searchResultAddOrAppend(e, userId, seen)
        callback?('Found by WordGroup:', e)
    Spomet.FullWordIndex.find(phrase).forEach (e) ->
        Spomet.searchResultAddOrAppend(e, userId, seen)
        callback?('Found by FullWord:', e)
    Spomet.ThreeGramIndex.find(phrase).forEach (e) ->
        Spomet.searchResultAddOrAppend(e, userId, seen)
        callback?('Found by ThreeGram', e)
    
    callback?('Complete', seen)
    
Spomet.searchResultAddOrAppend = (result, userId, seen) ->
    if seen[result.docId]?
        Spomet.CurrentSearch.update {docId: result.docId, user: userId}, {$inc: {score: result.score}}
    else
        Spomet.CurrentSearch.insert
            user: userId
            docId: result.docId
            score: result.score
            base: result.base
            path: result.path
            version: result.version
        seen[result.docId] = 1

Spomet.add = (findable) ->
    Spomet.ThreeGramIndex.add(findable)
    Spomet.FullWordIndex.add(findable)
    Spomet.WordGroupIndex.add(findable)
        
Spomet.remove = (delEntity) ->
    
Spomet.shrink = () ->
        
Spomet.rebuilt = (validEntities) ->
    
Spomet.reset = () ->
    Spomet.LatestPhrases.remove {}
    Spomet.CurrentSearch.remove {}
    Spomet.ThreeGramIndex.collection.remove {}
    Spomet.FullWordIndex.collection.remove {}
    Spomet.WordGroupIndex.collection.remove {}
        
Spomet.documentId = (base, path, version) ->
    base + path + version

class Spomet.Findable
    @version: '0.1'
    constructor: (@text, @path, @base, @version) ->

class Spomet.Result
    constructor: (@version, @base, @path, @score) ->
        @docId = Spomet.documentId @base, @path, @version


Meteor.methods(
    spomet_find: (phrase) ->
        Spomet.find(phrase, @userId)
    spomet_add: (findable) ->
        Spomet.add(findable)
)

Meteor.publish 'current-search-results', () ->
    Spomet.CurrentSearch.find {user: @userId}, {sort: {rank: 1}}

Meteor.publish 'latest-phrases', () ->
    Spomet.LatestPhrases.find {user: @userId}, {sort: {queried: -1}}, limit: 20
