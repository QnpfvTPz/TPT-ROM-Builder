
qRomBuilder = {}

local errorMessages = {
    "line %d: Data must be a number",
    "line %d: Data must be an integer",
    "line %d: Data is too big",
    "line %d: Data is too small"
}



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
        local tmp = data[ndx]
        local evResult = qRomBuilder.validateData(tmp)
        if (evResult ~= 0) then
            tpt.throw_error(string.format(errorMessages[evResult],ndx))
            return false
        end
        
        local p = sim.partCreate(-3, locX + x, locY - y, 125)
        sim.partProperty(p, sim.FIELD_TMP, 6)
        sim.partProperty(p, sim.FIELD_CTYPE, tmp)
        ndx = ndx + 1
    end
    end

    return true
end



function qRomBuilder.input()
    local dataPath = ""
    local locX
    local locY
    locX, locY = sim.adjustCoords(tpt.mousex,tpt.mousey)
    local sizeX = 64
    local sizeY = 1
    local defaultValue = "0x10000000"

    local genWindow  = Window:new  ( -1, -1,320, 144)
    local title      = Label:new   ( 10, 10,300, 17, "~/ Qn ROM Bulider \\~")
    local locLabel   = Label:new   ( 10, 32, 70, 17, "Starting point: ")
    local locXBox    = Textbox:new ( 85, 32, 34, 17, locX, "x coord")
    local locYBox    = Textbox:new (125, 32, 34, 17, locY, "y coord")
    local sizeLabel  = Label:new   (176, 32, 50, 17, "ROM size:")
    local sizeXBox   = Textbox:new (236, 32, 34, 17, sizeX, "width")
    local sizeYBox   = Textbox:new (276, 32, 34, 17, sizeY, "height")
    local pathLabel  = Label:new   ( 10, 54, 70, 17, "Data file path: ")
    local pathBox    = Textbox:new ( 85, 54,205, 17, dataPath, "ex) folder/file.txt")
    local testBtn    = Button:new  (293, 54, 17, 17, "test")
    local defVLabel  = Label:new   ( 10, 76, 70, 17, "Default value:")
    local defVBox    = Textbox:new ( 85, 76, 85, 17, defaultValue)
    local cancelBtn  = Button:new  (180, 76, 60, 17, "Cancel")
    local confirmBtn = Button:new  (250, 76, 60, 17, "Confirm")
    local outputLabel= Label:new   ( 10, 98,115, 17, "Message from the script: ")
    local outputText = Label:new   ( 10,117,320, 17)

    local data = {}
    local dataSize = 0


    local outputTest = function()
        if dataSize == 0 then
            outputText:text("blah blah blah")
        else
            dataPath = pathBox:text()
            local tmp = tonumber(dataPath)
            if dataPath == "dV" then
                outputText:text(defaultValue)
            elseif tmp == nil then
                outputText:text("input: nil")
            else
                outputText:text(data[tmp])
            end
            
        end
    end
    testBtn:action(outputTest)

    local terminate = function()interface.closeWindow(genWindow)end
	cancelBtn:action(terminate)

    local tryGen = function()
        
        locX = locXBox:text()
        locY = locYBox:text()
        sizeX = sizeXBox:text()
        sizeY = sizeYBox:text()
        dataPath = pathBox:text()
        defaultValue = defVBox:text()

        outputText:text("trying to open...")
        local dataFile
        data = {}
        dataSize = 0

        dataFile = io.open(dataPath)

        if dataFile == nil then
            outputText:text("file not found")
            return
        end

        

        for line in dataFile:lines() do
            if (line == nil) then
                data[#data+1] = defaultValue
            else
                data[#data+1] = line
            end
            dataSize = dataSize + 1
        end

        if (dataSize > (sizeX*sizeY)) then
            outputText:text("Data couldn't fit in the ROM")
            return
        end
        
        for i = dataSize + 1, sizeX*sizeY do
            data[i] = defaultValue
        end

        
        if qRomBuilder.generate(locX,locY,sizeX,sizeY,data) then
            terminate()
        end
    end
    confirmBtn:action(tryGen)


    genWindow:addComponent(title)
    genWindow:addComponent(locLabel)
    genWindow:addComponent(locXBox)
    genWindow:addComponent(locYBox)
    genWindow:addComponent(sizeLabel)
    genWindow:addComponent(sizeXBox)
    genWindow:addComponent(sizeYBox)
    genWindow:addComponent(pathLabel)
    genWindow:addComponent(pathBox)
    genWindow:addComponent(testBtn)
    genWindow:addComponent(defVLabel)
    genWindow:addComponent(defVBox)
    genWindow:addComponent(cancelBtn)
    genWindow:addComponent(confirmBtn)
    genWindow:addComponent(outputLabel)
    genWindow:addComponent(outputText)
    genWindow:onTryExit(terminate)
    genWindow:onTryOkay(tryGen)

    interface.showWindow(genWindow)

end

function qRomBuilder._HotkeyHandler(key, keyNum, rep, shift, ctrl, alt)
    if (key == 106) then
        qRomBuilder.input()
    end
end
    

event.register(event.keypress, qRomBuilder._HotkeyHandler)
