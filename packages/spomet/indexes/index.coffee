index = (findable, tokens, collection) ->
    tokens.forEach (token) ->
        doc = 
            docId: findable.docId
            pos: token.pos
        
        t = collection.findOne {token: token.token}
        if t?
            #maybe count only documents once, 
            #currently duplicate tokens are counted twice
            upd = {$push: {documents: doc}}
            unless doc.docId in (t.documents.map (d) -> d.docId)
                upd['$inc'] = {documentsCount: 1} 
                
            collection.update {token: token.token}, upd
        else
            collection.insert 
                token: token.token, 
                documentsCount: 1, 
                documents: [doc]

tokenizeWithIndex = (index, text) ->
    tokenizer = new index.Tokenizer
    text.split('').forEach (c, i) ->
        tokenizer.parseCharacter c, i
    tokenizer.finalize()
    tokenizer

documentsCountWithToken = (collection, token) ->
    collection.findOne({token: token})?.documentsCount

@Index =
    rate: (docId, tokenCounts) ->
        score = 0
        para = Documents.ratingParams docId
        for key, data of tokenCounts
            score += data.indexBoost * Index.tfidf data.tokenCountInDoc, 
                para.length, 
                para.mostCommonTermCount, 
                para.documentsCount, 
                data.documentsCountWithToken,
                data.indexBoost
        score
    
    tfidf: (termCountInDocument, documentLength, mostCommonTermCountInDocument, allDocumentsCount, documentsCountWithTerm) ->
        tf = termCountInDocument / Math.log(documentLength * mostCommonTermCountInDocument)
        idf = Math.log (1 + allDocumentsCount) / documentsCountWithTerm
        tf * idf
    
    add: (findable, callback) ->
        
        unless Documents.exists findable
            #init indexer for each index
            tokenizers = Spomet.options.indexes.map (index) ->
                new index.Tokenizer
                
            #normalize and tokenize over all indexes in one go
            findable.text.split('').forEach (c, pos) ->
                tokenizers.forEach (t) ->
                    t.parseCharacter c, pos
            
            tokenizers.forEach (t) ->
                t.finalize()
                index findable, t.tokens, t.collection
            
            Documents.add findable, tokenizers.map((i) -> i.tokens).reduce (s, a) -> s.concat a
            callback? findable.docId, 'Document added to all indexes'
        else
            callback? null, 'Document already added!'
            
    reset: () ->
        Documents.collection.remove {}
        Documents.collection._ensureIndex {docId: 1}
        Spomet.options.indexes.forEach (index) ->
            index.collection.remove {}
            index.collection._ensureIndex {token: 1}
            
    findWithIndex: (index, phrase, callback) ->
        tokenizer = tokenizeWithIndex index, phrase
        @findWithTokenizer tokenizer, callback
        
    findWithTokenizer: (tokenizer, callback) ->
        found = {}
        tokenizer.tokens.forEach (token) ->
            tokenizer.collection.find({token: token.token}).forEach (t) ->
                t.documents.forEach (d) ->
                    callback? t.token, d.docId, d.pos
                    if found[d.docId]
                        found[d.docId].push {token: t.token, pos: d.pos}
                    else
                        found[d.docId] = [{token: t.token, pos: d.pos}]
        found
        
    remove: (docId, indexName, remToken) ->
        index = i for i in Spomet.options.indexes when i.name is indexName
        index.collection.update {token: remToken},
            $pull: {documents: {docId: docId}}
            $inc: {documentsCount: -1}
            
    
    find: (phrase, callback, options) ->
        unless options?.indexes?
            unless options? then options = {}
            options.indexes = Spomet.options.indexes
            
        tokenizers = options.indexes.map (index) -> new index.Tokenizer
        phrase.split('').forEach (c, i) ->
            tokenizers.forEach (t) ->
                t.parseCharacter c, i
        
        found = {}
        tCounts = {}
        tokenizers.forEach (t) -> 
            t.finalize()
            Index.findWithTokenizer t, (token, docId, pos) ->
                unless tCounts[docId]? then tCounts[docId] = {}
                subCounts = tCounts[docId]
                
                key = token + t.indexName
                if subCounts[key]?
                    subCounts[key].tokenCountInDoc += 1 
                else 
                    subCounts[key] =
                        token: token
                        tokenCountInDoc: 1
                        documentsCountWithToken: documentsCountWithToken t.collection, token                        
                        indexBoost: t.indexBoost
                        
                if found[docId]
                    found[docId].tokens.push new Index.Token(t.index.name, token, pos)
                else
                    found[docId] = 
                        tokens: [new Index.Token(t.index.name, token, pos)]
                    
                found[docId].score = Index.rate docId, tCounts[docId]
                callback? docId, found[docId].tokens, found[docId].score
        
        for docId, data of found
            #ratedResults.push
                docId: docId
                hits: data.tokens
                score: Index.rate docId, tCounts[docId]

if Meteor.isServer
    Spomet.Index = @Index

class @Index.Token
    constructor: (@indexName, @token, @pos) ->
    
