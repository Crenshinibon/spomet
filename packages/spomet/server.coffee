Spomet.find = (phrase, userId) ->
    #store the latest phrase
    assert userId?
    assert phrase?
    
    Spomet.LatestPhrases.add
        phrase: phrase
        user: userId
        queried: new Date
    
    #clear latest search
    Spomet.CurrentSearch.remove {user: userId}
    
    #built up new results set
    wgRes = Spomet.WordGroupIndex.find(phrase)
    wgRes.forEach (e) ->
        Spomet.CurrentSearch.insert
            user: userId
            score: e.score
            base: e.base
            path: e.path
            version: e.version
    fwRes = Spomet.FullWordIndex.find(phrase)
    tgRes = Spomet.ThreeGramIndex.find(phrase)
    #Spomet.CurrentSearch.insert {user: userId}
        
    ['found']

Spomet.add = (findable) ->
    Spomet.ThreeGramIndex.add(findable)
    Spomet.FullWordIndex.add(findable)
    Spomet.WordGroupIndex.add(findable)
        
Spomet.remove = (delEntity) ->
    
Spomet.shrink = () ->
        
Spomet.rebuilt = (validEntities) ->
        

class Spomet.Findable
    @version: '0.1'
    constructor: (@text, @path, @base, @version) ->


class Spomet.Result
    constructor: (@docId, @version, @base, @path, @score) ->


Meteor.methods(
    spomet_find: (phrase) ->
        Spomet.find(phrase, @userId)
    spomet_add: (findable) ->
        Spomet.add(findable)
)


###
# There are different layers for indexes. Each layer has different precision and recall.
# The results of each layer are rated with their precision.
###