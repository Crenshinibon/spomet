@Spomet =
    find: (phrase) ->
        #clear latest search
        
        
        ['found']

    index: (newEntity) ->
        
    remove: (delEntity) ->
    
    shrink: () ->
        
    rebuilt: (validEntities) ->
        

class @Spomet.Findable
    @version: '0.1'
    @base: null
        
    @path: null
    @text: null
        
    constructor: (@text, @path, @base, @version) ->

Meteor.methods(
    spomet_find: (phrase) ->
        Spomet.find(phrase)
)