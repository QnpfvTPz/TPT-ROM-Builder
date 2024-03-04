
qRomBuilder = {}

local errorMessages = {
    "line %d: Data must be a number",
    "line %d: Data must be an integer",
    "line %d: Data is too big",
    "line %d: Data is too small"
}

--tpt.throw_error(string.format(errorMessages[tmp],tmp2))

function qRomBuilder.validateData(data)
    
    if (tonumber(data) == nil) then
        return 1
    else
        local tempLine = tonumber(data)
        if (tempLine ~= math.floor(tempLine)) then
            return 2
        elseif (tempLine > 4294967295) then
            return 3
        elseif (tempLine < -2147483647) then
            return 4
        else
            return 0
        end
    end
end



function qRomBuilder.generate(locX,locY,sizeX,sizeY,data)

    -- all data must be in a number
    -- all data must be seperated by \n
    
    local ndx = 1
    for y = 0, sizeY-1 do
    for x = 0, sizeX-1 do
        local p = sim.partCreate(-3, locX + x, locY - y, 125)
        sim.partProperty(p, sim.FIELD_TMP, 6)
        sim.partProperty(p, sim.FIELD_CTYPE, data[ndx])
        ndx = ndx + 1
    end
    end

    return
end



function QnROM()
    qRomBuilder.input()
end



function qRomBuilder.input()
    local dataPath = ""
    local locX
    local locY
    locX, locY = sim.adjustCoords(tpt.mousex,tpt.mousey)
    local sizeX = 64
    local sizeY = 1
    local defaultValue = 0x10000000

    local genWindow  = Window:new  ( -1, -1, 340, 80)
    local locLabel   = Label:new   ( 10, 10,  80, 17, "Starting point: ")
    local locXBox    = Textbox:new (100, 10,  30, 17, locX, "x coord")
    local locYBox    = Textbox:new (140, 10,  30, 17, locY, "y coord")
    local sizeLabel  = Label:new   (190, 10,  60, 17, "ROM size:")
    local sizeXBox   = Textbox:new (260, 10,  30, 17, sizeX, "width")
    local sizeYBox   = Textbox:new (300, 10,  30, 17, sizeY, "height")
    local pathBox    = Textbox:new ( 10, 32, 320, 17, dataPath, "Data file path (.txt allowed)")
    local defVLabel  = Label:new   ( 10, 54,  75, 17, "Default value:")
    local defVBox    = Textbox:new ( 85, 54,  75, 17, defaultValue, "0x10000000")
    local cancelBtn  = Button:new  (170, 54,  75, 17, "Cancel")
    local confirmBtn = Button:new  (255, 54,  75, 17, "Confirm")

    local terminate = function()interface.closeWindow(genWindow)end
	cancelBtn:action(terminate)

    local tryGen = function()
        
        
        if pcall(io.input(dataPath)) == false then
            tpt.throw_error("File not found")
            terminate()
            return
        end
        io.input(dataPath)
        

        local data = {}
        local dataSize = 0

        for line in io.lines() do
            
            if (line == nil) then
                data[#data+1] = defaultValue
            else
                data[#data+1] = line
            end
            dataSize = dataSize + 1

        end

        if (dataSize > (width*height)) then
            tpt.throw_error("Data couldn't fit in the ROM")
            terminate()
            return
        end
        
        for i = dataSize + 1, width*height do
            data[#data+1] = defaultValue
        end

        terminate()
        qRomBuilder.generate(locX,locY,sizeX,sizeY,data)
        
    end
    confirmBtn:action(tryGen)


    
    genWindow:addComponent(locLabel)
    genWindow:addComponent(locXBox)
    genWindow:addComponent(locYBox)
    genWindow:addComponent(sizeLabel)
    genWindow:addComponent(sizeXBox)
    genWindow:addComponent(sizeYBox)
    genWindow:addComponent(pathBox)
    genWindow:addComponent(defVLabel)
    genWindow:addComponent(defVBox)
    genWindow:addComponent(cancelBtn)
    genWindow:addComponent(confirmBtn)
    genWindow:onTryExit(terminate)
    genWindow:onTryOkay(tryGen)

    interface.showWindow(genWindow)

end

