#!/bin/bash
KEYRUNE_DIR=~/dev/git-repos/MtG/Keyrune

SET_JSON=SetList.json
CARDS_JSON=AllPrintings.json

SET_ALL=AllSets.txt
SET_DRAFT=LargeSetList.txt
SET_EXTRA=SmallSetList.txt

INPUT_ALL=AllSets.input
INPUT_DRAFT=LargeSetList.input
INPUT_EXTRA=SmallSetList.input

###########################################################
# Generates 3 folders full of STLs.
# The first is for small sets. These don't have any mana symbol in the divider, only the set symbol. Ideal for sets like Signature Spellbooks or Commander Precons, where all the cards are going to just be color imbalanced, as well as for Duel Decks where you may not want to sort them at all and keep them together by deck.
# The second folder is by mana symbol first, then by set symbol. I use these for rare boxes, where I want the cards by color identity, separated by set.
# The thrid and final folder is by set symbol first, then divided by mana symbol. I use these for bulk commons and uncommons where I store them by set, separated by color. 
# If you want a different organization scheme, feel free to tweak the code to get your desired organizational outcome!
##########################################################

# Functions
## Address any bugs in mtgjson before analyzing
apply_fixes() {
  #Fix for incorrect Duel Deck code
  sed -i 's/DD1/EVG/' "$1"
}

## removes old files and replaces with an empty file
reset() {
  rm "$1" 2>/dev/null
  touch "$1"
}

## finds the unicode code in the cheatsheet and echos out the unicode character to the file along with its keyrune code
read_set() {
  foundStart=false
  while read set_code
  do
    if [ "${set_code}" = "${STARTING_DRAFT_SET}" ] || [ "${set_code}" = "${STARTING_EXTRA_SET}" ]
    then
      foundStart=true
    fi
    if [ "${foundStart}" = "true" ]
    then
      grep -i " ss-$set_code " ${KEYRUNE_DIR}/docs/cheatsheet.html  | cut -f 3 -d'>' | cut -f 1 -d';' | sed 's/&#x/\\u/' | ascii2uni -a U -q | tr -d '\n' >> $2
      echo " $set_code" >> "$2"
    else
      echo "Skipping $set_code"
    fi
  done < "$1"
}

#Main Body
STARTING_DRAFT_SET=${1:-LEA}
STARTING_EXTRA_SET=${2:-BRB}

echo "Removing stale files"
find . -name "${SET_JSON}" -mtime +7 -delete
find . -name "${CARDS_JSON}" -mtime +7 -delete
if [ -f ${SET_JSON} ]
then
  echo "${SET_JSON} is not stale, keeping previous copy"
else
  rm ${SET_JSON}.gz 2>/dev/null
  echo "Fetching ${SET_JSON} from https://mtgjson.com/api/v5/${SET_JSON}.gz"
  rm ${SET_JSON} 2>/dev/null
  curl "https://mtgjson.com/api/v5/${SET_JSON}.gz" -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Alt-Used: mtgjson.com' -H 'Connection: keep-alive' -H 'Referer: https://mtgjson.com/downloads/all-files/' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'TE: trailers' --output ${SET_JSON}.gz
  gunzip ${SET_JSON}.gz
  echo "Done."
fi

if [ -f ${CARDS_JSON} ]
then
  echo "${CARDS_JSON} is not stale, keeping previous copy"
else
  rm ${CARDS_JSON}.gz 2>/dev/null
  echo "Fetching ${CARDS_JSON} from https://mtgjson.com/api/v5/${CARDS_JSON}.gz"
  rm ${CARDS_JSON} 2>/dev/null
  curl "https://mtgjson.com/api/v5/${CARDS_JSON}.gz" -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:101.0) Gecko/20100101 Firefox/101.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Alt-Used: mtgjson.com' -H 'Connection: keep-alive' -H 'Referer: https://mtgjson.com/downloads/all-files/' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'TE: trailers' > ${CARDS_JSON}.gz
  gunzip ${CARDS_JSON}.gz
  echo "Done."
fi
echo



# jq query explanation, line by line
# sorts by release date for ordering codes
# selects array
# skips online only sets, like Vintage Masters
# skips foreign only sets, like Renaissance
# ignores Summer Magic, Media Inserts, and a catch all that doesn't even exist
# Filters out a few more specific sets, mostly guild kits, some foreign sets, welcome decks, and some oddities. Also filters out the list, as the symbol is the same as Mystery Booster and it sort of doesn't have a release date
# Filters out types of sets that make no sense for this project
# (sub lists only) splits the contents of the two lists. These statements are identical, except one negates the expression.
# Duel Decks Anthology just ends up creating duplicate symbols of their original duel deck printing
# Eliminates products that are sub products of others, essentially deduplicates codes. For example, a set's box toppers are listed under the same set code but with a different entry in mtgjson
# Spits out the keyrune codes to a file

echo "Large sets are core sets, expansions, draft innovation sets (like battlebond), starter sets, masters sets, and unsets."
echo "Small sets are everything else that is available in paper that is a normal magic card"

echo "Removing undesired sets and creating sub lists of Keyrune codes for both small and large sets..."
jq '.data
| sort_by(.releaseDate)
| .[]
| select(.isOnlineOnly == true | not )
| select(.isForeignOnly == true | not )
| select( .keyruneCode as $key | ["PSUM", "PMEI", "DEFAULT"] | index($key) | not )
| select( .code as $key | ["PHUK", "GK1", "GK2", "DBL", "PLIST", "PTG", "W16", "W17", "H17", "ATH", "ITP", "MGB", "JMP"] | index($key) | not )
| select( .type as $key | ["alchemy", "masterpiece", "memorabilia", "promo", "token", "treasure_chest", "vanguard"] | index($key) | not )
| select( .name | startswith("Duel Decks Anthology") | not )
| select( has("parentCode") | not )
| .keyruneCode' $SET_JSON | tr -d '"' > $SET_ALL

jq '.data
| sort_by(.releaseDate)
| .[]
| select(.isOnlineOnly == true | not )
| select(.isForeignOnly == true | not )
| select( .keyruneCode as $key | ["PSUM", "PMEI", "DEFAULT"] | index($key) | not )
| select( .code as $key | ["PHUK", "GK1", "GK2", "DBL", "PLIST", "PTG", "W16", "W17", "H17", "ATH", "ITP", "MGB", "JMP"] | index($key) | not )
| select( .type as $key | ["alchemy", "masterpiece", "memorabilia", "promo", "token", "treasure_chest", "vanguard"] | index($key) | not )
| select( .type as $key | ["core", "expansion", "draft_innovation", "starter", "masters", "funny"] | index($key) )
| select( .name | startswith("Duel Decks Anthology") | not )
| select( has("parentCode") | not )
| .keyruneCode' $SET_JSON | tr -d '"' > $SET_DRAFT

jq '.data
| sort_by(.releaseDate)
| .[]
| select(.isOnlineOnly == true | not )
| select(.isForeignOnly == true | not )
| select( .keyruneCode as $key | ["PSUM", "PMEI", "DEFAULT"] | index($key) | not )
| select( .code as $key | ["PHUK", "GK1", "GK2", "DBL", "PLIST", "PTG", "W16", "W17", "H17", "ATH", "ITP", "MGB", "JMP"] | index($key) | not )
| select( .type as $key | ["alchemy", "masterpiece", "memorabilia", "promo", "token", "treasure_chest", "vanguard"] | index($key) | not )
| select( .type as $key | ["core", "expansion", "draft_innovation", "starter", "masters", "funny"] | index($key) | not)
| select( .name | startswith("Duel Decks Anthology") | not )
| select( has("parentCode") | not )
| .keyruneCode' $SET_JSON | tr -d '"' > $SET_EXTRA
echo "Done."
echo

echo "Applying any bug fixes to the data in the generated lists..."
apply_fixes $SET_ALL
apply_fixes $SET_DRAFT
apply_fixes $SET_EXTRA
echo "Done."
echo

echo "Converting keyrune codes into generation input files with the code and the unicode character together..."
reset $INPUT_ALL
reset $INPUT_DRAFT
reset $INPUT_EXTRA

pushd ${KEYRUNE_DIR}
git pull
popd

read_set $SET_ALL $INPUT_ALL
read_set $SET_DRAFT $INPUT_DRAFT
read_set $SET_EXTRA $INPUT_EXTRA
echo "Done."
echo

echo Kill it now if you do not want to regenerate your files!
sleep 5s

echo "Generate STLs from the various lists..."
echo "Generate STLs for the small sets by set, without any mana symbol..."
# ./generate_stls_from_json_no_mana.sh $INPUT_EXTRA ./mana_symbol_none ./CardBoxDivider.scad
echo "Generate STLs for the large sets by set first, then by mana symbol..."
# ./generate_stls_from_json_by_set.sh $INPUT_DRAFT ./mana_symbol_order_right ./CardBoxDivider.scad
echo "Generate STLs for the large sets by mana symbol first, then by set..."
 ./generate_stls_from_json_by_mana.sh $INPUT_DRAFT ./mana_symbol_order_right ./CardBoxDivider.scad
echo "Generate STLs for the large sets by set..."
 ./generate_stls_from_json_no_mana.sh $INPUT_DRAFT ./mana_symbol_none ./CardBoxDivider.scad
echo "Done."
echo
