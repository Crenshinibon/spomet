calcMostCommonTermCount = (tokens) ->
    if tokens.length > 0
        currentMax = 1
        tCounts = {}
        tokens.forEach (t) ->
            if tCounts[t.token]?
                tCounts[t.token] += 1
                c = tCounts[t.token]
                if c > currentMax
                    currentMax = c
            else
                tCounts[t.token] = 1
        currentMax
    else
        0
    
@Documents = 
    collection: new Meteor.Collection 'spomet-docs'
    exists: (findable) ->
        existing = @collection.findOne {docId: findable.docId}
        existing?
    
    get: (docId) ->
        @collection.findOne({docId: docId})
    
    add: (findable, tokens) ->
        #expects as indexTokens {index: name, tokens: ['t1','t2']}
        unless @exists findable
            @collection.insert 
                docId: findable.docId
                findable: findable
                dlength: findable.text.length
                created: new Date()
                indexTokens: tokens
                mostCommonTermCount: calcMostCommonTermCount tokens
            cMeta = @collection.findOne({meta: 'count'})
            if cMeta?
                @collection.update {_id: cMeta._id}, {$inc: {count: 1}}
            else
                @collection.insert {meta: 'count', count: 1}
    
    ratingParams: (docId) ->
        doc = @collection.findOne({docId: docId})
        if doc?
            dlength: doc.dlength
            mostCommonTermCount: doc.mostCommonTermCount
            documentsCount: @count()
        
    length: (docId) ->
        @collection.findOne({docId: docId})?.dlength
        
    mostCommonTermCount: (docId) ->
        @collection.findOne({docId: docId})?.mostCommonTermCount
        
    count: () ->
        @collection.findOne({meta: 'count'}).count
            
Spomet.Documents = @Documents