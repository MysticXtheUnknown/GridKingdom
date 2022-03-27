data = {}
data.maptiles = {}
data.maptiles[1] = { --swamp
name = "swamp",
sym = "%",
col = "brown"
}
data.maptiles[2] = { --forest
["name"] = "forest",
["sym"] = "#",
["col"] = "green"
}
data.maptiles[3] = { --meadow
["name"] = "meadow",
["sym"] = ".",
["col"] = "green"
}
data.maptiles[4] = { --barren
["name"] = "barren",
["sym"] = ",",
["col"] = "gray"
}
data.maptiles[5] = { --mountain
["name"] = "mountain",
["sym"] = "^",
["col"] = "gray",
["good_for"] = "castle or quarry"
}

data.special = {} -- mineral deposits, bonuses, etc STARTS AT 1!!!

data.special[1] = { 
["name"] = "mineral deposit",
["sym"] = "*",
["col"] = "gray",
["bonus"] = {minerals = 2},
["desc"] = "2x mineral prod"
}

data.special[2] = {
["name"] = "fertile",
["sym"] = "*",
["col"] = "gray",
["bonus"] = {food = 2},
["desc"] = "2x food prod"
}

data.special[3] = {
["name"] = "infertile",
["sym"] = "*",
["col"] = "gray",
["bonus"] = {food = 0.5},
["desc"] = "50% food prod"
}

data.special[4] = {
["name"] = "verdant valley",
["sym"] = "*",
["col"] = "gray",
["bonus"] = {gold = 2},
["desc"] = "2x gold"
}

data.special[5] = {
["name"] = "defensible",
["sym"] = "*",
["col"] = "gray",
["bonus"] = {security = 2},
["desc"] = "2x security"
}

data.special[6] = {
["name"] = "Lush",
["sym"] = "*",
["col"] = "gray",
["bonus"] = {wood = 2},
["desc"] = "2x wood"
}



data.buildable = {}
data.buildable["Foresters Camp"] = {
name = "Foresters Camp",
desc="Generates some food and wood",
sym = "F",
col = "yellow",
shortcut="F",
want_civ = "is_civilization", --10 to any village, town, or city
generates = { wood = 10,food = 10 },
drains = { gold = 2, population = 10},
requires_tile = "forest",
tile_penalty = 0.25,
cost = {wood = 0},
kingdom_zoom = 1
}

data.buildable["Road"] = {
name = "Road",
sym = "r",
col = 3, --3 is light blue
kingdom_zoom = 0,
path_cost = 0.1,
shortcut = "r",
is_road = true,
cost = {wood = 0}
}

data.buildable["Path"] = { --dropped by nomads
name = "Path",
sym = "r",
col = "white", --3 is light blue
kingdom_zoom = 0,
path_cost = 0.1,
shortcut = "p",
cost = {wood = 0}
}

data.buildable["City Wall"] = {
name = "City Wall",
sym = "#",
col = 12, --12 is light red pink?
kingdom_zoom = 0,
path_cost = 1000, --will jump walls sometimes?
shortcut = "w",
cost = {wood = 0}
}

data.buildable["Quarry"] = {
name = "Quarry",
desc="Generates some stone",
sym = "Q",
col = "yellow",
shortcut="q",
want_civ = "is_civilization", --10 to any village, town, or city
generates = { stone = 10 },
drains = { gold = 5 },
requires_tile = "mountain",
tile_penalty = 0.25,
cost = { lumber = 100 },
kingdom_zoom = 1
}

data.buildable["Mine"] = {
name = "Mineral Mine",
desc="Generates some minerals",
sym = "M",
col = "yellow",
shortcut="m",
want_civ = "is_civilization", --10 to any village, town, or city
generates = { minerals = 10 },
drains = { gold = 5 },
requires_tile = "mountain",
tile_penalty = 0.25,
cost = { lumber = 100 },
kingdom_zoom = 1
}

data.buildable["Sawmill"] = {
name = "Lumber Mill",
desc="turns wood into lumber",
sym = "L",
col = "blue",
shortcut="L",
want_civ = "is_civilization", --10 to any village, town, or city
generates = { lumber = 10 },
drains = { gold = 5, wood = 10 },
cost = { wood = 100 },
kingdom_zoom = 1
}

data.buildable["Stonecutter"] = {
name = "Stone Cutter",
desc="turns stone into cut stone",
sym = "c",
col = "white",
shortcut="l",
want_civ = "is_civilization", --10 to any village, town, or city
generates = { ["cut stone"] = 10 },
drains = { gold = 5, wood = 10 },
cost = { wood = 100 },
kingdom_zoom = 1
}

data.buildable["Farm"] = {
name = "Farm",
desc="Generates some food",
sym = "f",
col = "yellow",
shortcut="f",
requires_tile = "meadow",
tile_penalty = 0.25,
want_civ = "is_civilization",
generates = { food = 50 },
drains = { gold = 1 },
cost = { wood = 100 },
kingdom_zoom = 1
}

data.buildable["Smelter"] = {
name = "Smelter",
desc="A bloomery for production of iron",
sym = "B",
col = "blue",
shortcut="x",
--requires_tile = "meadow",
--tile_penalty = 0.25,
want_civ = "is_civilization",
generates = { iron = 10 },
drains = { gold = 1, minerals = 10 },
cost = { lumber = 100 },
kingdom_zoom = 1
}

data.buildable["Smithy"] = {
name = "Smithy",
desc="A smithy district with forges for turning iron into steel",
sym = "S",
col = 45,
shortcut="s",
--requires_tile = "meadow",
--tile_penalty = 0.25,
want_civ = "is_civilization" ,
generates = { steel = 10 },
drains = { gold = 1, iron = 10 },
cost = { lumber = 100 },
kingdom_zoom = 1
}


data.buildable["Village"] = {
name = "Village",
desc="A small town center (tier 0)",
sym = "V",
col = "yellow",
shortcut="v",
is_civilization = true,
--drains = {food = 200, wood = 10 },
--generates = { gold = 10 },
cost = { wood = 100, stone = 100, gold = 100},
nearby_bonus = 1, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 0,
in_game_help = "A village, left click menu item to build, then middle click the village on the map to zoom to the submap."
}

data.buildable["House"] = { --requires CIV!!!
name = "House",
desc="provides gold",
sym = "+",
col = 5,
shortcut="h",
want_civ = "is_market",
generates = { gold = 5, population = 10 },
drains = { food = 5 },
cost = { wood = 10 },
kingdom_zoom = 1
}

data.buildable["Stockpile"] = {
name = "Stockpile",
desc="place near farms, quarries, smelters, foresters, etc",
sym = "X",
col = "yellow",
shortcut="B",
is_civilization = true,
needs_roads = true,
cost = { wood = 10, stone = 10, gold = 10},
drains = { gold = 2 },
nearby_bonus = 1, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 1
}

data.buildable["Trading Hub"] = {
name = "Trading Hub",
desc="connect with roads to markets and stockpiles, otherwise, the nearby industries generate nothing.",
sym = "H",
col = "red",
shortcut="H",
road_hub = true,
cost = { wood = 0 },
--generates = { gold = 10 },
drains = {food = 200, wood = 10 },
generates = { gold = 10 },
--cost = { wood = 100, stone = 100, gold = 100},
--drains = { gold = 0 },
nearby_bonus = 1, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 1
}

data.buildable["Market"] = {
name = "Market",
desc="place near houses",
sym = "M",
col = "yellow",
shortcut="b",
is_market = true,
needs_roads = true,
cost = { wood = 10, stone = 10, gold = 10},
drains = { gold = 2 },
nearby_bonus = 1, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 1
}



data.buildable["Town"] = {
name = "Town",
desc="A medium size population center (tier 1)",
sym = "X",
col = 55, --yellow on blue background
shortcut=",",
is_civilization = true,
drains = {food = 500, wood = 100 },
generates = { gold = 100 },
cost = { lumber = 1000, stone = 1000, gold = 1000},
nearby_bonus = 2, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 0
}

data.buildable["Castle"] = {
name = "Castle",
desc="A Castle",
sym = "C",
col = "yellow",
shortcut="C",
is_civilization = false,
want_civ = "is_civilization",
drains = {food = 100, gold = 30,wood = 10},
generates = { security = 12 },
cost = { lumber = 300, wood = 100, stone = 1000, gold = 500},
requires_tile = "mountain",
tile_penalty = 0.5,
kingdom_zoom = 0
}

