###
# This collection stores the lately used search queries by user.
###
@LatestPhrases = new Meteor.Collection('spomet-latestphrases')

Meteor.publish 'latest-phrases', () ->
    LatestPhrases.find {user: @userId}, {sort: {queried: -1}}, limit: 20

###
# This collection stores the results of the current search by user
###
@CurrentSearch = new Meteor.Collection('spomet-currentresults')

Meteor.publish 'current-search-results', () ->
    CurrentSearch.find {user: @userId}, {sort: {rank: 1}}

