if Meteor.isClient
    Session.set 'sessionId', Meteor.connection._lastSessionId