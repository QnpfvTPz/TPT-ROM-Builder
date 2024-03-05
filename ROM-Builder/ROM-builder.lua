
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


----------------------------------------------------------------


function qRomBuilder.generate(locX,locY,sizeX,sizeY,ori1,ori2,data,eleId)

    -- all data must be in a number
    -- all data must be seperated by \n
    
    --ori1: Left, Right, Up, Down
    --ori2: Left/Up, Right/Down

    tpt.log("Qn-ROM-Builder: generating...")

    local size = {sizeY, sizeX}
    local ndx = 1
    local vh = 0
    local yx, xy
    local tmp
    local evResult

    if ori1 <= 1 then
        vh = 1
    end

    for y = 0, size[2-vh]-1 do
    for x = 0, size[1+vh]-1 do

        tmp = data[ndx]
        evResult = qRomBuilder.validateData(tmp)
        if (evResult ~= 0) then
            tpt.throw_error(string.format(errorMessages[evResult],ndx))
            return false
        end
        
        if vh == 1 then
            yx = x
            xy = y
        else
            yx = y
            xy = x
        end

        if ori1 == 0 then
            tmpX = locX - yx
        elseif ori1 == 1 then
            tmpX = locX + yx
        elseif ori1 == 2 then
            tmpY = locY - xy
        elseif ori1 == 3 then
            tmpY = locY + xy
        else
            tpt.throw_error("invalid orientation 1")
            return false
        end
        if vh == 1 then
            if ori2 == 0 then
                tmpY = locY - xy
            elseif ori2 == 1 then
                tmpY = locY + xy
            else
                tpt.throw_error("invalid orientation 2")
                return false
            end
        else
            if ori2 == 0 then
                tmpX = locX - yx
            elseif ori2 == 1 then
                tmpX = locX + yx
            else
                tpt.throw_error("invalid orientation 2")
                return false
            end
        end
        
        if ((tmpX < 4) or (tmpX > 607) or (tmpY < 4) or (tmpY > 379)) then
            tpt.throw_error("going out of bound!")
            return false
        end
        sim.partKill(tmpX, tmpY)
        local p = sim.partCreate(-3, tmpX, tmpY, eleId)
        if eleId == 0x7D then
            sim.partProperty(p, sim.FIELD_TMP, 6)
        elseif eleId == 0x1F then
            sim.partProperty(p, sim.FIELD_LIFE, 0)
            sim.partProperty(p, sim.FIELD_TEMP, 295.15)
            sim.partProperty(p, sim.FIELD_VX, 0)
            sim.partProperty(p, sim.FIELD_VY, 0)
        elseif eleId == 0x7F then
            sim.partProperty(p, sim.FIELD_LIFE, 0xFFFF)
        end
        sim.partProperty(p, sim.FIELD_CTYPE, tmp)
        ndx = ndx + 1
    end
    end

    return true
end


----------------------------------------------------------------


function qRomBuilder.input()
    local dataPath = ""
    local locX
    local locY
    locX, locY = sim.adjustCoords(tpt.mousex,tpt.mousey)
    local sizeX
    local sizeY
    local defaultValue = "0x10000000"
    local ori1 = 1  --Left, Right, Up, Down
    local ori2 = 0  --Left/Up, Right/Down
    local elem = 0
    local eleId = 0x7D

    local genWindow  = Window:new  ( -1, -1,320,160)
    local title      = Label:new   ( 10, 10,300, 17, "~/ Qn ROM Bulider \\~")
    local locLabel   = Label:new   ( 10, 32, 70, 17, "Starting point: ")
    local locXBox    = Textbox:new ( 85, 32, 34, 17, locX, "x coord")
    local locYBox    = Textbox:new (125, 32, 34, 17, locY, "y coord")
    local sizeLabel  = Label:new   (176, 32, 50, 17, "ROM size:")
    local sizeXBox   = Textbox:new (236, 32, 34, 17, sizeX, "width")
    local sizeYBox   = Textbox:new (276, 32, 34, 17, sizeY, "height")
    local pathLabel  = Label:new   ( 10, 54, 70, 17, "Data file path: ")
    local pathBox    = Textbox:new ( 85, 54,205, 17, dataPath, "ex) folder/file.txt")
    local testBtn    = Button:new  (293, 54, 17, 17, "뷁")
    local oriLabel1  = Label:new   ( 10, 76, 70, 17, "Orientation:")
    local oriBox1    = Button:new  ( 85, 76, 40, 17, "Right")
    local oriLabel2  = Label:new   (130, 76, 20, 17, "->")
    local oriBox2    = Button:new  (155, 76, 40, 17, "Up")
    local elemLabel  = Label:new   (210, 76, 50, 17, "Element type:")
    local elemBox    = Button:new  (270, 76, 40, 17, "FILT")
    local defVLabel  = Label:new   ( 10, 98, 70, 17, "Default value:")
    local defVBox    = Textbox:new ( 85, 98, 85, 17, defaultValue)
    local cancelBtn  = Button:new  (180, 98, 60, 17, "Cancel")
    local confirmBtn = Button:new  (250, 98, 60, 17, "Confirm")
    local outputLabel= Label:new   ( 10,120,310, 17, "Message from the script:             Made by 쀒뚫끢쮅똹뭜쏔")
    local outputText = Label:new   ( 10,137,310, 17)

    local data = {}
    local dataSize = 0

    local elemCfg = function()
        local winX, winY = genWindow:position()
        local btnX, btnY = elemBox:position()
        winX = winX + btnX
        winY = winY + btnY

        local eleWindow = Window:new (winX, winY - (elem * 16), 40, 96)
        local btnFilt   = Button:new (0, 0,40,17, "FILT")
        local btnPhot   = Button:new (0,16,40,17, "PHOT")
        local btnBray   = Button:new (0,32,40,17, "BRAY")
        local btnBizs   = Button:new (0,48,40,17, "BIZS")
        local btnBizr   = Button:new (0,64,40,17, "BIZR")
        local btnBizg   = Button:new (0,80,40,17, "BIZG")

        local eleTerminate = function()interface.closeWindow(eleWindow)end
        btnFilt:action(function()
            elem = 0
            eleId = 0x7D
            elemBox:text("FILT")
            eleTerminate()
        end)
        btnPhot:action(function()
            elem = 1
            eleId = 0x1F
            elemBox:text("PHOT")
            eleTerminate()
        end)
        btnBray:action(function()
            elem = 2
            eleId = 0x7F
            elemBox:text("BRAY")
            eleTerminate()
        end)
        btnBizs:action(function()
            elem = 3
            eleId = 0x69
            elemBox:text("BIZS")
            eleTerminate()
        end)
        btnBizr:action(function()
            elem = 4
            eleId = 0x67
            elemBox:text("BIZR")
            eleTerminate()
        end)
        btnBizg:action(function()
            elem = 5
            eleId = 0x68
            elemBox:text("BIZG")
            eleTerminate()
        end)

        eleWindow:addComponent(btnFilt)
        eleWindow:addComponent(btnPhot)
        eleWindow:addComponent(btnBray)
        eleWindow:addComponent(btnBizs)
        eleWindow:addComponent(btnBizr)
        eleWindow:addComponent(btnBizg)
        eleWindow:onTryExit(eleTerminate)
        interface.showWindow(eleWindow)
    end
    elemBox:action(elemCfg)

    local ori1Cfg = function()
        local winX, winY = genWindow:position()
        local btnX, btnY = oriBox1:position()
        winX = winX + btnX
        winY = winY + btnY
        
        local oriWindow = Window:new (winX, winY - (ori1 * 16), 40, 64)
        local btnL      = Button:new (0, 0,40,17,"Left")
        local btnR      = Button:new (0,16,40,17,"Right")
        local btnU      = Button:new (0,32,40,17,"Up")
        local btnD      = Button:new (0,48,40,17,"Down")
        
        local oriBox2Cfg = function()
            local oriBox2text = {}
            if ori1 <= 1 then
                oriBox2text = {"Up", "Down"}
            else
                oriBox2text = {"Left", "Right"}
            end
            oriBox2:text(oriBox2text[ori2+1])
        end

        local oriTerminate = function()interface.closeWindow(oriWindow)end
        btnL:action(function()
            ori1 = 0
            oriBox1:text("Left")
            oriBox2Cfg()
            oriTerminate()
        end)
        btnR:action(function()
            ori1 = 1
            oriBox1:text("Right")
            oriBox2Cfg()
            oriTerminate()
        end)
        btnU:action(function()
            ori1 = 2
            oriBox1:text("Up")
            oriBox2Cfg()
            oriTerminate()
        end)
        btnD:action(function()
            ori1 = 3
            oriBox1:text("Down")
            oriBox2Cfg()
            oriTerminate()
        end)
        
        oriWindow:addComponent(btnL)
        oriWindow:addComponent(btnR)
        oriWindow:addComponent(btnU)
        oriWindow:addComponent(btnD)
        oriWindow:onTryExit(oriTerminate)
        interface.showWindow(oriWindow)
    end
    oriBox1:action(ori1Cfg)

    local ori2Cfg = function()
        local winX, winY = genWindow:position()
        local btnX, btnY = oriBox2:position()
        winX = winX + btnX
        winY = winY + btnY
        
        local oriBox2text = {}
        if ori1 <= 1 then
            oriBox2text = {"Up", "Down"}
        else
            oriBox2text = {"Left", "Right"}
        
        end
        local oriWindow = Window:new (winX, winY - (ori2 * 16), 40, 32)
        local btnLU     = Button:new (0, 0,40,17,oriBox2text[1])
        local btnRD     = Button:new (0,16,40,17,oriBox2text[2])
        
        local oriTerminate = function()interface.closeWindow(oriWindow)end
        btnLU:action(function()
            ori2 = 0
            oriBox2:text(oriBox2text[1])
            oriTerminate()
        end)
        btnRD:action(function()
            ori2 = 1
            oriBox2:text(oriBox2text[2])
            oriTerminate()
        end)
        
        oriWindow:addComponent(btnLU)
        oriWindow:addComponent(btnRD)
        oriWindow:onTryExit(oriTerminate)
        interface.showWindow(oriWindow)
    end
    oriBox2:action(ori2Cfg)

    local outputTest = function()
        
        local dP = pathBox:text()
        if dP == "easteregg" then
            outputText:text("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
            io.popen('start /max https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        elseif dataSize == 0 then
            outputText:text("blah blah blah")
        else
            
            local tmp = tonumber(dP)
            if tmp == nil then
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

        if (tonumber(sizeX) == nil) then
            if(tonumber(sizeY) == nil) then
                if (dataSize > 32) then
                    sizeX = 64
                elseif (dataSize > 4) then
                    sizeX = 32
                else
                    sizeX = 4
                end
                sizeY = math.ceil(dataSize / sizeX)
            else
                sizeX = math.ceil(dataSize / sizeY)
            end
        elseif (tonumber(sizeY) == nil) then
            sizeY = math.ceil(dataSize / sizeX)
        end
        

        if (dataSize > (sizeX*sizeY)) then
            outputText:text("Data couldn't fit in the ROM")
            return
        end
        
        for i = dataSize + 1, sizeX*sizeY do
            data[i] = defaultValue
        end

        if qRomBuilder.generate(locX,locY,sizeX,sizeY,ori1,ori2,data,eleId) then
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
    genWindow:addComponent(oriLabel1)
    genWindow:addComponent(oriBox1)
    genWindow:addComponent(oriLabel2)
    genWindow:addComponent(oriBox2)
    genWindow:addComponent(elemLabel)
    genWindow:addComponent(elemBox)
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


----------------------------------------------------------------


function qRomBuilder._HotkeyHandler(key, keyNum, rep, shift, ctrl, alt)
    if (key == 106) then        -- J stands for Jay
        qRomBuilder.input()
    end
end

event.register(event.keypress, qRomBuilder._HotkeyHandler)
