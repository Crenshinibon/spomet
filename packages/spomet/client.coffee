Deps.autorun () ->
    Meteor.subscribe 'current-search-results'
    Meteor.subscribe 'latest-phrases'

Spomet.find = (phrase) ->
    Meteor.call 'spomet_find', phrase
    
Spomet.add = (findable) ->
    Meteor.call 'spomet_add', findable
    

Template.spometSearch.events
    'keyup input': (e) ->
        #type ahead - yet to implement
        #console.log e.target.value
    'submit form': (e) ->
        e.preventDefault()
        phrase = $(e.target).find('input')[0].value
        Spomet.find phrase