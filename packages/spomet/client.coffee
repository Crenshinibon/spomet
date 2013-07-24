Meteor.subscribe 'current-search-results'

Spomet.find = (phrase) ->
    Meteor.call 'spomet_find', phrase
    
Spomet.add = (findable) ->
    Meteor.call 'spomet_add', findable
    
