Spomet
======

Spomet is the contraction of Spotting Meteors.

Test it [here](http://spomet.meteor.com/ "Spomet hosted at meteor.com")

Spomet is a simple, but for my purpose (and eventually many other's) sufficient, search engine for [Meteor](http://meteor.com "Home of Meteor"). It should be easily includable into your Meteor project. Take the [spomet package](https://github.com/Crenshinibon/spomet/tree/master/packages/spomet "Spomet package") from this GitHub repository's packages folder and put it into your app's packages folder.

This Meteor app, should serve as an example how to actually use it. I tried to make it as simple as possible:

Include the search box in your template:
    
    {{> spometSearch}}
    
Access the results through the CurrentSearch collection:

    Spomet.CurrentSearch.find()

The search is user based. As long as their is no logged-in user Spomet uses the user *anon*. Multiple anonymous users do **interfere** with each other. A future version might utilize the Session to separate the users.

Add documents to the search by calling *add* the method with a *Findable*:

    Spomet.add new Spomet.Findable text, path, base, rev

* text
    The first parameter is the text, to be indexed.
* path
    Part of the identifier, relative to the bae. Useful to identify parts of the base document. E.g. attribute identifiers of the stored document.
* base
    The base path. E.g. the id of the document, whose text should be indexed.
* rev
    A revision number to support multiple version of a document. Postpones the need to
    remove documents from the index and provides basic support for versioning.


Technology
==========

The current implementation uses three simple indexes. They are supposed to balance precision and recall. There haven't been many tests yet. So future updates might fine-tune the parameters and introduce further indexes. 

Currently there is a 3gram based index, a simple word index and a wordgroup index. Whereas wordgroups are groups of two words.

Future enhancements might include stemming, algorithm based (e.g. Porter) or based on a lexikon. As well as phonetics.

Furthermore is the implementation not very efficient, I fear. There is plenty of room to optimize certain aspects.

A small client side subset of the most commonly used index terms to accelarate the search, for example.

The server process handles the heavy lifting of indexing the documents. So when there are many documents to include the server will stall. A future enhancement might include establishing a separate process (deployable on a different host) for the indexing.

Tests
=====

There are tests. [Laika](http://arunoda.github.io/laika/ "Home of Laika") tests, written in CoffeeScript. To execute those, you need a few additional things. A local MongoDB installation, Phantom.js and of course CoffeeScript. You might check the laika [homepage](http://arunoda.github.io/laika/ "Home of Laika") for further instructions.

Run the tests from the project's root folder with:

    laika --compilers coffee:coffee-script

Warning
=======

This package is in it's really really early stages. As it should allow for some basic usage, there are many aspects missing. The functionality to remove documents from the index for example. Supporting information to highlight matching aspects of resulting documents is also missing. As well as the performance improvements mentioned above.

There is of course no guarantee for it's correct functioning.

Plans
=====

I'm not sure how much time I can spend, to drive this project further. For now I'm only adding aspects I need for the app I'm currently developing.

Contributions
=============

You are free to send me additions and corrections via pull requests. Or to use the code as inspiration and/or basis for your own implementation.

License
=======

"Do What The Fuck You Want To" - License.
