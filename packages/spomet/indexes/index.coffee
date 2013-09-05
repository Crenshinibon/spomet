@Index =
    rate: (termCountInDocument, documentLength, mostCommonTermCountInDocument, allDocumentsCount, documentsCountWithTerm) ->
        tf = termCountInDocument / Math.log(documentLength * mostCommonTermCountInDocument)
        idf = Math.log (1 + allDocumentsCount) / documentsCountWithTerm
        tf * idf
    
    index: (findable, tokens, collection) ->
        for token, pos of tokens
            doc = 
                docId: findable.docId
                pos: pos
            
            t = collection.find {token: token}
            if t?
                collection.update {token: token}, {$push: {documents: doc}}
            else
                collection.insert {token: token, documents: [doc]}
    
    add: (findable, callback) ->
        
        unless Documents.exists findable
            #init indexer for each index
            tokenizer = Spomet.options.indexes.map (index) ->
                new index.Tokenizer
                
            #normalize and tokenize over all indexes in one go
            findable.text.split().forEach (c, pos) ->
                tokenizer.forEach (t) ->
                    t.parseCharacter c, pos
            
            tokenizer.forEach (t) ->
                index findable, t.tokens, t.collection
            
            Documents.add findable, tokenizer.map (i) -> i.indexTokens()
            callback? 'Document added to all indexes'
        else
            callback? 'Document already added!'
            
    reset: () ->
        Documents.collection.remove {}
        
        Spomet.options.indexes.forEach (index) ->
            index.collection.remove {}
