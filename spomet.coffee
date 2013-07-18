if Meteor.isClient
    Template.hello.greeting = () ->
        'Welcome to spomet.'

    Template.hello.events(
        'click input' : () ->
            console?.log 'You pressed the button'
    )

if Meteor.isServer
    Meteor.startup () ->


@some_fun = () ->
    'some fun called'

@test_package = () ->
    Spomet.find('')