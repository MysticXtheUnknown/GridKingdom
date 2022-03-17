-- front end driver stub for slang console mode i/o
-- required lua libs: base, table, string, math (for rand)


local keys = { [13]='ret', [127]='bs', [9]='tab', [27]='esc',
[257]='up', [258]='down', [259]='left', [260]='right',
}
-- note: alt keys aren't handled, they send an escape first

slang.keys = keys

-- character symbols, turn into table and kvswap?
-- first element ' ' is ascii code 32
-- or use string.char
-- symbols=[[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~]]


-- translate ascii code to string character or key name
function slang.ascii(int)
	assert(type(int) == 'number')

	local k = keys[int] 
	if(k) then return k end

--	if(int > 255) then return '' end
	return string.format('%c', int)
end


-- do not change this table with adjusting the one in lua_slang.h accordingly
local colors={
     [0]="black", "blue", "green", "cyan",
     "red", "magenta", "brown", "lightgray",
     "gray", "brightblue", "brightgreen", "brightcyan",
     "brightred", "brightmagenta", "yellow", "white"
}

slang.colors = colors

-- print("color table: ") for i=0,15 do print(i .." = ".. colors[i]) end

-- need to swap keys & values in color table
local function kvswap(t)
	for i=0, table.getn(t) do
		t[t[i]]=i
		t[i]=nil
	end
end

kvswap(slang.colors)

local function colorcode(fg, bg)
	return fg+bg*16
end

local function getcolor(fg, bg)
	return colorcode(colors[fg], colors[bg])
end

-- output a bunch of stuff
local function testslang()
--	slang.write_string("The quick brown fox jumps over the lazy dog.");
	slang.gotorc(0,0)
	for i=32,63 do slang.writechar(i) end
	slang.gotorc(1,0)

	for i=64,126 do slang.writechar(i) end

	slang.gotorc(2,0)
--	slang.drawhline(40)

	slang.gotorc(3,0)
	for i=128,191 do slang.writechar(i) end
	slang.gotorc(4,0)
	for i=192,255 do slang.writechar(i) end

	slang.showcursor(0)

	slang.gotorc(5,0)
	slang.setcolor(15*16) -- row of spaces, black on white = white boxes
	for i=0,40 do slang.writechar(32) end

	slang.setcolor(0)
--	slang.drawbox (7, 0, 18, 18)

	-- color grid
	for i=0,15 do 
		for j=0,15 do
			slang.gotorc(8+i,1+j)
			slang.setcolor(colorcode(j,i))
			slang.writechar('o')
		end
	end
	-- background colors only
	for i=0,15 do 
		slang.gotorc(8,19+i)
		slang.setcolor(i*16)
		slang.writechar(' ')
	end

	slang.gotorc(26,0)
--	slang.writestring("Hello World")
	slang.writestring(table.concat({slang.dimensions()}," "))
end


-- write random chars all over
local function randchar1()
	local rand = math.random
	local r,c = slang.dimensions()
	slang.setcolor(rand(0,255))
	slang.gotorc(rand(0,r), rand(0,c))
	slang.writechar(rand(32,255))
end

-- write random chars sequentially
local randcolor, randc, randr, randsymbol
local function randchar2()
	local sizer, sizec = slang.dimensions()
	if(randcolor == nil) then randcolor = 0 end
	if(randr == nil) then randr = 0 end
	if(randc == nil) then randc = 0 end
	if(randsymbol == nil) then randsymbol = 32 end

	randcolor = randcolor+1
	if (randcolor > 255) then randcolor = 0 end
	randc = randc+1
	if(randc >= sizec) then
		randc = 0
		randr = randr+1
	end
	if(randr >= sizer) then randr = 0 end

	randsymbol = randsymbol+1
	if(randsymbol > 255) then randsymbol = 32 end

	slang.setcolor(randcolor)
	slang.gotorc(randr, randc)
	slang.writechar(randsymbol)
end

function slang.testinput()

	assert(slang.init())
	slang.mousemode(1,1)
	
	local sizer, sizec = slang.dimensions()
--	slang.showcursor(false)
	slang.writestring"slang input test.  push some keys, try the mouse, esc to exit"
	slang.gotorc(2,0)
	slang.writestring("terminal dimensions: " .. sizec ..", ".. sizer)
	slang.gotorc(4,0)
	slang.refresh()
			
	while(true) do
		
		local r,c = slang.getrc()
		if(r + 1 >= sizer) then slang.clear() slang.gotorc(0,0)
		elseif(c + 1 >= sizec) then slang.gotorc(r+1, 0) 
		end
		

		local k, b, x, y = slang.getinput()	-- input keysym / mouse info
		if(k == -1) then
			-- run idle process
			-- continue.  damn, where's my continue statement Lua?  stupid.  
		elseif(k == 'mouse') then 
			slang.writestring( table.concat({' mouse', b, x, y, ''}, ' ') )
			slang.refresh()
		else
			if(keys[k] == 'esc') then break end	-- quit on single escape
	
			-- if code > 127 then ... end	-- escape sequences or something?
		
			slang.writestring(k .. ' ')
			slang.w=ritestring(slang.ascii(k) .. ' ')

			slang.refresh()
		end
	end
	
	slang.reset()
end

function slang.testoutput()
	assert(slang.init())
	while(true) do
		if(slang.getinput() ~= -1) then break end
		randchar2()
		testslang()
		slang.refresh()
	end
	slang.reset()
end

--slang.testinput()
--slang.testoutput()
