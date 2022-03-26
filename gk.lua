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

dofile("code/russastar2d.lua")

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
stockpile.wood = 1000 * 100
stockpile.food = 10000
stockpile.gold = 1000 * 100
stockpile.stone = 1000 * 100
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

map_size_y = 50 --written over be preStart()
map_size_x = 50
submap_size_y = 20
submap_size_x = 20

content = {}
content.map = {}

fixed_tiles = {} --for fixing the numbered tiles in the map generation.

living_entities = {} --entities that pathfind
global_id = 0


--map_size_y = 80 --map size --WORKS
--map_size_x = 80

--  cout << "\e[8;50;100t"; 

function preStart() --initializes map, terminal size
	math.randomseed( os.time() )
	local r,c = slang.dimensions()

	map_size_y = r - 5
	map_size_x = c - 40
end

dofile("code/content.lua")


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

function fixTiles() --fixes the tile numbering problem with maptiles.  now maptiles key can be the word "swamp" instead of a number.
	local num = 1 --start at 1

	for k,v in pairs(data.maptiles) do --only used for map generation.
		fixed_tiles[num] = v
		
		for k2,v2 in pairs(v) do
		fixed_tiles[num][k2] = v2
		end
		
		num = num + 1
	end

	--data.maptiles = fixed_tiles
end --ends function

function generateMap(mapy,mapx,villagey,villagex)

fixTiles()

local num_kinds = count_maptile_kinds() --counts fixed_tiles
local num_special = countEntries(data.special)
for y=0 , mapy , 1 do
for x=0 , mapx , 1 do
content.map[y] = content.map[y] or {}
content.map[y][x] = content.map[y][x] or {}

local r_num = math.random(1,num_kinds) --this table starts at one...

--content.map[y][x]["land_tile_kind"] = r_num

content.map[y][x]["tile"] = {}

set_inherit(content.map[y][x]["tile"],fixed_tiles[r_num])

copyObject(content.map[y][x]["tile"],fixed_tiles[r_num])


if math.random(1,20) == 1 then
	local id = math.random(1,num_special) --this table starts at 0... was 1
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
--spot["land_tile_kind"] = r_num

spot["tile"] = {}
set_inherit(spot["tile"],fixed_tiles[r_num])
copyObject(spot["tile"],fixed_tiles[r_num])
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
local tile = content.map[y][x]["tile"]
slang.gotorc(y,x)
setColor(tile["col"])
slang.writestring(tile["sym"])


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

--local tile = map_data[y][x]["land_tile_kind"]

local tile = map_data[y][x]["tile"]

if not tile then return end --sanity
slang.gotorc(y,x)
setColor(tile["col"])
slang.writestring(tile["sym"])

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
		setColor(tile["player_building"]["use_col"] or tile["player_building"]["col"])
		slang.writestring(tile["player_building"]["sym"])
	end
	
end end --ends for loops
end --ends function


function specialdisplaymessage(message,y,x) --for getstring. old code.
	if x == nil then x = 3 end


	if y == nil then y = 0 end
	slang.gotorc(y,x)
	print("message ("..message..")  ")
	slang.writestring(message.."                                                                                      ")
	slang.refresh()
	return
end

function getString(printonline) --gets a string of chars, prints them on the line specified on the screen.
	local getkey = getKey
	local inn = "x"
	local bb = 1
	local tableaa= {}
	local str = ""
	while(inn ~= [[ret]]) do
		inn = getkey("any")
		if inn ~= "ret" and inn ~= "bs" then
			bb = bb+1
			specialdisplaymessage(inn,printonline,bb)
			tableaa[bb] = inn

			end
		if inn == "bs" then
			specialdisplaymessage(" ",printonline,bb)
			tableaa[bb] = nil
			bb = bb -1
			if bb < 1 then bb = 1 end
			end
	local checkstr = ""
	for k,v in pairs(tableaa) do
		if v ~= "ret" and v ~= "bs" then checkstr = checkstr..v end
	end
--	for k in pairs(list) do
--		if list[k]["name"] == checkstr then funcs.displaymessage(printonline+1,1,"That might work.") break end
--		if list[k]["name"] ~= checkstr then funcs.displaymessage(printonline+1,1,"That won't help.") end
--	end
	end --ends the do loop
	for k,v in pairs(tableaa) do --not ipairs but seems to get them in the right order anyway.
		if v ~= "ret" and v ~= "bs" then str = str..v end
	end
	print("string "..str)
	return str 
end

function playerHasResources()
return true
end

function createBuilding(kind,spoty,spotx)
current_map[spoty][spotx]["player_building"] = {}
copyObject(current_map[spoty][spotx]["player_building"],kind)
current_map[spoty][spotx]["player_building"]["x"] = spotx
current_map[spoty][spotx]["player_building"]["y"] = spoty
end

villages = {}

function playerAddBuilding(kind,spoty,spotx)
--try to pay
if not current_map[spoty][spotx] then return end --outside of map

for k,v in pairs(kind["cost"]) do --check if i have enough resources in my stockpile.
if stockpile[k] < v and v ~= 0 then return end --0 cost, dont care.
end

for k,v in pairs(kind["cost"]) do --first, see if i have all ingredients.  For now, just spend it
stockpile[k] = stockpile[k] - v
end

local name
if kind["name"] == "Village" or kind["name"] == "Castle" then
slang.gotorc(0,0)
slang.writestring("Type name then press enter)")
slang.refresh()
name = getString(1)
end

current_map[spoty][spotx]["player_building"] = {}
copyObject(current_map[spoty][spotx]["player_building"],kind)
current_map[spoty][spotx]["player_building"]["x"] = spotx
current_map[spoty][spotx]["player_building"]["y"] = spoty
if name then
	current_map[spoty][spotx]["player_building"]["custom_name"] = name
	end
	
	--if village, add to village list
	
	if kind["name"] == "Village" then
	villages[global_id] = current_map[spoty][spotx]["player_building"]
	global_id = global_id + 1
	end
--[[
if zoom_level == 0 then
resetSubmapStockpile()
calculateSubmapStockpile("for_display") --turns buildings red if no road connection
end

if zoom_level == 1 then
resetSubmapStockpile()
calcOneSubmapStockpile(map_pos_y,map_pos_x)
end
--]]
refresh_display()

end --ends function

function playerRemoveBuilding(spoty,spotx)
if not current_map[spoty][spotx]["player_building"] then return end --no building to deconstruct.
	
for k,v in pairs(current_map[spoty][spotx]["player_building"]["cost"]) do
	stockpile[k] = stockpile[k] + v --reimburse materials
end
	
	
	--remove from village list
if zoom_level == 0 then --main map
		local build = current_map[spoty][spotx]["player_building"]
		if build and build["name"] == "Village" then
			villages[build["id"]] = nil
		end
end

 current_map[spoty][spotx]["player_building"] = nil
end

function player_build(spoty,spotx)

local line_data = {}

	local line = 0

		for k,v in pairs(data.buildable) do --populate line_data
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
	
	if key == "mouse" and b == 0 then --mouse click, see if its on a menu entry
		for k,v in pairs(line_data) do --go over the lines, see which one matches the click
			if k == y then --you clicked on a line
			playerAddBuilding(line_data[k],spoty,spotx)
		--	refresh_display()
			
			return
			
			end
		end
	end
	
	if key == "mouse" and b == 2 then --right click, show data on the entity
		for k,v in pairs(line_data) do
			if k == y then
				displayMenuInfo(line_data[k])
			end
		end
	end
		
	if key == "e" then --pressed 'remove building'
	playerRemoveBuilding(spoty,spotx)
	resetSubmapStockpile()
	calculateSubmapStockpile("for_display")
	showMap()
	showSpecial()
	showBuildings()
	return
	end
	
	for k,v in pairs(data.buildable) do --build a building key
		if data.buildable[k]["shortcut"] == key and ( not data.buildable.kingdom_zoom or (data.buildable.kingdom_zoom == zoom_level )) then
			playerAddBuilding(data.buildable[k],spoty,spotx)
		--	refresh_display()
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
local on_tile = my_tile["tile"]["name"]

--	local on_tile = data.maptiles[ content.map[y][x]["land_tile_kind"] ] ["name"]
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

for k,v in pairs(current_submap_outgoing) do
current_submap_outgoing[k] = math.floor(v)
end

end

function findTradingPost(y,x,map_data) --returns x and y of trading post
for y3 = 0,submap_size_y,1 do
for x3 = 0,submap_size_x,1 do

if map_data[y3][x3]["player_building"] and map_data[y3][x3]["player_building"]["road_hub"] == true 
 then return y3,x3,true end

end
end
return -1,-1,false 
end

function calcOneSubmapStockpile(y,x,command)

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
			
			if effectiveness == 0 then building["use_col"] = 64 end --red color if no effectiveness, no effectiveness if no stockpile and trade hub.
			if effectiveness ~= 0 then building["use_col"] = nil end
			local modifier = ( v * effectiveness * penalty * near_bonus * special_bonus * (1.0 + security/100) )
			
			building["adjusted_resources"] = building["adjusted_resources"] or {} --for display only
			local adj_ob = building["adjusted_resources"]
			adj_ob[k] = adj_ob[k] or 0
			adj_ob[k] = adj_ob[k] + modifier

			if command ~= "for_display" then
			resources[k] = resources[k] + modifier --actual resource math, not for just display.
			end
			
			--only add for my x and y position on zoom 0 main map.
			
			if (y == y_spot and x == x_spot and zoom_level == 0) or (zoom_level == 1 and y == map_pos_y and x == map_pos_x) then
				current_submap_resources[k] = current_submap_resources[k] + modifier --just for display
			end
			
			end --ends  k,v in generates
		end --ends if building[generates
		
		if building["drains"] then --drain resources
			for k3,v3 in pairs(building["drains"]) do
			local add_amount = v3 * near_bonus * effectiveness
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
 
 floorSubmapStockpile()

end --end function

function resetSubmapStockpile()

for k,v in pairs(resources) do --reset incoming/outgoing
current_submap_resources[k] = 0
current_submap_outgoing[k] = 0 
end

end


function calculateSubmapStockpile(command,y_spot,x_spot)

local y_spot = map_pos_y
local x_spot = map_pos_x

for k,v in pairs(resources) do --reset incoming/outgoing
current_submap_resources[k] = 0
current_submap_outgoing[k] = 0 
end

--ADD resources to the display data from the village at the map point
	local current_map_square = content.map[y_spot][x_spot]
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

calcOneSubmapStockpile(y,x) end 

end end --ends the iteration over the map

floorSubmapStockpile() --floors out the current_submap_resources display values

end --ends function

function checkPathToTradeHub(neary,nearx,map_data,y,x)
local final_modifier = true

		local found
		local tradey
		local tradex
		tradey,tradex, found = findTradingPost(y,x,map_data) --find the trading post, 1 per submap
		-- if found == true, trading post exists.. ok, pathfind to it
		if found == false then final_modifier = false end --no trading post on map.
		
		if found == true then
			local distances, foundit = funcs.astarpathfind(nearx,neary,tradex,tradey,nil,nil,"stay_on_road",map_data ) --tile is mapdata
			--foundit is true on finding the destination.
			if not foundit then --couldnt find a path on the road to target

				final_modifier = false
			end --no road connection, generate nothing.
		
		end
return final_modifier end

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

local final_modifier = 1 -- stays 1 if there is a path to a trade hub.  stockpiles are treated as roads incidentally. see astar blockingpath function.

if  map_data[y][x]["player_building"] and map_data[y][x]["player_building"]["requires_tile"] then
		local want_tile = map_data[y][x]["player_building"]["requires_tile"]
		local has_tile = tile["tile"]["name"]
		penalty = map_data[y][x]["player_building"]["tile_penalty"]
		if want_tile == has_tile then penalty = 1 end --has wanted tile
	end
	
if map_data[y][x]["player_building"] and map_data[y][x]["player_building"]["want_civ"] then
		
		local civ_kind  = map_data[y][x]["player_building"]["want_civ"]
		distance, neary,nearx = calc_distance_to_nearest(tile,y,x,map_data,submap_size_y,submap_size_x,civ_kind)
	
		if (nearx == 0 and neary == 0) or distance == 100000 then near_bonus = 0.1 else
			near_bonus = map_data[neary][nearx]["player_building"]["nearby_bonus"]
		end
	
	
	if map_data[neary][nearx]["player_building"] and map_data[neary][nearx]["player_building"]["needs_roads"] then
		
		
	 --CHECK ROAD CONNECTIONS FOR "needs_roads" and 'road_hub' etc. 
	 --check path to trading post on roads.  if it exists, allow resource generation.
	local reached_dest = checkPathToTradeHub(neary,nearx,map_data,y,x)
	if not reached_dest then final_modifier = 0 end
	
	end
		
		
			effectiveness = (1- (distance/10)) * final_modifier 
--		effectiveness = (1 / distance) * final_modifier --final modifier is 0 if no path to trade hub for 'needs roads' buildings.
		effectiveness = bounds(effectiveness,0,1)
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
local tile = content.map[y][x]["tile"]
	
	if  content.map[y][x]["player_building"] and content.map[y][x]["player_building"]["requires_tile"] then
		local want_tile = content.map[y][x]["player_building"]["requires_tile"]
		local has_tile = tile["name"]
		penalty = content.map[y][x]["player_building"]["tile_penalty"]
		if want_tile == has_tile then penalty = 1 end --has wanted tile
	end
	
	if content.map[y][x]["player_building"] and content.map[y][x]["player_building"]["want_civ"] then
		distance, neary,nearx = calc_distance_to_nearest(tile,y,x,content.map,map_size_y,map_size_x,"is_civilization")
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
local amount_to_add

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
	
	amount_to_add = ( ((((v * effectiveness) * penalty) * near_bonus) * special_bonus) * (1.0 + security/100) )
	
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
	outgoing[k] = outgoing[k] + v --was v
	end
end



end

end end --end for x, for y
	

end

--distance of 10.  pref distance of 10. result is 0.1
--distance of 5. pref distance of 10. result is 0.5
--distance of 1, pref distance of 3, result is 1.0

function showIncomes(y,x) --and stockpile

if not x then x = player_x end
if not y then y = player_y end
local line = 0
--local y_loc = 81
local x_loc = map_size_x + 1

if not current_map[y] or not current_map[y][x] or not current_map[y][x]["tile"] then return end

local on_tile_name=current_map[y][x]["tile"]["name"]
local is_good_for = current_map[y][x]["tile"]["good_for"] or "no entry"

--display tile info for standing on map
--local on_tile_name = data.maptiles[ content.map[player_y][player_x]["land_tile_kind"] ] ["name"]
--local is_good_for = data.maptiles[ content.map[player_y][player_x]["land_tile_kind"] ] ["good_for"] or "test"

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
		slang.writestring(k.." (+"..submap_production.." -"..submap_consumption..")".."(+"..math.floor(resources[k]).." -"..math.floor(outgoing[k]).. ") "..v.."            ")
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
setColor(building["use_col"] or building["col"])
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
map_pos_x = x
map_pos_y = y


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


function rightClickOnMap(y,x) --right single click
map_pos_x = x
map_pos_y = y

displayEntityInfo(y,x)

--calcOneSubmapStockpile(y,x)
refresh_display()
--showIncomes(y,x)
slang.refresh()
getKey()
--refresh_display()
end

function displayInfoForOneEntity(k,v,line,building) --displays the info on a right clicked menu or map item.

if type(v) == "number" or type(v) == "string" then
slang.gotorc(line,0)
slang.writestring(k.." = "..v.."     ")
line = line + 1
end



if k == "generates" then
	for k2, v2 in pairs (building["generates"]) do
		slang.gotorc(line,0)
		slang.writestring("Generates "..v2.." "..k2.."     ")
		line = line + 1
	end
end
if k == "drains" then
	for k2,v2 in pairs(building["drains"]) do
		slang.gotorc(line,0)
		slang.writestring("Drains "..v2.." "..k2.."     ")
		line = line + 1
	end
end

if k == "adjusted_resources" then --building has adjusted resources.
	for k2,v2 in pairs(building["adjusted_resources"]) do
		slang.gotorc(line,0)
		slang.writestring("Adjusted Income: "..v2.." "..k2.."     ")
		line = line + 1
	end 
end
if k == "cost" then
	for k2,v2 in pairs(building["cost"]) do
	slang.gotorc(line,0)
	slang.writestring("Build Cost: "..v2.." "..k2.."     ")
	line = line + 1
	end
end


return line
end

function displayMenuInfo(building) --for r-click on the menu building

local line = 0
if building then
for k,v in pairs(building) do
line = displayInfoForOneEntity(k,v,line,building)
end
end

slang.refresh()
getKey()
refresh_display()

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

--local key,b,x2,y2 = getKey()
--if key == "mouse" and b == 2 then return displayEntityInfo(y2,x2) end --RIGHT CLICK DISPLAYS NEXT POINT OF DATA




end


function refresh_display()
--slang.clear()
showMap();
showSpecial()

if zoom_level == 0 then
resetSubmapStockpile()
calculateSubmapStockpile("for_display",player_y,player_x)
end
if zoom_level == 1 then
resetSubmapStockpile()
calcOneSubmapStockpile(map_pos_y,map_pos_x,"for_display")
end

showBuildings()
showPlayer()


showIncomes()
slang.refresh()
end

data.pathFindEntities = {}
data.pathFindEntities["nomad"] = {
kind = "nomad",
col = "white",
sym = "N",
native_zoom = 0
--makes_paths = true,
}
data.pathFindEntities["trader"] = {
kind = "trader",
col = "red",
sym = "T"

}


function spawn_nomad(y,x) --testing

living_entities[global_id] = {}

living_entities[global_id]["id"] = global_id
living_entities[global_id]["x"] = x
living_entities[global_id]["y"] = y

copyObject(living_entities[global_id],data.pathFindEntities["nomad"])

local nexty,nextx = selectRandom("is_civilization")

living_entities[global_id]["target"] = {}
living_entities[global_id]["target"]["x"] = nextx or 10
living_entities[global_id]["target"]["y"] = nexty or 10


living_entities[global_id]["zoom_level"] = zoom_level --which map am i on?

global_id = global_id + 1

end

function spawn_pathfind_entity(y,x,kind)

living_entities[global_id] = {}

living_entities[global_id]["id"] = global_id
living_entities[global_id]["x"] = x
living_entities[global_id]["y"] = y

copyObject(living_entities[global_id],data.pathFindEntities[kind])

local nexty,nextx = selectRandom("is_civilization")

living_entities[global_id]["target"] = {}
living_entities[global_id]["target"]["x"] = nextx or 10
living_entities[global_id]["target"]["y"] = nexty or 10

global_id = global_id + 1

end

function selectRandom(match_key) --eg match_key = 'is_civilization' etc selects a random 'is civ' on the map.

local entry = 0 --start at 1

local listx = {}
local listy = {}

for k,v in pairs(villages) do
	local build = villages[k]
	if build and build[match_key] then --found a castle or village on main map, add to list.
		entry = entry + 1
		listx[entry] = build["x"]
		listy[entry] = build["y"]
		
	end

end
	
	

--if entry == 1 then return 10,10 end --no villages

--use list to make a random choice
local choice = math.random(1,entry)
--print("choice "..choice)
--print("listx "..listx[choice])
--print("listy "..listy[choice])

return listy[choice], listx[choice] --y and x

end

function movePathfinders()
--	local y2 = 20
--	local x2 = 20 --pathfinding target, make getTarget() sometime
	
	
local x2
local y2
	
	local oldx
	local oldy
	
	local x
	local y
	
	for k,v in pairs(living_entities) do
	
	
	
		local ob = living_entities[k]
		
		
		
		x2 = ob["target"]["x"]
		y2 = ob["target"]["y"]
		
		x = ob["x"]
		y = ob["y"]

		oldx = x
		oldy = y
		
		made_move = funcs.moveEntityTowards(ob,x,y,x2,y2) --move one square towards x2,y2 with A*
	
	if ob["zoom_level"] == zoom_level then --if its on the same zoom level as me, erase and draw
		--erase the enetity
		
		erasePlayer(oldy,oldx) --erase
		
		--draw the entity
		slang.gotorc(living_entities[k]["y"],living_entities[k]["x"]) --draw
		setColor(living_entities[k]["col"])
		slang.writechar(living_entities[k]["sym"])
	end
		
		local newx = ob["x"]
		local newy = ob["y"]
		
		
		
		--if i didnt move
		if oldx == newx and oldy == newy then --nomad arrived at destination
			ob.distances = nil
			--select a new target village
			 local nexty,nextx = selectRandom("is_civilization")
			 ob["target"]["x"] = nextx
			 ob["target"]["y"] = nexty
		end --true, i reached my destination
		 
		 

		
	end
	
	slang.refresh()
 

end



function main()

movePathfinders() 



local key
local x
local y
local mbutton

key, mbutton, x, y = getKey();

if key == "b" then player_build(player_y,player_x) end
if key == "S" then spawn_nomad(player_y,player_x) end

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

	rightClickOnMap(y,x);
--	elseif key == "mouse" and last_mouse == "mouse" and (last_mouse_x == x and last_mouse_y == y) then --double click
	elseif key == "mouse" and mbutton == 0 then --left click bring up build menu
--	key = "blank"
	slang.gotorc(y,x)
	slang.writestring("?")
	player_build(y,x) --open the build menu on left click
	
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

	--calculateIncomes() --incomes and adds to stockpile
if day == 7 then
	calculateStockpile()
	day = 0
	
	if zoom_level == 0 then
		resetSubmapStockpile()
		calculateSubmapStockpile() -- each day
	end

	if zoom_level == 1 then
		resetSubmapStockpile()
		calcOneSubmapStockpile(map_pos_y,map_pos_x)
	end
--	resetSubmapStockpile()
--	resetSubmapStockpile()
--	calculateSubmapStockpile("",player_y,player_x)
	finishStockpileCalc()
	
	
end
	day = day + 1



--day = day + 1



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