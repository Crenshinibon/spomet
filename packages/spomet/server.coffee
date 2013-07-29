Spomet.find = (phrase, userId, callback) ->
    #store the latest phrase
    Spomet.LatestPhrases.insert
        phrase: phrase
        user: userId
        queried: new Date
    
    #clear latest search
    Spomet.CurrentSearch.remove {user: userId}
    
    resAccumulator =
        allFinished: () ->
            @wgf and @fwf and @tgf
        wgf: false
        fwf: false
        tgf: false
    
    #built up new results set
    seen = {}
    
    wgr = Spomet.WordGroupIndex.find(phrase)
    if wgr.length is 0
        resAccumulator.wgf = true
        
    wgr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, seen, (error, result) ->
            unless error
                resAccumulator.wgf = true
                if resAccumulator.allFinished()
                    callback?('Complete', seen)
            else
                callback?('Error', error)
                console.log error
    
    fwr = Spomet.FullWordIndex.find(phrase)
    if fwr.length is 0
        resAccumulator.fwf = true
    
    fwr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, seen, (error, result) ->
            unless error
                resAccumulator.fwf = true
                if resAccumulator.allFinished()
                    callback?('Complete', seen)
            else
                callback?('Error', error)
                console.log error
                
    tgr = Spomet.ThreeGramIndex.find(phrase)
    if tgr.length is 0
        resAccumulator.tgf = true
    
    tgr.forEach (e) ->
        Spomet.searchResultAddOrAppend e, userId, seen, (error, result) ->
            unless error
                resAccumulator.tgf = true
                if resAccumulator.allFinished()
                    callback?('Complete', seen)
            else
                callback?('Error', error)
                console.log error
    
Spomet.searchResultAddOrAppend = (result, userId, seen, cb) ->
    if seen[result.docId]?
        Spomet.CurrentSearch.update {docId: result.docId, user: userId}, {$inc: {score: result.score}}, cb
    else
        Spomet.CurrentSearch.insert
            user: userId
            docId: result.docId
            score: result.score
            base: result.base
            path: result.path
            version: result.version
        , cb
        seen[result.docId] = 1

Spomet.add = (findable, callback) ->
    Spomet.ThreeGramIndex.add findable, () ->
        Spomet.FullWordIndex.add findable, () ->
            Spomet.WordGroupIndex.add findable, () ->
                callback?("Added to all indexes.")
        
Spomet.remove = (delEntity) ->
    
Spomet.shrink = () ->
        
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
    Spomet.CurrentSearch.find {user: @userId}, {sort: [['score','desc']], limit: 10}

Meteor.publish 'latest-phrases', () ->
    Spomet.LatestPhrases.find {user: @userId}, {sort: [['queried','desc']], limit: 20}
