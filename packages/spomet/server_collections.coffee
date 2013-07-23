###
# Collections to store the actual index
# - an index by word, (eventually stemming )
###
Spomet.WordIndex = new Meteor.Collection('spomet-wordindex')



###
# This collections stores deleted Findables, it's used
# to later get rid of those. Remove them from the indexes.
###
Spomet.DeletedEntities = new Meteor.Collection('spomet-deletedentities')


##
# This collection stores searches by query
# 
#
# well this doesn't make much sense or? Maybe it does, because Search
# is the main navigation facility.
##
Spomet.SearchHistory = new Meteor.Collection('spomet-searchhistory')

