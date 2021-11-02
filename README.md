A complete flow from Project Zomboid map to deepzoom tile pyramid.

Preparations
============

Grab a copy of MapMap.exe from https://github.com/blind-coder/pz-mapmap and put it in the checked out repository.

Grab the map you want to convert and put it into a directory called "map/".

Copy the whole directory from Project Zomboid directory at %SteamApps%/projectzomboid/media/texturepacks/ into the checked out repository.

Converting
==========

Run `make` and wait. And wait. And wait. And then wait some more. Wait again. Until it's done. Also, wait a lot. The main Muldraugh map may take a week or two.

By default the ground floor (layer 0) will be converted. If you want another layer, delete some files and run `make` with the LAYER parameter:

```
rm -rf map.xml map_files tmp/output-*png tmp/Makefile.stitch tmp/stitch.ok tmp/Makefile.deepzoom work-*.png
make LAYER=1
```


Mono bug
========

There is a bug in Mono that prevents transparency from being correctly drawn resulting in weird look of the map. See https://github.com/blind-coder/pz-mapmap/tree/master/MonoTransparanceBug for details. I suggest to run MapMap.exe on Windows instead of Linux because of that.

I did report that bug to the Mono project way back when, but they told me they wouldn't even file a ticket for it unless I also provided them with a fix for it. I do not know enough about Mono and image manipulation to do that, so Mono will continue to be broken unless someone else picks this up.

**UPDATE**: This may be fixed by now, needs investigating.
