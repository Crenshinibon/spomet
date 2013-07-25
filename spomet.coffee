
if Meteor.isClient
    Template.addable.posts = () ->
        Posts.find({indexed: false})

    Template.addable.events(
        'click input' : () ->
            Spomet.add new Spomet.Findable this.title, '/title', this._id, '0.1'
            Spomet.add new Spomet.Findable this.text, '/text', this._id, '0.1'
            Posts.update {_id: this._id},{$set: {indexed: true}}
    )

if Meteor.isServer
    Meteor.startup () ->

@some_fun = () ->
    'some fun called'

@test_package = () ->
    Spomet.find('')