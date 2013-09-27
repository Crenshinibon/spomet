if Meteor.isClient
    
    Template.addable.posts = () ->
        Posts.find {indexed: false}, {limit: 3}

    Template.search.results = () ->
        Spomet.defaultSearch.results()
    
    Template.result.score = () ->
        @score.toFixed 4
        
    Template.result.title = () ->
        if @type isnt 'custom'
            p = Posts.findOne {_id: @base}
            if p? then p.title else 'deleted'
        else
            c = CustomContent.findOne {_id: @base}
            if c? then c.text.substring(0,10) + '...' else 'deleted'
        
    Template.result.text = () ->
        if @type isnt 'custom'
            p = Posts.findOne {_id: @base}
            if p? then p.text else 'deleted'
        else
            c = CustomContent.findOne {_id: @base}
            if c? then c.text else 'deleted'
        
    Template.addable.events
        'click input' : () ->
            Spomet.add new Spomet.Findable this.title, '/title', this._id, 'post', 1
            Spomet.add new Spomet.Findable this.text, '/text', this._id, 'post', 1
            Posts.update {_id: this._id},{$set: {indexed: true}}

    Template.ownText.events
        'submit form': (e) ->
            e.preventDefault()
            tarea = $(e.target).find('textarea').first()
            text = tarea.val()
            id = CustomContent.insert {text: text}
            Spomet.add new Spomet.Findable text, 'custom', id, 'custom', 1
            tarea.val ''


