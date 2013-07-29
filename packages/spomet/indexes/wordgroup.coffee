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
        
        mostCommonTermCountQuery = Spomet.Index.mostCommonTermCount tokens
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
                        
                        docId = Spomet.documentId e.version, e.base, e.path
                        unless results[docId]?
                            results[docId] = new Spomet.Result e.version, e.base, e.path, score
                        else
                            results[docId].score += score
        _.values results
    
    tokenize: (text, incReverse) ->
        tokens = {}
        
        addToken = (token) ->
            if tokens[token]?
                tokens[token] += 1 
            else
                tokens[token] = 1
        
        words = text.split(' ')
        if words.length > 1
            prev = words[0]
            for i in [1 .. words.length]
                cur = words[i]
                addToken prev + cur
                if incReverse?
                    addToken cur + prev
                prev = cur
        tokens
        
    
    normalize: (text) ->
        text = text.toLowerCase().replace /[^a-z'äüö]/g, ' '
        text = text.replace /\s{2,}/g, ' '
        text.trim()
    
    add: (findable, callback) ->
        iCallback = (message, error) ->
            callback?("Document: #{findable.base}#{findable.path} added to WordGroup index.")
            
        normed = @normalize findable.text
        tokens = @tokenize normed
        
        if _.values(tokens).length > 1
            Spomet.Index.add findable, normed, tokens, @collection, iCallback
        else
            callback?("Document: #{findable.base}#{findable.path} NOT indexed. It contains only one word.")
