Deps.autorun () ->
    Meteor.subscribe 'common-terms'
    Meteor.subscribe 'search-results', 
        Session.get 'spomet-current-search', 
        Session.get 'spomet-search-opts'
    
Spomet.find = (phrase) ->
    Session.set 'spomet-current-search', phrase
    Meteor.call 'spometFind', phrase

Spomet.clearSearch = () ->
    Session.set 'spomet-current-search', null

Spomet.add = (findable) ->
    Meteor.call 'spometAdd', findable

Template.spometSearch.latestPhrase = () ->
    Session.get 'spomet-current-search'

typeaheadSource = (query) ->
    [start..., last] = @query.split ' '
    r = new RegExp "^#{last}"
    cursor = Spomet.CommonTerms.find 
        token: r
        tlength: {$gt: last.length}
        
    fixed = start.join ' '
    m = cursor.map (e) ->
        fixed + ' ' + e.token
    console.log m
    m

###
highlighter: (item) ->
    q = @query
    parts = item.token.split q
    parts.reduce (s, e) ->
        s + '<span style="color: lightgrey">' + q + '</span>' + e
###
Template.spometSearch.rendered = () ->
    $('input.spomet-search-field').typeahead
        source: typeaheadSource
        updater: (item) ->
            $('input.spomet-search-field')[0].value = item
        matcher: (item) ->
            true
    
Template.spometSearch.events
    'submit form': (e) ->
        e.preventDefault()
        phrase = $('input.spomet-search-field')[0].value
        Spomet.find phrase
    'focus input.spomet-search-field': (e) ->
        $(e.target).select()
    'mouseup input.spomet-search-field': (e) ->
        e.preventDefault()