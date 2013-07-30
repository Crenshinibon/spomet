Spomet.documentId = (base, path, version) ->
    base + path + version

class Spomet.Findable
    @version: 1
    constructor: (@text, @path, @base, @version) ->

class Spomet.Result
    constructor: (@version, @base, @path, @score) ->
        @docId = Spomet.documentId @base, @path, @version
