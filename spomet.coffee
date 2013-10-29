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
            Spomet.add 
                text: @title
                path: '/title'
                base: @_id 
                type: 'post'
            Spomet.add 
                text: @text
                path: '/text'
                base: @_id 
                type: 'post'
            Posts.update {_id: @_id},{$set: {indexed: true}}

    Template.ownText.events
        'submit form': (e) ->
            e.preventDefault()
            tarea = $(e.target).find('textarea').first()
            text = tarea.val()
            id = CustomContent.insert {text: text}
            Spomet.add 
                text: text
                path: 'custom'
                base: id
                type: 'custom'
            tarea.val ''


