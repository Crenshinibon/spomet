Spomet.FullWordIndex =
    layerBoost: 1.0
    collection: new Meteor.Collection('spomet-fullwordindex')
    
    find: (phrase) ->
        phrase = @normalize phrase
        tokens = @tokenize phrase
        @lookupAndRate tokens
        
    lookupAndRate: (tokens) ->
        results = {}
        
        mostCommonTermCountQuery = Spomet.Index.mostCommonTermCount tokens
        meta = @collection.findOne {type: 'meta'}
        if meta?
            for own key, value of tokens
                term = @collection.findOne {term: key}
                if term?
                    documentsCountWithTerm = term.documents.length
                    term.documents.forEach (e) ->
                        score = Spomet.Index.rate(
                            e.currentTermCount, 
                            e.documentLength, 
                            e.mostCommonTermCount, 
                            meta.documentsCount, 
                            documentsCountWithTerm) 
                        score = score * Spomet.FullWordIndex.layerBoost / _.values(tokens).length * value / mostCommonTermCountQuery
                        
                        docId = Spomet.documentId e.version, e.base, e.path            
                        unless results[docId]?
                            results[docId] = new Spomet.Result e.version, e.base, e.path, score
                        else
                            results[docId].score += score
        _.values results
    
    tokenize: (text) ->
        tokens = {}
        text.split(' ').forEach (e) ->
            if tokens[e]?
                tokens[e] += 1
            else
                tokens[e] = 1
        tokens
        
    
    normalize: (text) ->
        text = text.toLowerCase().replace /[^a-z'\-äüö]/g, ' '
        text = text.replace /\s{2,}/g, ' '
        text.trim()
         
    add: (findable, callback) ->
        iCallback = (message, error) ->
            callback?("Document: #{findable.base}#{findable.path} added to word index.")
            
        normed = @normalize findable.text
        tokens = @tokenize normed
        
        Spomet.Index.add findable, normed, tokens, @collection, iCallback
        