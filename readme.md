# glakas

An adventure based puzzle game

## Rewrite Branch

This branch is a rewrite of the `master` branch which is the prototype as of now. This rewrite aims to make things much more organized as far as "classes" go and to make things more easily expandable. It also adds proper test coverage and is currently being developed in a TDD fashion. Check out the `docs/architecture*` files for an overview on game objects.

*this branch will not currently build without errors. please check out the master branch for the prototype game*

## Tests

Test me! Run `busted test/ --shuffle` to execute all tests.

## tiles

movement is based on tiles and the player moves one tile per move. some tiles can not be moved through and the player must go around them. 

- empty tile: tiles are empty by default; anything the player picks up can be put down on an empty tile
- gem (gem_blue, gem_orange, gem_*): gems can be mined with the pickaxe. mining gems is the most common interaction the player will have.
- door (door_up, door_down): doors lead to other rooms. up/down are simply names that mean next/prev in terms of sequential rooms. more arrangements can be added.
- gold: gold can be collected and used for keys and backpack upgrades. it requires the pickaxe to be mined.
- tree: trees can be chopped down or foraged to collect wood. if the player has the axe, then the tree will be chopped. if the player does not yet have the axe, it will be foraged. 
- water: water tiles are impassible. 
- stone: stone tiles are also impassible.
- food: food can be foraged and eaten for energy.
- chest: chests can be opened with keys. they contain prizes for the player

## rooms

the game "maps" are split in to rooms. each room can have different properties as to what tiles exist there. this is done by specifying "weights" to the tile generator. 


## player actions

the player's main goal is to mine gems, but this costs energy so the player must forage for food in order to maintain a positive energy. (see more in 'energy' section)

in order to mine gems, the player must create a pickaxe. they are also able to create an axe, which makes obtaining wood easier. without any tools, they are only able to forage. (see more in 'tools' section)

to assist with mining, the player wears around a backpack. although it can store an unlimited amount of wood and gold (magically), it can only store 3 gems at a time (this amount can be upgraded later on*). managing the backpack is an important part of the game. see below for some gem movement controls and then the 'backpack' section for the rest.

player movement:
  - arrow keys: move the player one tile at a time.

main actions (space bar):
  - foraging: player's can forage for food and also wood. it is recommended the axe is made as soon as possible though. food is eaten as soon as it is obtained.
  - chopping: player's can chop down trees once they have created the axe. when a tree is chopped down with the axe, all trees that touch will also be chopped down. if there are 5 trees chopped down at once, the player is rewarded with fruit.
  - mining: the player can mine gems once they have created the pickaxe. when a gem is mined, all gems that touch are also mined. mining costs energy so it is important to minimize the swings you take. gold can also be mined and collected. when 5 items are mined at once (the max possible) there is a random opportunity for a tree to sprout, or fruit to appear. gold is also subject to bonus gold when matches combos > 2.
  - enter door/stairs: follow any sort of room exit to the next room.

gem movement:
  - 'c': collect a gem. pick up gems from the ground and put them in the player's backpack.
  - 'v': put down the topmost item from the backpack. items can only be put down on empty tiles
  - 'x': swap the current tile with the topmost item from the backpack. this let's you put down a piece at the same time that you pick up a new one.

item creation:
  - 'a': create axe, requires 3 wood
  - 's': create pickaxe, requires 4 wood
  - 'd': create key, requires 10 gold


## tools

- axe: the axe requires 3 wood to be created and can be used to chop down trees more efficiently. the axe is not required to obtain wood, but makes it possible to destroy more than one tile at a time.
- pickaxe: the axe requires 4 wood to be created and is required in order to mine any resources. the main purpose of the game is mine gems, but you can also mine gold to obtain other items such as keys and tool upgrades.

*tool upgrades to come in the future.


## game flow

