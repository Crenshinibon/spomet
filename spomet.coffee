
if Meteor.isClient
    console.log Meteor.default_connection
    
    Template.addable.posts = () ->
        Posts.find({indexed: false})

    Template.search.results = () ->
        Spomet.CurrentSearch.find()
        
    Template.result.score = () ->
        @score.toFixed 4
        
    Template.result.title = () ->
        p = Posts.findOne {_id: @base}
        if p? then p.title else 'deleted'
        
    Template.result.text = () ->
        p = Posts.findOne {_id: @base}
        if p? then p.text else 'deleted' 
        
    Template.addable.events
        'click input' : () ->
            Spomet.add new Spomet.Findable this.title, '/title', this._id, 1
            Spomet.add new Spomet.Findable this.text, '/text', this._id, 1
            Posts.update {_id: this._id},{$set: {indexed: true}}

if Meteor.isServer
    Meteor.startup () ->
