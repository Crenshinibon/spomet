Meteor.subscribe 'current-search-results'

Spomet.find = (phrase) ->
    Meteor.call 'spomet_find', phrase
    
Spomet.add = (findable) ->
    Meteor.call 'spomet_add', findable
    

Template.spometSearchForm.events
    'submit form': (e) ->
        #e.stopPropagation()
        #e.stopImmediatePropagation()
        e.preventDefault()
        phrase = $(e.target).find('input')[0].value
        Spomet.find phrase