Deps.autorun () ->
    Meteor.subscribe 'documents'
    Meteor.subscribe 'common-terms'
    Meteor.subscribe 'search-results', 
        Session.get 'spomet-current-search', 
        Session.get 'spomet-search-opts'
    
Spomet.find = (phrase) ->
    if phrase? and phrase.length > 0
        Meteor.call 'spometFind', phrase

Spomet.clearSearch = () ->
    Session.set 'spomet-current-search', null

Spomet.add = (findable) ->
    Meteor.call 'spometAdd', findable
    Spomet.clearSearch()

Template.spometSearch.latestPhrase = () ->
    phrase = Session.get 'spomet-current-search'
    if phrase? then phrase else ''

Template.spometSearch.searching = () ->
    Session.get('spomet-current-search')?

updateIntermediaryResults = (item) ->
    words = item.split(' ')
    cur = Spomet.CommonTerms.find {token: {$in: words}} 
    cur.forEach (e) ->
        e.documents.forEach (d) ->
            doc = Spomet.Documents.collection.findOne {docId: d.docId}
            res = 
                phraseHash: Spomet.phraseHash item
                docId: d.docId
                score: 0
                type: doc.findable.type
                base: doc.findable.base
                path: doc.findable.path
                version: doc.findable.version
                hits: []
                queried: new Date()
                interim: true
            Spomet.Search.insert res

typeaheadSource = (query) ->
    [start..., last] = @query.split ' '
    r = new RegExp "^#{last}"
    cursor = Spomet.CommonTerms.find 
        token: r
        tlength: {$gt: last.length}
        
    fixed = start.join ' '
    cursor.map (e) ->
        fixed + ' ' + e.token

Template.spometSearch.rendered = () ->
    $('input.spomet-search-field').typeahead
        source: typeaheadSource
        updater: (item) ->
            Spomet.clearSearch()
            $('input.spomet-search-field')[0].value = item
            updateIntermediaryResults item
            Session.set 'spomet-current-search', item
            #
            #this is a hack, I have to wait shortly, otherwise
            #the intermediary results are not shown
            #
            find = () ->
                Spomet.find item
            Meteor.setTimeout find, 5
        matcher: (item) ->
            true
    
Template.spometSearch.events
    'submit form': (e) ->
        e.preventDefault()
        Spomet.clearSearch()
        phrase = $('input.spomet-search-field')[0].value
        Session.set 'spomet-current-search', phrase
        Spomet.find phrase
    'click button.spomet-reset-search': (e) ->
        Spomet.clearSearch()
    'mouseup input.spomet-search-field': (e) ->
        e.preventDefault()