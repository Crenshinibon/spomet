###
# Collections to store the actual index
# - an index by word, (eventually stemming )
###
@WordIndex = new Meteor.Collection('spomet-wordindex')
@NGramIndex = new Meteor.Collection('spomet-ngramindex')


###
# This collections stores deleted Findables, it's used
# to later get rid of those. Remove them from the indexes.
###
@DeletedEntities = new Meteor.Collection('spomet-deletedentities')


##
# This collection stores searches by query
# 
#
# well this doesn't make much sense or? Maybe it does, because Search
# is the main navigation facility.
##
@SearchHistory = new Meteor.Collection('spomet-searchhistory')

