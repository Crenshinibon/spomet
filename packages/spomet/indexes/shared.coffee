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
        
        _.keys(tokens).forEach (key) ->
            term = collection.findOne {term: key}
            doc.currentTermCount = tokens[key]
            if term?
                collection.update {_id: term._id}, {$push: {documents: doc}}
            else
                collection.insert {term: key, documents: [doc]}
        callback 'Finished'