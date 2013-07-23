Spomet.WordGroupIndex =
    layerBoost: 2
    collection: new Meteor.Collection('spomet-wordgroupindex')
    
    find: (phrase) ->
        phrase = @normalize phrase
        tokens = @tokenize phrase, true
        if _.values(tokens).length > 1
            @lookupAndRate tokens
        else
            []
                
    lookupAndRate: (tokens) ->
        results = {}
        
        mostCommonTermCountQuery = @mostCommonTermCount tokens
        meta = @collection.findOne {type: 'meta'}
        if meta?
            for own key, value of tokens
                term = @collection.findOne {term: key}
                #term known?
                if term?
                    documentsCountWithTerm = term.documents.length
                    term.documents.forEach (e) ->
                        score = Spomet.Index.rate(
                            e.currentTermCount, 
                            e.documentLength, 
                            e.mostCommonTermCount, 
                            meta.documentsCount, 
                            documentsCountWithTerm) 
                        score = score * Spomet.WordGroupIndex.layerBoost / Math.log _.values(tokens).length
                        
                        docId = e.path + e.base + e.version                        
                        unless results[docId]?
                            results[docId] = new Spomet.Result docId, e.version, e.base, e.path, score
                        else
                            results[docId].score += score
        _.values results
    
    tokenize: (text, incReverse) ->
        tokens = {}
        
        addToken = (token) ->
            if tokens[token]? then tokens[token] += 1 else tokens[token] = 1
        
        words = text.split(' ')
        if words.length > 1
            prev = words[0]
            for i in [1 .. words.length]
                cur = words[i]
                addToken prev + cur
                if incReverse? then addToken cur + prev
                prev = cur
        tokens
        
    
    normalize: (text) ->
        text = text.toLowerCase().replace /[^a-z'äüö]/g, ' '
        text = text.replace /\s{2,}/g, ' '
        text

    
    mostCommonTermCount: (tokens) ->
        count = 1
        for own key, value of tokens
                if value > count
                    count = value
        count
    
    add: (findable, callback) ->
        normed = @normalize findable.text
        tokens = @tokenize normed
        if _.values(tokens).length > 1
            meta = @collection.findOne {type: 'meta'}
            if meta?
                @collection.update {_id: meta._id}, {$inc: {documentsCount: 1}}
            else
                @collection.insert {type: 'meta', documentsCount: 1}
        
            doc =
                base: findable.base
                path: findable.path
                version: findable.version
                mostCommonTermCount: @mostCommonTermCount tokens
                documentLength: normed.length
        
            for own key, value of tokens
                term = @collection.findOne {term: key}
            
                doc.currentTermCount = value
                if term?
                    @collection.update {_id: term._id}, {$push: {documents: doc}}
                else
                    @collection.insert {term: key, documents: [doc]}
                 
            callback?("Document: #{doc.base}#{doc.path} added to WordGroup index.")
        else
            callback?("Document: #{findable.base}#{findable.path} NOT indexed. It contains only one word.")
