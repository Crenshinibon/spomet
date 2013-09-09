@Documents = 
    collection: new Meteor.Collection 'spomet-docs'
    exists: (findable) ->
        existing = Spomet.Documents.find {docId: findable.docId}
        existing?
    
    add: (findable, tokens) ->
        #expects as indexTokens {index: name, tokens: ['t1','t2']}
        unless @exists findable
            @collection.insert 
                docId: findable.docId
                findable: findable
                indexTokens: tokens
            
Spomet.Documents = @Documents