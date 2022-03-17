color = 0
slang.init()
yy,xx = slang.dimensions()
for x = 1,xx/4 do
	for y = 1,yy do
color = color + 1
print("C: "..color)
slang.setcolor(color)
slang.gotorc(y,x*3)
slang.writestring(color)
slang.refresh()
end
end
while(true) do end

