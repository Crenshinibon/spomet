Spomet.Index =
    rate: (termCountInDocument, documentLength, mostCommonTermCountInDocument, allDocumentsCount, documentsCountWithTerm) ->
        tf = termCountInDocument / Math.log(documentLength * mostCommonTermCountInDocument)
        idf = Math.log (1 + allDocumentsCount) / documentsCountWithTerm
        tf * idf
    
    
    mostCommonTermCount: (tokens) ->
        count = 1
        for own key, value of tokens
                if value > count
                    count = value
        count
    
    add: (findable, normed, tokens, collection, callback) ->
        meta = collection.findOne {type: 'meta'}
        if meta?
            collection.update {_id: meta._id}, {$inc: {documentsCount: 1}}
        else
            collection.insert {type: 'meta', documentsCount: 1}
        
        doc =
            base: findable.base
            path: findable.path
            version: findable.version
            mostCommonTermCount: @mostCommonTermCount tokens
            documentLength: normed.length
        
        #reduce the load on the MongoDB ...
        addToCollectionDelayed = (ikeys) ->
            ikeys.forEach (key) ->
                term = collection.findOne {term: key}
                doc.currentTermCount = tokens[key]
                if term?
                    collection.update {_id: term._id}, {$push: {documents: doc}}
                else
                    collection.insert {term: key, documents: [doc]}
        
        
        cbCount = 0
        firstRun = true
        interval = Meteor.setInterval () ->
            #console.log cbCount
            if not firstRun and cbCount is 0
                callback('Finished')
                Meteor.clearInterval interval
        , 20
        
        tokKeys = _.keys tokens
        keys = []
        tokKeys.forEach (e, i) ->
            keys.push e
            if i isnt 0 and i % 10 is 0
                ikeys = keys.slice()
                keys = []
                
                cbCount += 1
                firstRun = false
                
                Meteor.setTimeout () -> 
                    addToCollectionDelayed ikeys
                    cbCount -= 1
                , i / 2
            else if i + 1 is tokKeys.length and keys.length > 0
                    
                    cbCount += 1
                    firstRun = false
                    
                    Meteor.setTimeout () -> 
                        addToCollectionDelayed keys
                        cbCount -= 1
                    , i / 2