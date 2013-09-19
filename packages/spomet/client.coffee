Deps.autorun () ->
    Meteor.subscribe 'documents'
    Meteor.subscribe 'common-terms'
    Meteor.subscribe 'search-results', 
        Session.get 'spomet-current-search', 
        Session.get 'spomet-search-sort',
        Session.get 'spomet-search-offset',
        Session.get 'spomet-search-limit'
    
Spomet.find = (phrase) ->
    #
    # THIS IS A HACK, I have to wait shortly, otherwise
    # the intermediary results are not shown and Meteor
    # waits for the end before displaying results.
    # 
    # The problem might be some optimization that's going
    # on under the hood.
    #
    Session.set 'spomet-searching', true
    find = () ->
        if phrase? and phrase.length > 0
            Meteor.call 'spometFind', phrase, () ->
                Session.set 'spomet-searching', null
    Meteor.setTimeout find, 5
    
Spomet.searching = () ->
    Session.get 'spomet-searching'
    
Spomet.clearSearch = () ->
    Session.set 'spomet-searching', null
    Session.set 'spomet-current-search', null
    Session.set 'spomet-search-offset', null
    
Spomet.add = (findable) ->
    Meteor.call 'spometAdd', findable, () ->
    Spomet.clearSearch()

Spomet.setSort = (sort) ->
    Session.set 'spomet-search-sort', sort

Spomet.getSort = () ->
    Session.get 'spomet-search-sort'

Spomet.setOffset = (offset) ->
    Session.set 'spomet-search-offset', offset
    
Spomet.getOffset = () ->
    Session.get 'spomet-search-offset'
    
Spomet.setLimit = (limit) ->
    Session.set 'spomet-search-limit', limit
    
Spomet.getLimit = () ->
    Session.get 'spomet-search-limit'

Spomet.Results = () ->
    phrase = Session.get 'spomet-current-search'
    if phrase?
        [selector, opts] = Spomet.buildSearchQuery phrase, 
            Spomet.getSort(), 
            Spomet.getOffset(), 
            Spomet.getLimit()
        
        Spomet.Search.find selector, opts

Template.spometSearch.latestPhrase = () ->
    phrase = Session.get 'spomet-current-search'
    if phrase? then phrase else ''

Template.spometSearch.searchInProgress = () ->
    Session.get('spomet-searching')?

Template.spometSearch.searching = () ->
    Session.get('spomet-current-search')?

createIntermediaryResults = (item) ->
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
        if fixed and fixed.length > 0
            fixed + ' ' + e.token
        else
            e.token

Template.spometSearch.rendered = () ->
    $('input.spomet-search-field').typeahead
        source: typeaheadSource
        updater: (item) ->
            Spomet.clearSearch()
            $('input.spomet-search-field')[0].value = item
            createIntermediaryResults item
            Spomet.find item
            Session.set 'spomet-current-search', item
        matcher: (item) ->
            true
    
Template.spometSearch.events
    'submit form': (e) ->
        e.preventDefault()
        Spomet.clearSearch()
        phrase = $('input.spomet-search-field')[0].value
        Spomet.find phrase
        Session.set 'spomet-current-search', phrase
    'click button.spomet-reset-search': (e) ->
        Spomet.clearSearch()
    'mouseup input.spomet-search-field': (e) ->
        e.preventDefault()