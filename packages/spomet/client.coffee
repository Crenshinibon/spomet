Deps.autorun () ->
    Meteor.subscribe 'current-search-results'
    Meteor.subscribe 'latest-phrases'

Spomet.find = (phrase, options) ->
    Meteor.call 'spometFind', phrase, (Session.get 'sessionId'), options
    
Spomet.add = (findable) ->
    Meteor.call 'spometAdd', findable

Template.spometSearch.latestPhrase = () ->
    e = Spomet.LatestPhrases.findOne {}, {sort: [['queried', 'desc']], limit: 1}
    if e?
        e.phrase
    else
        ''

Spomet.options = Spomet.defaultOptions

Template.spometSearch.rendered = () ->
    $('input.spomet-search-field').typeahead
        source: () ->
            _.map Spomet.LatestPhrases.find().fetch(), (e) ->
                e.toString = () ->
                    JSON.stringify @
                e
        updater: (item) ->
            obj = JSON.parse item
            $('input.spomet-search-field')[0].value = obj.phrase
            Spomet.find obj.phrase, Spomet.options
        matcher: (item) ->
            regexp = new RegExp(@query,'i')
            regexp.test item.phrase
        sorter: (items) ->
            items.sort (e,o) ->
                e.queried < o.queried
        highlighter: (item) ->
            q = @query
            parts = item.phrase.split new RegExp(@query,'i')
            parts.reduce (s, e) ->
                s + '<span style="color: lightgrey">' + q + '</span>' + e
                        
Template.spometSearch.events
    'submit form': (e) ->
        e.preventDefault()
        phrase = $('input.spomet-search-field')[0].value
        Spomet.find phrase, Spomet.options
    'focus input': (e) ->
        $('input.spomet-search-field').first().select()
    'mouseup input': (e) ->
        e.preventDefault()