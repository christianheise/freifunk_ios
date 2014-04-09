# Freifunk iOS App

The Support is currently limited to some Freifunk Regions (Hamburg, Jena, Kiel, Lübeck, Paderborn, Wuppertal, Dresden).

[Get the App](http://appstore.com/nofail/freifunk) in the iOS AppStore.

![screens](http://f.cl.ly/items/2A1z3r2b1s1B0Y392T3s/iOS%20Simulator%20Screen%20shot%2023.02.2014%2020.22.09.png)

## [GUIDE] add your region

In order to add another region to the app there are some steps that need to be taken:

YOUR PART:

* add all the [infos for a region](https://github.com/phoet/freifunk_ios/blob/master/app/01_models/region.rb)
  * Name
  * Location of `nodes.json` ie `http://graph.hamburg.freifunk.net/nodes.json`
  * Homepage ie `http://hamburg.freifunk.net/`
  * Twitter handle ie `FreifunkHH`

MY PART:
 
* build a new app version
* push the version to the iTunes Store

A new version might take [some time](http://appreviewtimes.com/) to be available through the AppStore!
