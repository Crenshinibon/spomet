Spomet.ThreeGramIndex =
    layerBoost: 0.8
    collection: new Meteor.Collection('spomet-threegramindex')
    
    find: (phrase) ->
        phrase = @normalize phrase
        tokens = @tokenize phrase
        @lookupAndRate tokens, phrase
        
    lookupAndRate: (tokens, phrase) ->
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
                 
        callback?("Document: #{doc.base}#{doc.path} added to 3gram index.")
