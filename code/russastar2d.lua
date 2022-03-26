funcs = {}

function funcs.getdistance(x,y,x2,y2)
--local path_cost = 1
--	local point = content.map[y][x]
--	if point and point["player_building"] and point["player_building"]["path_cost"] then
--	path_cost = point["player_building"]["path_cost"]
--	end

	--local difx = funcs.getdifference(x,x2)  WORKED
	--local dify = funcs.getdifference(y,y2)
	
	local difx = math.abs(x-x2)
	local dify = math.abs(y-y2)
	
	return (math.sqrt((difx * difx) + (dify * dify)))  --path_cost)
end

function funcs.getdifference(a,b)
	if a > b then return a - b end
	if a < b then return b - a end
	return 0
end


--change the x and y of the object.
function funcs.moveobject(id,x,y)
living_entities[id]["x"] = x
living_entities[id]["y"] = y
end

function funcs.moveEntityTowards(ob,x1,y1,x2,y2,submapx,submapy)


print("x1 "..x1)
print("y1 "..y1)
print("x2 "..x2)
print("y2 "..y2)


--Manage the distance variable in the object, see if i needa a new path
	local distances = ob.distances
--	local zoom = ob["native_zoom"]

	if not distances then distances = funcs.astarpathfind(x2,y2,x1,y1) end --i need a new path

	ob.distances = distances --store the path
	
	if not distances then --reached destination? --no path?
	ob.distances = nil
	 
	 return false end --reached destination or no path
	
	

	local oldx,oldy = x1,y1
	--print("MOVING A MONSTER!!")
	local x local y
	local lowestdistance = {distance = 10000000 ,x=oldx,y=oldy} --HARDCODED LIMIT
	local iterations = 0


--	movementintelligence = 20 

	
	for x = ob["x"]-1,ob["x"]+1,1 do
	for y = ob["y"]-1,ob["y"]+1,1 do
	
	
			local relativevalue = 0
			--if ((not targ) or (distances and distances[x] and distances[x][y] and distances[x][y])) and not funcs.checkforedgeofmap(x,y) then --was and distances[x][y][z]
			if distances and distances[x] and distances[x][y] then --ADD IF EDGE OF MAP
				relativevalue = distances[x][y] + relativevalue

				if relativevalue < lowestdistance["distance"] then --go towards high strength sound
					lowestdistance = {["distance"] = relativevalue,["x"]=x,["y"]=y}
				end
			end

	
	
--	
end
end 
local id = ob.id
funcs.moveobject(id,lowestdistance["x"],lowestdistance["y"])
end


function funcs.checkforblockpassageofpath(x,y,submap_x,submap_y,command,map_data) 

	if submap_x and submap_y then --off the map
	if x > submap_size_x then return true end
	if y > submap_size_y then return true end
	end
	
	if not submap_x and not submap_y then
	if x > map_size_x then return true end --off the map
	if y > map_size_y then return true end
	end
	
	if x < 0 then return true end --off the map
	if y < 0 then return true end
	
	--TESTING
	
	local spot
--	if not map_data or not map_data[y] or not map_data[y][x] then return true end --outside of map, blocked = true
	
--if command then	print("command "..command) end
--	print("x"..x)
--	print("y"..y)
	if command == "stay_on_road" and map_data[y][x] then --WORKS....fucking hell.
--		print("foudn road1")
--		os.exit()
		spot = map_data[y][x]["player_building"]
		if spot and (spot["is_road"] or spot["road_hub"] or spot["needs_roads"]) 
		then
		--got to here foudn road
		return false end --looking for roads, found a connection, not blocked
		
	end
	
	if command == "stay_on_road" then return true end --looking for roads, no connection, blocked.
	
	return false
end

function funcs.astarpathfind(startx,starty,endx,endy,submap_x,submap_y,command,map_data) --comand = "on_road"
	if startx == endx and starty == endy then return false end
	local working = {} --node list
--	local closed = {} --node list
	local insert = table.insert
	local min = math.min

	--[[
	local mapsizex = map_size_x
	local mapsizey = map_size_y
	
	if submap_x and submap_y then --on a submap
	mapsizex = submap_size_x
	mapsizey = submap_size_y
	end
--]] 
	
	local distances = {}
	local future = {}
	
	local getdistance = funcs.getdistance
	
	local blocking = funcs.checkforblockpassageofpath
	
	local impossible = 100000000
	
	--seed the working table
	distances[startx] = {}
	distances[startx][starty] = 0

	insert(future,{startx,starty,0,0,funcs.getastarheuristic(startx,starty,endx,endy)})

	while(true) do
	
		
		for k,v in pairs(future) do
			insert(working,v)
		end
		future = {}

		local lowestfvalue = impossible --or lowestfvalue (dumb pathfind)
		local savedk

for k,v in pairs(working) do --4 is distance, 5 is heuristic
		

	local x = working[k][startx]
	local y = working[k][starty]
	if (working[k][4]) + working[k][5] < lowestfvalue then
		lowestfvalue = (working[k][4]) + (working[k][5])  --new distance + my heuristic	
		savedspot = v
		savedk = k
	end
end
	if working[savedk] == nil then return distances end --ALREADY AT DESTINATION
		working[savedk] = nil

			--iterate over that one
		for x = savedspot[1] - 1,savedspot[1] + 1 do
		for y = savedspot[2] -1,savedspot[2]+1 do
		
			distances[x] = distances[x] or {}
			distances[x][y] = distances[x][y] or impossible
			
			local path_cost = 10 --default value

			local point
			
			if not submap_x and not submap_y and content.map[y] and content.map[y][x] then --not on a submap
			point = content.map[y][x]
			end
			
			
			if submap_x and submap_y then -- on a submap
			
				if content.map[submap_y] and content.map[submap_y][submap_x] and content.map[submap_y][submap_x][y] and
				content.map[submap_y][submap_x][y][x] then
			
					point = content.map[submap_y][submap_x][y][x]
			
				end
			end
			
			if point and point["player_building"] and point["player_building"]["path_cost"] then
				path_cost = point["player_building"]["path_cost"]
			end
		
	--	end

			
			local newdistance = min(distances[x][y], (savedspot[4] + path_cost) + (getdistance(x,y,savedspot[1],savedspot[2])))
--			if not closed[savedspot] then
			if not blocking(x,y,submap_x,submap_y,command,map_data) then 
				if newdistance < distances[x][y] then	-- adds or readds a spot to the array
--				print("Updating X "..x.." Y "..y)
				local myh = funcs.getastarheuristic(x,y,endx,endy)
				insert(future, {x,y,0,newdistance,myh})
				distances[x][y] = newdistance
				end
			end
						
						
			if x == endx and y == endy then
					--print("Correct Return")
					return distances, true
				end
--			end --ends closedcheck	
		end--ends for y
		end --ends for x
			
			--end --ends for z
--The following visualizes the pathfind data
--	print("Path X "..savedspot[1].." Y "..savedspot[2])
--	print("DIST "..savedspot[4])
--	print("HEUR "..savedspot[5])
--	slang.gotorc(savedspot[2]+data.mapoffsety,savedspot[1]+data.mapoffsetx)
--	slang.setcolor(math.random(1,15))
--	slang.writechar("*")
--	slang.writechar(""..math.mod(savedspot[4],10))
--	slang.refresh()
--	funcs.displaymessage(1,1,"Press a key")
--	funcs.getkey()

	end --ends while true
return false

end


			
function funcs.getastarheuristic(x,y,x2,y2) --was processer heavy possibly.
	
	local distanceguess = funcs.manhattandistance(x,y,x2,y2)
--local distanceguess = funcs.crowdistance(x,y,x2,y2)
	return distanceguess
end

function funcs.manhattandistance(x,y,x2,y2) --difference in x plus difference in y
	return math.abs(x-x2) + math.abs(y-y2)
	end

function funcs.crowdistance(x,y,x2,y2)  --removed math.sqrt
	local guess = (math.abs(x-x2)^2) + (math.abs(y-y2)^2)
	
	return guess
	
	end 
