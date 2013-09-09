Spomet.defaultOptions =
    indexes: [WordGroupIndex, FullWordIndex, ThreeGramIndex]
    resultsCount: 20
    keywordsCount: 1000

Spomet.options = Spomet.defaultOptions

class Spomet.Findable
    version: 1
    type: 'default'
    constructor: (@text, @path, @base, @type, @version) ->
        @docId = type + base + path + version

