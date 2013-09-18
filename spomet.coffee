if Meteor.isClient
    Session.set 'random-offset', Math.random()
    
    Template.addable.posts = () ->
        Posts.find({indexed: false, rand: {$gt: Session.get 'random-offset'}},{limit: 3})

    Template.search.results = () ->
        Spomet.Search.find()
    
    Template.result.score = () ->
        @score.toFixed 4
        
    Template.result.title = () ->
        if @path isnt 'custom'
            p = Posts.findOne {_id: @base}
            if p? then p.title else 'deleted'
        else
            c = CustomContent.findOne {_id: @base}
            if c? then c.text.substring(0,10) + '...' else 'deleted'
        
    Template.result.text = () ->
        if @path isnt 'custom'
            p = Posts.findOne {_id: @base}
            if p? then p.text else 'deleted'
        else
            c = CustomContent.findOne {_id: @base}
            if c? then c.text else 'deleted'
        
    Template.addable.events
        'click input' : () ->
            Session.set 'random-offset', Math.random()
            Spomet.add new Spomet.Findable this.title, '/title', this._id, 'post', 1
            Spomet.add new Spomet.Findable this.text, '/text', this._id, 'post', 1
            Posts.update {_id: this._id},{$set: {indexed: true}}

    Template.ownText.events
        'submit form': (e) ->
            text = $(e.target).find('textarea').first().val()
            id = CustomContent.insert {text: text}
            Spomet.add new Spomet.Findable text, 'custom', id, 'custom', 1
    
