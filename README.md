Millennial — A Tool for the Meme Generation
===========================================

A command line utility to generate meme-ified images from given templates.

I made this since the API our chatbot was hitting was suddenly deprecated, and we (at the moment) have lost all the images we had on their server. Basically, enough hitting an API for something that can be done locally.

I've still got some tweaks to make, but it's at least somewhat functional right now (because it sure isn't object oriented, I'll tell ya that). \*ba dum tss\*

## Usage

```
$ make mill
$ mill <template path> <save path> <top text> ... ---- <bottom text> ...
```

The top and bottom text can be any number of words, they're delimited by four hyphens.

To have blank text on the top or bottom, pass in an underscore (_)

    $ mill template.png bottom.png _ ---- just bottom
    $ mill template.png top.png just top ---- _
    $ mill template.png no_caption.png _ ---- _

If you wanna just take a look at some of the tests I cobbled together, just run

    $ make && make run

