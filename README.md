# The game

Scoundrel is a single player rogue-like card game by Zach Gage and Kurt Bieg.

[Original rules](http://stfj.net/art/2011/Scoundrel.pdf)

Although this implementation strictly follows all these rules, it does not include any mentions of playing cards in the interface: I think this could break the immersion.

# Implementation

I used to use `jq` only to extract a JSON field. One day I wanted to get to know `jq` a little better — this is the result.

The code almost certainly has some formatting issues: unfortunately, I did not find any official (more or less) `jq` beautifier. Also, I had never tried any serious functional programming before. Nevertheless, it works.

The main restriction I followed was not using any external programs (i.e., `system()`). 

# How to run

```
jq --null-input -f main.jq --slurpfile data data.json --raw-output
```
