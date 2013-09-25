Spomet
======

Spomet is the contraction of Spotting Meteors.

Test it [here](http://spomet.meteor.com/ "Spomet hosted at meteor.com")

It is a quite simple and limited fulltext search engine for [Meteor](http://meteor.com "Home of Meteor"). Besides it's simplicity it's sufficient for my purpose (and eventually for many other's). It should be easily includable into your Meteor project. Take the [spomet package](https://github.com/Crenshinibon/spomet/tree/master/packages/spomet "Spomet package") from this GitHub repository's *packages* folder and put it into your app's *packages* folder.

This repository is itself a Meteor app and should serve as an example, of how to actually use Spomet. 

Get Started
===========

I tried to make using the package as simple as possible:

Include the search box in your template:
    
    {{> spometSearch}}
    
Access the results, found by using the search box, through a call to:

    Spomet.defaultSearch.results()

It returns a Meteor Collections Cursor.

Add documents to the search by calling the method *add* with a *Spomet.Findable* instance:

    Spomet.add new Spomet.Findable text, path, base, type, rev

* text
    The first parameter is the text, to be indexed.
* path
    Part of the identifier, relative to the base. Useful to identify parts of the base document. E.g. attribute identifiers of the stored document.
* base
    The base path. E.g. the id of the document, whose text should be indexed.
* type
    The documents type. Might be useful to distinguish between different types of documents. 
* rev
    A revision number to support multiple version of a document.
    

Advanced
========

You can delete documents from the search by calling *Spomet.remove* with a *Spomet.Findable* instance as the parameter or with the *docId*.

    Spomet.remove 'post-id1234-description-2'
    Spomet.remove new Spomet.Findable null, 'description', 'id1234', 'post', 2

You can update already indexed documents, dismissing the prior version.

    Spomet.update new Spomet.Findable text, path, base, type, rev
    
The document, with *rev - 1* gets removed from the search as a result.

You can create your own searches by instantiating *Spomet.Search*.

    mySearch = new Spomet.Search
    mySearch.find 'some text'
    mySearch.results()


Technology
==========

The current implementation uses four simple indexes. They are supposed to balance precision and recall. There haven't been any tests yet. So future updates might fine-tune the parameters and introduce further indexes.

Currently there is a 3gram based index, a simple word index, a custom index and a wordgroup index. Whereas wordgroups are groups of two words.

Future enhancements might include stemming, algorithm based (e.g. Porter) or based on a lexikon. As well as phonetics.

Furthermore is the implementation not very efficient, I fear. There is plenty of room to optimize certain aspects.

The server process handles the heavy lifting of indexing, finding and scoring the documents. 

When there are many documents to index the server might stall. 

A future enhancement might include establishing a separate process (deployable on a different host) for the indexing. Client side indexing might not be doable, because of security considerations.

If you experience performance issues you might want to disable certain Indexes, you should start with the 3Gram index.

There are handy Meteor methods to achieve this:

    Meteor.call 'disableThreeGramIndex'
    Meteor.call 'disableCustomIndex'
    Meteor.call 'disableWordGroupIndex'
    Meteor.call 'disableFullWordIndex'

Tests
=====

There are tests. [Laika](http://arunoda.github.io/laika/ "Home of Laika") tests, written in CoffeeScript. To execute those, you need a few additional things. A local MongoDB installation, Phantom.js and of course CoffeeScript. You might check the laika [homepage](http://arunoda.github.io/laika/ "Home of Laika") for further instructions.

Run the tests from the project's root folder with:

    laika --compilers coffee:coffee-script

Note: There might be some false errors, indicating some curly braces problem, when you run all tests at once.

Warning
=======

This package is still in it's really really early stages. As it should allow for some basic usage, there might be some essential things missing or going wrong.

There is of course no guarantee for it's correct functioning. And I'm not liable on any consequences resulting from the usage of this software.

Plans
=====

I'm not sure how much time I can spend, to drive this project further. For now I'm only adding aspects I need for the app I'm currently developing.

Contributions
=============

You are free to send me additions and corrections via pull requests. Or to use the code as inspiration and/or basis for your own implementation.

License
=======

"Do What The Fuck You Want To" - License.
