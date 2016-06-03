# Updating the source code #

If you wish to commit changes or upgrades to BioPatRec, the easiest way is to submit a _patch_ using Tortoise. See this [Tortoise SVN Tutorial](http://www.igorexchange.com/node/87#branches) for more information.

PLEASE consider the following while programming

  * [Coding\_Standard](Coding_Standard.md) It simple, easy, and useful! Having the same coding standard helps everybody to easily understand and modify code.
  * [Copyright\_Notice](Copyright_Notice.md) (keep the connection with the author)


# Updating the wiki #

In order to update the wiki you must be added as a _committer_ in the project. Mail: maxo@chalmers.se to join.

Remember that the information on the wiki is public so mind the quality. It's OK to modify the wiki if there is a mistake, and every change is saved. However, try to minimize the modification history of the wiki by preparing you documentation first in other text processing software and using the _preview_ button before committing.

## Displaying images ##

Most of the wiki formatting can be found directly from [WikiSyntax](http://code.google.com/p/support/wiki/WikiSyntax). However something that they haven't communicated very well is how to display images. It is just a bit tricky but you will manage by following these steps:

  * Upload your image in the SVN at the folder _wiki/img_. If you are going to upload several images please create a new folder inside _img_.
  * You need to add the svn:mime-type with value image/png, to do so in Tortoise:
    * Copy the image to the img/ folder
    * Ring click on the image -> TortoiseSVN -> _add_
    * Ring click on the image -> then TortoiseSVN -> _properties_
    * New or Edit -> mime-type
    * Custom -> image/png
    * Ring click on the image -> SVN Commit...

then just write the address to the image in google code, e.g.:

`https://biopatrec.googlecode.com/svn/wiki/img/BioPatRec_Logo.png`

will render:

![https://biopatrec.googlecode.com/svn/wiki/img/BioPatRec_Logo.png](https://biopatrec.googlecode.com/svn/wiki/img/BioPatRec_Logo.png)