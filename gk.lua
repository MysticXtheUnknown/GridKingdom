--//GRID KINGDOMS\\--
--ideas:
--Nomad villages that move around and give 'want_civ'
--Nomad villages become cities if they step on a verdant square?
--Nomad villages cost gold but give want_civ resource bonuses to nearby buildings?
--Settlers - pathfind to verdant?

slang.init()
slang.mousemode(1,1)  --TO MAKE THE MOUSE WORK: RIGHT CLICK ON TERMINAL> CLICK DEFAULT > REMOVE QUICK_EDIT FROM OPTIONS.
slang.clear()

player_x = 10
player_y = 10 --start points

day = 0

resources = {}
resources.wood = 0
resources.food = 0 --these are per turn values incoming
resources.gold = 0
resources.stone = 0
resources.security = 0
resources.minerals = 0
resources.iron = 0
resources.steel = 0
resources.population = 0
resources.lumber = 0
resources["cut stone"] = 0

current_submap_outgoing = {}

current_submap_resources = {} --FOR DISPLAY ONLY, NOT GAME DATA

current_submap_resources.wood = 0
current_submap_resources.food = 0 --these are per turn values incoming
current_submap_resources.gold = 0
current_submap_resources.stone = 0
current_submap_resources.security = 0
current_submap_resources.minerals = 0
current_submap_resources.iron = 0
current_submap_resources.steel = 0
current_submap_resources.population = 0
current_submap_resources.lumber = 0
current_submap_resources["cut stone"] = 0

stockpile = {} --actual stockpile
stockpile.wood = 1000
stockpile.food = 10000
stockpile.gold = 1000
stockpile.stone = 1000
stockpile.security = 0
stockpile.minerals = 1000
stockpile.iron = 1000
stockpile.steel = 0
stockpile.population = 0
stockpile.lumber = 0
stockpile.lumber = 1000 --DEBUG
stockpile["cut stone"] = 0

outgoing = {} --outgoing
outgoing.food = 0
outgoing.wood = 0
outgoing.gold = 0
outgoing.stone = 0
outgoing.security = 0
outgoing.minerals = 0
outgoing.iron = 0
outgoing.steel = 0
outgoing.population = 0
outgoing.lumber = 0
outgoing["cut stone"] = 0

map_size_y = 50
map_size_x = 50
submap_size_y = 20
submap_size_x = 20

--map_size_y = 80 --map size --WORKS
--map_size_x = 80

--  cout << "\e[8;50;100t"; 

function preStart() --initializes map, terminal size
	math.randomseed( os.time() )
	local r,c = slang.dimensions()

	map_size_y = r - 5
	map_size_x = c - 30
end


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
drains = { gold = 2 },
requires_tile = "forest",
tile_penalty = 0.25,
cost = {wood = 0},
kingdom_zoom = 1
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
drains = { gold = 1, minerals = 20 },
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
drains = { gold = 1, minerals = 20 },
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
drains = {food = 200, wood = 10 },
generates = { gold = 100 },
cost = { wood = 100, stone = 100, gold = 100},
nearby_bonus = 1, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 0
}

data.buildable["House"] = { --requires CIV!!!
name = "House",
desc="provides gold",
sym = "+",
col = "yellow",
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
cost = { wood = 10, stone = 10, gold = 10},
drains = { gold = 2 },
nearby_bonus = 1, --1.0 * production of nearby buildings. stat increases on bigger cities. other building must have 'want civ'
kingdom_zoom = 1
}

data.buildable["Market"] = {
name = "Market",
desc="place near houses",
sym = "X",
col = "yellow",
shortcut="b",
is_market = true,
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
shortcut="x",
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
want_civ = true,
drains = {food = 100, gold = 30,wood = 10},
generates = { security = 12 },
cost = { lumber = 300, wood = 100, stone = 1000, gold = 500},
requires_tile = "mountain",
tile_penalty = 0.5,
kingdom_zoom = 0
}

content = {}
content.map = {}

function message(y,x,string)
	print(string)
	slang.gotorc(y,x)
	slang.writestring(string)
	slang.refresh()
end


function setColor(name)
print(name)
	if type(name) == "number" then slang.setcolor(name) return end
	if slang.colors[name] then slang.setcolor(slang.colors[name]) return end
	assert(slang.colors[name],"No color by name "..name)
	end

function getKey() --returns the pressed key.   waits for key to be pressed
	local act = -1 
	local b
	local x
	local y
--	slang.flushinput()
	while(true) do
	act, b, x, y = slang.getinput(1000) -- b? x and y are mouse. if mouse is pressed,
	--act = 'mouse'
	if act == 'mouse' then return "mouse", b, x, y end
	if act ~= -1 then return slang.ascii(act), b, x, y end
	end
end

function count_maptile_kinds() --counts kinds of map tiles
	local num = 0
	for k,v in pairs(data.maptiles) do
		num = num + 1
	end
	
return num
end

function countEntries(tab)

local count = 0
for k,v in pairs(tab) do
count = count + 1
end

return count
end

function copyObject(a,b)
for k,v in pairs(b) do
a[k] = v
end
end

function set_inherit(a,b)
	setmetatable(a,{["__index"] = b})
end

function generateMap(mapy,mapx,villagey,villagex)

local num_kinds = count_maptile_kinds()
local num_special = countEntries(data.special)
for y=0 , mapy , 1 do
for x=0 , mapx , 1 do
content.map[y] = content.map[y] or {}
content.map[y][x] = content.map[y][x] or {}

local r_num = math.random(1,num_kinds) --this table starts at one...

content.map[y][x]["land_tile_kind"] = r_num

content.map[y][x]["tile"] = {}

set_inherit(content.map[y][x]["tile"],data.maptiles[r_num])

copyObject(content.map[y][x]["tile"],data.maptiles[r_num])


if math.random(1,20) == 1 then
	local id = math.random(1,num_special) --this table starts at 0...
	content.map[y][x]["special"] = {}
	set_inherit(content.map[y][x]["special"],data.special[id])

end

--generate town map

  --end generate town map

end
end



end

function generateSubmap(y,x,villagey,villagex)

local num_kinds = count_maptile_kinds()

for y2=0,villagey,1 do
for x2=0,villagex,1 do

content.map[y][x][y2] = content.map[y][x][y2] or {}
content.map[y][x][y2][x2] = content.map[y][x][y2][x2] or {}
content.map[y][x]["already_generated"] = true
local spot = content.map[y][x][y2][x2]
local r_num = math.random(1,num_kinds)
spot["land_tile_kind"] = r_num

spot["tile"] = {}
set_inherit(spot["tile"],data.maptiles[r_num])
copyObject(spot["tile"],data.maptiles[r_num])
end end

end

function showPlayer()
slang.gotorc(player_y,player_x)
setColor("white")
slang.writestring("@")

end

function old_showMap(mapy,mapx)
for y=0,mapy, 1 do
for x=0,mapx, 1 do
local tile = content.map[y][x]["land_tile_kind"]
slang.gotorc(y,x)
setColor(data.maptiles[tile]["col"])
slang.writestring(data.maptiles[tile]["sym"])


end end
--show player build stuff on top

for y=0,mapy, 1 do
for x=0,mapx, 1 do

	local tile = content.map[y][x]

	if tile["player_building"] then
		slang.gotorc(y,x)
		setColor(tile["player_building"]["col"])
		slang.writestring(tile["player_building"]["sym"])
	end
	
end end --ends for loops

end --ends function

function showSpecial()
local mapy
local mapx

if zoom_level == 0 then
mapy = map_size_y
mapx = map_size_x
end

if zoom_level == 1 then
mapy = submap_size_y
mapx = submap_size_x
end


for y=0,mapy, 1 do
for x=0,mapx, 1 do
	local special = content.map[y][x]["special"]
	if special then
		slang.gotorc(y,x)
		setColor(special["col"])
		slang.writestring(special["sym"])
	end

end end
end

function showMap(command)
local mapy
local mapx
if zoom_level == 0 then
mapy = map_size_y
mapx = map_size_x
end

if zoom_level == 1 then
mapy = submap_size_y
mapx = submap_size_x
end

local map_data = current_map

local y = 0
local x = 0

for y=0,mapy,1 do
for x=0,mapx,1 do

local tile = map_data[y][x]["land_tile_kind"]
if not tile then return end --sanity
slang.gotorc(y,x)
setColor(data.maptiles[tile]["col"])
slang.writestring(data.maptiles[tile]["sym"])

end end

end

function showBuildings()


local map_data = current_map
local mapy
local mapx


if zoom_level == 0 then
mapy = map_size_y
mapx = map_size_x
end

if zoom_level == 1 then
mapy = submap_size_y
mapx = submap_size_x
end

local x = 0
local y = 0

for y=0,mapy, 1 do
for x=0,mapx, 1 do

	local tile = map_data[y][x]

	if tile["player_building"] then
		slang.gotorc(y,x)
		setColor(tile["player_building"]["col"])
		slang.writestring(tile["player_building"]["sym"])
	end
	
end end --ends for loops
end --ends function

function playerHasResources()
return true
end

function playerAddBuilding(kind,spoty,spotx)
--try to pay
if not current_map[spoty][spotx] then return end --outside of map

for k,v in pairs(kind["cost"]) do --check if i have enough resources in my stockpile.
if stockpile[k] < v and v ~= 0 then return end --0 cost, dont care.
end

for k,v in pairs(kind["cost"]) do --first, see if i have all ingredients.  For now, just spend it
stockpile[k] = stockpile[k] - v
end 

current_map[spoty][spotx]["player_building"] = {}
copyObject(current_map[spoty][spotx]["player_building"],kind)
end

function playerRemoveBuilding(spoty,spotx)
if not current_map[spoty][spotx]["player_building"] then return end --no building to deconstruct.
	for k,v in pairs(current_map[spoty][spotx]["player_building"]["cost"]) do
	stockpile[k] = stockpile[k] + v --reimburse materials
	end

 current_map[spoty][spotx]["player_building"] = nil
end

function player_build(spoty,spotx)

local line_data = {}

	local line = 0

		for k,v in pairs(data.buildable) do
		local meant_for_zoom = data.buildable[k]["kingdom_zoom"]
			if (not meant_for_zoom) or (meant_for_zoom and meant_for_zoom == zoom_level) then
				--save the entry to the line data
				line_data[line] = data.buildable[k]
				message(line,0,data.buildable[k]["shortcut"]..") "..data.buildable[k]["name"])
				line = line+1
			else
			--does nothing
			end
		end 
	
	
	local key, b, x, y = getKey()
	
	if key == "mouse" then --mouse click, see if its on a menu entry
		for k,v in pairs(line_data) do --go over the lines, see which one matches the click
			if k == y then --you clicked on a line
			playerAddBuilding(line_data[k],spoty,spotx)
			refresh_display()
			
			return
			
			end
		end
	end
	
	if key == "e" then --pressed 'remove building'
	playerRemoveBuilding(spoty,spotx)
	showMap()
	showSpecial()
	showBuildings()
	return
	end
	
	for k,v in pairs(data.buildable) do --build a building key
		if data.buildable[k]["shortcut"] == key and ( not data.buildable.kingdom_zoom or (data.buildable.kingdom_zoom == zoom_level )) then
			playerAddBuilding(data.buildable[k],spoty,spotx)
			refresh_display()
			return
		end
	end
	
	--you pressed an invalid key
	showMap()
	showSpecial()
	showBuildings()
	showPlayer()

end --ends function




function calc_distance_to_nearest(tile,startY,startX,map_data,mapy,mapx,key) --mapy and x are the map sizes

local best_distance = 100000 --impossible number

local savedx = 0
local savedy = 0

for y = 0,mapy,1 do
for x = 0,mapx,1 do

if map_data[y][x] then
local tileb = map_data[y][x]["player_building"]
if tileb and map_data[y][x]["player_building"][key] then
--found a city etc, calculate the distance.
local changeX = math.abs(startX - x)
local changeY = math.abs(startY - y);
local distance = ( (changeX^2) + (changeY^2) )

if distance < best_distance then 
	savedx = x
	savedy = y
	best_distance = distance 
end

end --ends if player building

end --ends if civilization

end end --ends double for.

if best_distance ~= 100000 then
best_distance = math.floor(math.sqrt(best_distance )) end

return best_distance,savedy,savedx

end

function getSecurity()

local sec = 0

for y = 0,map_size_y,1 do
for x = 0,map_size_x,1 do

local my_tile = content.map[y][x]
local modifier = 1
local special_mod = 1

if content.map[y][x]["player_building"] and content.map[y][x]["player_building"]["generates"] and
content.map[y][x]["player_building"]["generates"]["security"] then
	local on_tile = data.maptiles[ content.map[y][x]["land_tile_kind"] ] ["name"]
	local want_tile = content.map[y][x]["player_building"]["requires_tile"]
	if want_tile ~= on_tile then
		modifier = content.map[y][x]["player_building"]["tile_penalty"] 
	end
	
	if my_tile["special"] and my_tile["special"]["bonus"]["security"] then
	special_mod = my_tile["special"]["bonus"]["security"]
	end


sec = sec + ((content.map[y][x]["player_building"]["generates"]["security"] * modifier) * special_mod)

end

end end

return sec
end

function floorSubmapStockpile()

for k,v in pairs(current_submap_resources) do
current_submap_resources[k] = math.floor(v)
end

end

function calculateSubmapStockpile(command)

for k,v in pairs(resources) do --reset incoming/outgoing
current_submap_resources[k] = 0
current_submap_outgoing[k] = 0 
end

--ADD resources to the display data from the village at the map point
	local current_map_square = content.map[map_pos_y][map_pos_x]
	if current_map_square["player_building"] and current_map_square["player_building"]["generates"] 
	then
			for k,v in pairs(current_map_square["player_building"]["generates"]) do
			--	current_submap_resources[k] = current_submap_resources[k] or 0
				current_submap_resources[k] = current_submap_resources[k] + v
			end
			for k,v in pairs(current_map_square["player_building"]["drains"]) do
				current_submap_outgoing[k] = current_submap_outgoing[k] + v
			end
			
			
	end

--start iteration over the map

for y = 0,map_size_y,1 do
for x = 0,map_size_x,1 do

if content.map[y][x]["already_generated"] then --found a submap

	


for y2 = 0,submap_size_y,1 do --iterate over submap
for x2 = 0,submap_size_x,1 do

local penalty = 1 --for wrong tile
local near_bonus = 1 -- for 'want civ'
local effectiveness = 1 -- for want_civ
local special_bonus = 1 -- for special map additions like fertile tiles.
local security = 0

local special = content.map[y][x][y2][x2]["special"] --grab special bonus
			if special then
	
				for k2,v2 in pairs (special["bonus"]) do
					if k == k2 then --found a special bonus for this resource
						special_bonus = v2
					end
				end
			end

penalty,near_bonus,effectiveness = stockpileDetailSubmap(y2,x2,content.map[y][x])

local building = content.map[y][x][y2][x2]["player_building"]
if building then --found a player building, calculate drains and generates
		building["adjusted_resources"] = {}
		if building["generates"] then
			for k,v in pairs(building["generates"]) do
			
			resources[k] = resources[k] or 0 --sanity
			current_submap_resources[k] = current_submap_resources[k] or 0
			
		--	penalty,near_bonus,effectiveness = stockpileDetailSubmap(y2,x2,content.map[y][x])
			
		
			--uses v:
			local modifier = ( ((((v * effectiveness) * penalty) * near_bonus) * special_bonus) * (1.0 + security/100) )
			building["adjusted_resources"] = building["adjusted_resources"] or {} --for display only
			local adj_ob = building["adjusted_resources"]
			adj_ob[k] = adj_ob[k] or 0
			adj_ob[k] = adj_ob[k] + modifier

			if command ~= "for_display" then
			resources[k] = resources[k] + modifier --actual resource math, not for just display.
			end
			
			--only add for my x and y position on zoom 0 main map.
			
			if (y == player_y and x == player_x and zoom_level == 0) or (zoom_level == 1 and y == map_pos_y and x == map_pos_x) then
				current_submap_resources[k] = current_submap_resources[k] + modifier --just for display
			end
			
			end --ends  k,v in generates
		end --ends if building[generates
		
		if building["drains"] then --drain resources
			for k3,v3 in pairs(building["drains"]) do
			local add_amount = v3 * near_bonus
				if command ~= "for_display" then
					outgoing[k3] = outgoing[k3] or 0
					outgoing[k3] = outgoing[k3] + (add_amount)
				end

				if (zoom_level == 0 and x == player_x and y == player_y) or (zoom_level == 1 and y == map_pos_y and x == map_pos_x) then
				current_submap_outgoing[k3] = current_submap_outgoing[k3] + add_amount
				end
			end
		end
	
	

	--comment
	end --ends if building


end end --ends inner loop

end --ends if 'alraedy generated' 

end end --ends the iteration over the map




floorSubmapStockpile() --floors out the current_submap_resources display values

end --ends function

function finishStockpileCalc()

for k,v in pairs(stockpile) do
stockpile[k] = stockpile[k] or 0
resources[k] = resources[k] or 0
outgoing[k] = outgoing[k] or 0
stockpile[k] = math.floor(stockpile[k] + resources[k] - outgoing[k])
end

end

function stockpileDetailSubmap(y,x,map_data)

local penalty = 1 --for wrong tile
local near_bonus = 1 -- for 'want civ'
local effectiveness = 1 -- for want_civ
local special_bonus = 1 -- for special map additions like fertile tiles
local tile = map_data[y][x]
local distance
local nearx
local neary

if  map_data[y][x]["player_building"] and map_data[y][x]["player_building"]["requires_tile"] then
		local want_tile = map_data[y][x]["player_building"]["requires_tile"]
		local has_tile = data.maptiles[map_data[y][x]["land_tile_kind"] ] ["name"]
		penalty = map_data[y][x]["player_building"]["tile_penalty"]
		if want_tile == has_tile then penalty = 1 end --has wanted tile
	end
	
	if map_data[y][x]["player_building"] and map_data[y][x]["player_building"]["want_civ"] then
	local civ_kind  = map_data[y][x]["player_building"]["want_civ"]
		distance, neary,nearx = calc_distance_to_nearest(tile,y,x,map_data,submap_size_y,submap_size_x,civ_kind)
		if (nearx == 0 and neary == 0) or distance == 100000 then near_bonus = 0.1 else
		
		
		near_bonus = map_data[neary][nearx]["player_building"]["nearby_bonus"] end
		
		
		effectiveness = 1 / distance
		effectiveness = bounds(effectiveness,0,1);
		if distance >= 100000 then effectiveness = 0 end
	end
	
return penalty, near_bonus,effectiveness
end




function calculateStockpile()

stockpile.security = 0 --only this stat nils out each turn.
stockpile.population = 0 --nils out each turn

local security = getSecurity() --first, check security.   Security gives a percent bonus to ALL production. (gold, wood, etc)

for k,v in pairs(resources) do --reset incoming/outgoing
resources[k] = 0
outgoing[k] = 0
end

--iterate over the map, calculating generated and consumed resources.

for y = 0,map_size_y,1 do
for x = 0,map_size_x,1 do

local penalty = 1 --for wrong tile
local near_bonus = 1 -- for 'want civ'
local effectiveness = 1 -- for want_civ
local special_bonus = 1 -- for special map additions like fertile tiles.

local distance, nearx,neary
	
	if  content.map[y][x]["player_building"] and content.map[y][x]["player_building"]["requires_tile"] then
		local want_tile = content.map[y][x]["player_building"]["requires_tile"]
		local has_tile = data.maptiles[ content.map[y][x]["land_tile_kind"] ] ["name"]
		penalty = content.map[y][x]["player_building"]["tile_penalty"]
		if want_tile == has_tile then penalty = 1 end --has wanted tile
	end
	
	if content.map[y][x]["player_building"] and content.map[y][x]["player_building"]["want_civ"] then
		distance, neary,nearx = calc_distance_to_nearest(tile,y,x,content.map,map_size_y,map_size_x)
		if nearx == 0 and neary == 0 and distance == 100000 then near_bonus = 1 else
		
		
		near_bonus = content.map[neary][nearx]["player_building"]["nearby_bonus"]
	    end
		
		
		effectiveness = 1 / distance
		effectiveness = bounds(effectiveness,0,1);
		if distance >= 100000 then effectiveness = 0 end
	end

	local special = content.map[y][x]["special"]

if content.map[y][x]["player_building"] then --found a player building, calculate drains and generates


	local building = content.map[y][x]["player_building"]

if building["generates"] then
for k,v in pairs(building["generates"]) do
	resources[k] = resources[k] or 0
	
	if special then
	
		for k2,v2 in pairs (special["bonus"]) do
			if k == k2 then --found a special bonus for this resource
				special_bonus = v2
			end
		end
	end
	
	--save the adjusted value in the building	
	
	local amount_to_add = ( ((((v * effectiveness) * penalty) * near_bonus) * special_bonus) * (1.0 + security/100) )
	
	building["adjusted_resources"] = building["adjusted_resources"] or {} --for display only
	local adj_ob = building["adjusted_resources"]
	adj_ob[k] = adj_ob[k] or 0
	
	adj_ob[k] = adj_ob[k] + amount_to_add
	
	--save the incoming resource amount to game engine data (not just display)
	
	resources[k] = resources[k] + amount_to_add

end
end

if building["drains"] then
	for k,v in pairs(building["drains"]) do
	outgoing[k] = outgoing[k] or 0
	outgoing[k] = outgoing[k] + v
	end
end



end

end end --end for x, for y
	

end

--distance of 10.  pref distance of 10. result is 0.1
--distance of 5. pref distance of 10. result is 0.5
--distance of 1, pref distance of 3, result is 1.0

function showIncomes() --and stockpile
local x
local y

if not x then x = player_x end
if not y then y = player_y end
local line = 0
--local y_loc = 81
local x_loc = map_size_x + 1

--display tile info for standing on map
local on_tile_name = data.maptiles[ content.map[player_y][player_x]["land_tile_kind"] ] ["name"]
local is_good_for = data.maptiles[ content.map[player_y][player_x]["land_tile_kind"] ] ["good_for"] or "test"

slang.gotorc(line,x_loc)
setColor("white")
slang.writestring(on_tile_name..", good for: "..is_good_for.."          ")
line = line + 1

local special = content.map[y][x]["special"]

if special then
local desc = " "
if special.desc then desc = special.desc end
slang.gotorc(line,x_loc)
slang.writestring(special.name.." : "..desc)
line = line + 1
end


--if not resources then return end

	for k,v in pairs(stockpile) do
		local submap_production = current_submap_resources[k] or 0
		local submap_consumption = current_submap_outgoing[k] or 0
		
		slang.gotorc(line,x_loc)
		setColor("yellow")
		slang.writestring("(+"..submap_production.." -"..submap_consumption..")".."(+"..math.floor(resources[k]).." -"..math.floor(outgoing[k]).. ") "..k.." "..v.."            ")
		line = line + 1;
	end

end


function bounds(num,low,hi)
if num <= hi and num >= low then return num end
if num >= hi then return hi end
if num <= low then return low end
end

function erasePlayer(y,x)

if not current_map[y] or not current_map[y][x] then  --outside of map 
	slang.gotorc(y,x)
	slang.writechar(" ")
	return 
end

 -- sanity
local tile = current_map[y][x]["tile"]
 --no tile, skip
print("erasing tile")
slang.gotorc(y,x)
setColor(tile["col"])
slang.writechar(tile["sym"])

local special_tile = current_map[y][x]["special"]
if special_tile then
print("special tile")
slang.gotorc(y,x)
setColor(special_tile["col"])
slang.writechar(special_tile["sym"])
end

local building = current_map[y][x]["player_building"]
if building then
slang.gotorc(y,x)
setColor(building["col"])
slang.writechar(building["sym"])
end

end --ends function

function playerMove(changeY,changeX)
erasePlayer(player_y,player_x)

player_x = player_x + changeX
player_y = player_y + changeY

player_x = bounds(player_x,0,map_size_x)
player_y = bounds(player_y,0,map_size_y)
showPlayer()

if zoom_level == 0 then
map_pos_x = player_x
map_pos_y = player_y
end

end --ends function


function playerZoom(y,x,map_data)


--zoom in


if zoom_level == 0 
and content.map[y][x]["player_building"]
and content.map[y][x]["player_building"]["is_civilization"]
then

	if not content.map[y][x]["already_generated"] then
		generateSubmap(y,x,submap_size_y,submap_size_x) 
	end

	slang.clear()
	current_map = content.map[y][x]
	zoom_level = 1
	showMap() --same as generate submap
	showSpecial()
	showBuildings()
	return
end


--zoom out
if zoom_level == 1 then -- we are zoomed in currently so zoom out

--first, nil out the old data
--for k,v in pairs(resources) do
--current_submap_resources[k] = 0
--current_submap_outgoing[k] = 0
--end
current_map = content.map
zoom_level = 0

player_x = map_pos_x
player_y = map_pos_y --reset the cursor to the overmaps last position.

showMap()
showSpecial()
showBuildings()
return
end

end

function printSlangLibraryNames()
	--list slang libraries
	local line = 0
	for k,v in pairs(slang) do
		slang.gotorc(line,0)
		slang.writestring(k)
		line = line + 1
	end
	slang.refresh()
	getKey()
end


function singleClick(y,x) --right single click
displayEntityInfo(y,x)
end

function displayInfoForOneEntity(k,v,line,building)
setColor("white")
if type(v) == "number" or type(v) == "string" then
slang.gotorc(line,0)
slang.writestring(k.." = "..v)
line = line + 1
end
if k == "generates" then
	for k2, v2 in pairs (building["generates"]) do
		slang.gotorc(line,0)
		slang.writestring("Generates "..v2.." "..k2)
		line = line + 1
	end
end
if k == "drains" then
	for k2,v2 in pairs(building["drains"]) do
		slang.gotorc(line,0)
		slang.writestring("Drains "..v2.." "..k2)
		line = line + 1
	end
end

if k == "adjusted_resources" then --building has adjusted resources.
	for k2,v2 in pairs(building["adjusted_resources"]) do
		slang.gotorc(line,0)
		slang.writestring("Adjusted Income: "..v2.." "..k2)
		line = line + 1
	end 
end

return line
end

function displayEntityInfo(y,x)

local line = 0
local building = false

if not current_map[y] or not current_map[y][x] then return end --outside of map.


--if current_map[y][x]["player_building"] then
--building = current_map[y][x]["player_building"]
--end

--if current_map[y][x]["tile"] then
local building = current_map[y][x]["player_building"]
--tile_kind = current_map[y][x]["land_tile_kind"]
local tile = current_map[y][x]["tile"]
--end

if building then
for k,v in pairs(building) do
line = displayInfoForOneEntity(k,v,line,building)
end
end

if tile then
for k,v in pairs(tile) do
line = displayInfoForOneEntity(k,v,line,tile)
end
end

slang.refresh()
getKey()
refresh_display()


end


function refresh_display()
--slang.clear()
showMap();
showSpecial()
showBuildings()
showPlayer()
calculateSubmapStockpile("for_display")
showIncomes()
slang.refresh()
end


function main()
local key
local x
local y
local mbutton

key, mbutton, x, y = getKey();

if key == "b" then player_build(player_y,player_x) end



if key == "w" then playerMove(-1,0) end
if key == "a" then playerMove(0,-1) end
if key == "d" then playerMove(0,1) end
if key == "s" then playerMove(1,0) end
if key == "z" then playerZoom(player_y,player_x,content.map[player_y][player_x]) end

	if key == "0" then
	printSlangLibraryNames()
	--list slang libraries
	local line = 0
	for k,v in pairs(slang) do
		slang.gotorc(line,0)
		slang.writestring(k)
		line = line + 1
	end
	slang.refresh()
	getKey()
	end
	
	if key == "mouse" and  mbutton == 2 then --right button, display entity info (buildings, tiles)
	--single click r click

	singleClick(y,x);
--	elseif key == "mouse" and last_mouse == "mouse" and (last_mouse_x == x and last_mouse_y == y) then --double click
	elseif key == "mouse" and mbutton == 0 then --left click bring up build menu
--	key = "blank"
	slang.gotorc(y,x)
	slang.writestring("?")
	player_build(y,x)
	
	--slang.gotorc(y,x)
--	slang.writestring("Mouse!")
--	slang.refresh()
--	getKey();
	elseif key == "mouse" and mbutton == 1 then --middle click

	playerZoom(y,x,content.map[y][x])
	end

if key == "9" then --rerun the prestart to define map x and y size.
	preStart()
	generateMap(map_size_y,map_size_x)
	return
end


--showMap(map_size_y,map_size_x);
--showSpecial(map_size_y,map_size_x)
--showPlayer()



--calculate incomes once every seven days
if day == 7 then
	--calculateIncomes() --incomes and adds to stockpile

	calculateStockpile()
	calculateSubmapStockpile()
	finishStockpileCalc()
	day = 0
end

day = day + 1

calculateSubmapStockpile("for_display") -- each day

showIncomes() --show incomes and stockpile

slang.refresh();

last_mouse = key
last_mouse_x = x
last_mouse_y = y

end

--PRIMARY CODE:
--START:


--turn off flashing cursor
slang.showcursor(false)

dofile("mods/modlist.lua") --LOAD MODS AFTER ALL OTHER CODE IS DEFINED EXCEPT MAIN LOOP


preStart() --DEFINES MAP SIZE X AND Y
--GEN AND SHOW MAP:
generateMap(map_size_y,map_size_x)
current_map= content.map

zoom_level = 0 --start on world map, zoom level 0

map_pos_x = player_x
map_pos_y = player_y

showMap();
showSpecial()
showBuildings()
showPlayer()
slang.refresh()
--MAIN LOOP:

while(true) do
main()
end