Spomet.ThreeGramIndex =
    layerBoost: 0.8
    collection: new Meteor.Collection('spomet-threegramindex')
    
    find: (phrase) ->
        res = []
        if phrase?
            phrase = @normalize phrase
            tokens = @tokenize phrase
            res = @lookupAndRate tokens, phrase
        res
        
    lookupAndRate: (tokens, phrase) ->
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
                        score = score * Spomet.ThreeGramIndex.layerBoost / phrase.length * value / mostCommonTermCountQuery
                        
                        docId = Spomet.documentId e.version, e.base, e.path            
                        unless results[docId]?
                            results[docId] = new Spomet.Result e.version, e.base, e.path, score
                        else
                            results[docId].score += score
                            
        _.values results
    
    tokenize: (text) ->
        text = " #{text} "
        tokens = {}
        
        #iterate over every character
        current = []
        for i in [0 .. text.length]
            l = text[i]
            if (i >= 3)
                ng = current.join ''
                if tokens[ng]?
                    tokens[ng] = tokens[ng] + 1
                else
                    tokens[ng] = 1
                
                current = current[1..]
                current.push l
            else
                current.push l
            
        tokens
        
    
    normalize: (text) ->
        text = text.toLowerCase().replace /[^a-z]/g, ' '
        text = text.replace /\s{2,}/g, ' '
        text.trim()

    add: (findable, callback) ->
        iCallback = (message, error) ->
            callback?("Document: #{findable.base}#{findable.path} added to 3Gram index.")
        
        normed = @normalize findable.text
        tokens = @tokenize normed
        Spomet.Index.add findable, normed, tokens, @collection, iCallback
