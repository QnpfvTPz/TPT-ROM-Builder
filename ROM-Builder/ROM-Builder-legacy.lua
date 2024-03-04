function test(locX,locY,sizeX,sizeY,dataPath)
	
    io.input(dataPath)
	
    local data = {}
	local dataSize = 0

	for line in io.lines() do
		data[#data+1] = line
		dataSize = dataSize + 1
	end

	local ndx = 1
	for y = 0, sizeY-1 do
	for x = 0, sizeX-1 do
		local p = sim.partCreate(-3, locX+x, locY-y, 125)
		sim.partProperty(p, sim.FIELD_TMP, 6)
		sim.partProperty(p, sim.FIELD_CTYPE, data[ndx])
		ndx = ndx + 1
	end
	end
    
	return
end