Spomet
======

Spomet is the contraction of Spotting Meteors. The detailed uptodate documentation can be found [here](http://shiggyenterprises.wordpress.com/2013/11/04/spomet-meteor-full-text-search-in-a-nutshell/)

Test it [here](http://spomet.meteor.com/ "Spomet hosted at meteor.com") and read about an extended example of it's usage [here](http://shiggyenterprises.wordpress.com/2013/09/28/developing-a-full-text-search-enabled-meteor-app).

It is a quite simple and limited fulltext search engine for [Meteor](http://meteor.com "Home of Meteor"). Besides it's simplicity it's sufficient for my purpose (and eventually for many other's). 


Tests
=====

There are tests. [Laika](http://arunoda.github.io/laika/ "Home of Laika") tests, written in CoffeeScript. To execute those, you need a few additional things. A local MongoDB installation, Phantom.js and of course CoffeeScript. You might check the laika [homepage](http://arunoda.github.io/laika/ "Home of Laika") for further instructions.

Run the tests from the project's root folder with:

    laika --compilers coffee:coffee-script

**Note:** There might be some false errors, indicating some curly braces problem, when you run all tests at once.

Warning
=======

This package is still in it's really really early stages. As it should allow for some basic usage, there might be some essential things missing or going wrong.

There is of course no guarantee for it's correct functioning. And I'm not liable on any consequences resulting from the usage of this software.

Plans
=====

I'm not sure how much time I can spend, to drive this project further. For now I'm only adding aspects I need for the app I'm currently developing. Ideas and wishes are welcome, though.

Contributions
=============

You are free to send me additions and corrections via pull requests. Or to use the code as inspiration and/or basis for your own implementation.

[![Hack Crenshinibon/spomet on Nitrous](https://d3o0mnbgv6k92a.cloudfront.net/assets/hack-l-v1-4b6757c3247e3c50314390ece34cdb11.png)](https://www.nitrous.io/hack_button?source=embed&runtime=meteor&repo=Crenshinibon%2Fspomet&file_to_open=README.md)

License
=======

"Do What The Fuck You Want To" - License.
