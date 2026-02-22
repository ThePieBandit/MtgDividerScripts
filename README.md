# MtgDividerScripts
Linux Shell scripts that generate STLs for https://www.thingiverse.com/thing:3753832

## Prerequisites

1. Clone a copy of https://github.com/andrewgioia/Keyrune.
2. Update `update_set_order.sh` to point to the location you cloned your copy of Keyrune.

## How to use

Primarily, you will run `update_set_order.sh`. This will query https://www.mtgjson.com/ and download a `tar.gz` of all sets that exist. Then it will generate a series of STLs, in order, using `CardBoxDivider.scad` with the properties of `CardBoxDivider.json`. This script optionally takes the 3 letter code to start at, so if you have a more modern collection, you don't have to waste time generating STLs for sets you don't care about. 

For example STLs, see the thingiverse link above.
