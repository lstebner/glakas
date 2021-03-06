# glakas

this document should be a piece of documentation for how all things under the hood are architected. please keep it updated.

# game components overview

- World: this represents a collection of Maps, which the player explores 
- Map: Maps are a collection of Cells which can be explored by the player
- Player: the Player is the in-game-world representation of the player of the game. it can move around, interact, craft tools, eat food, and so on. it carrys a Backpack and has Energy which are some core functionality of the game.
- Cell: A Cell is a single tile of a map. each one has unique properties that dictate how it is rendered and how it behaves when the user interacts with it.
  - type: A general key used to identify the cell
  - cell_props: Special properties related to the cell that differ based on type
- Gem: certain cells contain Gems and the players main goal is collecting these Gems. 
  - gems come in different colors which can be matched to be collected
- Gold: some cells contain gold which can be collected to create keys (and some other stuff tbd)
- Food: some cells contain food which can be eaten to restore energy
- Backpack: the backpack is where the player carries items to move around the map. it can be upgraded to whole more items, but initially can hold up to 3 things
- Energy: the player spends energy to move and do actions like chopping and mining. 
- Tree: some cells contain trees which can be chopped down for wood. some trees have fruited and leave food for the player after they are harvested
  - Forest: a collection of trees, typically 2x2, 3x3, or 4x4
  - Tree Sapling: a tree sprout that will one day grow in to a full blown tree
- Water: water tiles cannot be passed through by the player. 
  - Lake: a collection of water tiles surrounded by trees
  - River: a line of water tiles in a row
- Mushrooms: a rare growing source of energy
- Axe: an item that the player can create to harvest trees more efficiently
- Pickaxe: an item that the player must create to mine gems and gold
- Shovel: an item that the player can create to be able to move tree saplings
- Chest: a special item that spawns in cells and contains rewards or useful item



# World

props = {
  maps = []
  num_maps = #
  current_map = nil
}

- create: create a game world based on properties passed in. mainly: create maps for the world and create the player
- create_map: create a map and add to the current world's maps list
- create_player: create a player to exist in the world
- player_position: player's current position in the world
- player_cell: current cell the player is on top of
- current_map: the current map the player is inside of
- maps: the list of maps in the current world
- load_map: load one of the maps in to the current_map
- update_world: a hook for all cells to listen for an update


# Map

props = {
  idx = #
  rows = #
  cols = #
  total_cells = #
  cells = []
  grid_size = #
}

- create: creates a set of cells that represent an area the player can explore
- create_cells: uses a set of rules to create all the cells in the map
- create_cell: creates a single cell of a specified cell type
- create_door: creates a special cell type that connects to another map in the world
- empty_cell: changes a cell to an empty cell
- get_neighboring_cells: gets the cells that touch a specified cell 
- get_surrounding_cells: gets all cells around a specified cell
- get_cells_of_type: gets all cells of a specified type
- is_player_on: checks if the player is on a certain cell type
- player_cell: get the current cell the player is on
- player_pos: get the player's position in the map
- update_map: updates a map, called by World#update_world
- is_active_map: tells if a map is the one the player is currently in or not
- log_msg: add a message to the msg_log


# Player

props = {
  pos = #
  cur_map_idx = #
  backpack = Backpack
  energy = #
  max_energy = #
  last_move_time = #
  last_tool_time = #
  num_steps = #
  size = #
  tools = []
  msg_log = []
  num_tents_built = #
}

static ENERGY_REQS = {
  pickaxe = #
  axe = #
  shovel = #
  hand = #
}

static WOOD_REQS = {
  create_axe = #
  create_pickaxe = #
  create_shovel = #
  create_tent = #
}

static GOLD_REQS = {
  create_key = #
}

- create: creates a player
- create_backpack: creates the player's backpack
- upgrade_backpack: upgrades the player's backpack
- create_key: uses gold to create a key and stores it in the backpack
- use_key: removes a key from the inventory
- open_chest: uses key(s) to open a chest
- move: moves the player in a given direction
- move_to: moves the player to a specific cell
- add_item_to_backpack: add something to the backpack
- drop_item_from_backpack: drops the top item in the backpack
- swap_item_in_backpack: swaps the topmost item with another item
- create_tool: creates a tool, using up wood
- use_tool: uses the applicable tool on the current cell
- collect_wood: collects wood in the backpack
- collect_gold:
- collect_gem:
- eat_food: eats food from a cell or backpack
- collect_food: collects food in the backpack
- build_tent: builds a tent using wood
- sleep: sleeps for awhile to regain energy
- wake_up: wake the player up from sleeping


# Cell

props = {
  type: ""
  props: {}
  idx: #
  map_idx: #
  x: #
  y: #
  size: #
}

- create:
- get_cell_props:
- disguise_cell:
- undisguise_cell:
- update: 
- collect: 

## Cell.Tree

- create
- create_forest
- create_tree_sapling
- grow_tree
- grow_trees_in_map
- fruit_tree
- grow_tree_sapling
- collect

## Cell.Food

static TYPES = []

static ENERGY_VALS = {
  mushroom = #
  apple = #
}

- create
- collect

## Cell.Door

- create
- get_connecting_map

## Cell.Chest

- create
- open
- get_containing_item
- collect: 

## Cell.Mushroom

- create:
- collect:

## Cell.Water

- create:
- create_lake:
- create_stream:

## Cell.Gold

- create:
- get_value:

## Cell.Gem

static TYPES = []

- create:
- get_type:


# Backpack

props = {
  gold = #
  wood = #  
  keys = #
  foods = []
  cells = []
  max_cells = #
  max_foods = #
  max_wood = #
}

- create:
- add_item:
- remove_item:
- get_item_at:
- get_first_item:
- get_last_item:
- get_items:
- num_items:
- upgrade_capacity:
- shift_items: 

# Tool

props = {
  type = #
  energy_req = #
  wood_to_build = #
  built = bool
  name = ""
  status = #
  max_repair_value = #
}

static image = nil

- create:
- use:
- repair: 
- needs_repair: 



