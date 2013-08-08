if Meteor.isClient
    Session.set 'sessionId', Meteor.default_connection._lastSessionId