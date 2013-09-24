Spomet = {}

Spomet.Search = new Meteor.Collection 'spomet-search'
Spomet.CommonTerms = new Meteor.Collection 'spomet-fullword'

Spomet.options =
    indexes: []
    resultsCount: 20
    keywordsCount: 1000
    sort:
        field: 'score'
        direction: -1

Spomet.phraseHash = (phrase) ->
    CryptoJS.MD5(phrase).toString()

Spomet.buildSearchQuery = (phrase, sort, offset, limit) ->
    phraseHash = CryptoJS.MD5(phrase).toString()
    selector = {phraseHash: phraseHash}
    
    unless sort?
        sort = Spomet.options.sort
    
    opts = {}
    opts.sort = {}
    opts.sort[sort.field] = sort.direction
    
    if offset?
        if sort.direction is -1
            selector[sort.field] = {$lte: offset}
        else if sort.direction is 1
            selector[sort.field] = {$gte: offset}
    
    unless limit? then opts.limit = Spomet.options.resultsCount
    [selector, opts]

class Spomet.Findable
    constructor: (@text, @path, @base, @type, @version) ->
        unless version? then @version = 1
        unless type? then @type = 'default'
        @docId = @type + '-' + base + '-' + path + '-' + @version
    previousVersionDocId: () ->
        @type + '-' + @base + '-' + @path + '-' + (@version - 1)

@Index = {}
