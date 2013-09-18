Spomet = {}

Spomet.Search = new Meteor.Collection 'spomet-search'
Spomet.CommonTerms = new Meteor.Collection 'spomet-fullword'

Spomet.options =
    indexes: []
    resultsCount: 20
    keywordsCount: 1000

class Spomet.Findable
    version: 1
    type: 'default'
    constructor: (@text, @path, @base, @type, @version) ->
        @docId = type + '-' + base + '-' + path + '-' + version


@Index = {}
