@Documents = 
    collection: new Meteor.Collection 'spomet-docs'
    exists: (findable) ->
        existing = Spomet.Documents.find {docId: findable.docId}
        existing?
    
    add: (findable, indexTokens) ->
        #expects as indexTokens {index: name, tokens: ['t1','t2']}
        unless @exists findable
            doc = 
                docId: findable.docId
                findable: findable
        
            for indexName, tokens of indexTokens
                doc[index] = tokens
        
            @collection.insert doc
        