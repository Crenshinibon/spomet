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
        
    constructor: (@text, @path, @base, @version) ->


class @Spomet.Result
    @score: 0
    
    constructor: (@version, @base, @path, @score) ->


Meteor.methods(
    spomet_find: (phrase) ->
        Spomet.find(phrase)
)


###
# There are different layers for indexes. Each layer has different precision and recall.
# The results of each layer are rated with their precision.
###