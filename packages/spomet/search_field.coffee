Spomet.defaultSearch = new Spomet.Search

Template.spometSearch.latestPhrase = () ->
    phrase = Spomet.defaultSearch.getCurrentPhrase()
    if phrase? then phrase else ''

Template.spometSearch.searchInProgress = () ->
    Spomet.defaultSearch.isSearching()?

Template.spometSearch.searching = () ->
    Spomet.defaultSearch.getCurrentPhrase()?

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
            $('input.spomet-search-field')[0].value = item
            Spomet.defaultSearch.find item
        matcher: (item) ->
            true
    
Template.spometSearch.events
    'submit form': (e) ->
        e.preventDefault()
        Spomet.defaultSearch.clearSearch()
        phrase = $('input.spomet-search-field')[0].value
        if phrase? and phrase.length > 0
            Spomet.defaultSearch.find phrase
    'click button.spomet-reset-search': (e) ->
        Spomet.defaultSearch.clearSearch()
    