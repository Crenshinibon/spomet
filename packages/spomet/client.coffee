@Spomet =
    find: (phrase, callback) ->
        Meteor.call 'spomet_find', phrase, callback