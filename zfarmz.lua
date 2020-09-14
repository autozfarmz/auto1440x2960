version = "2.8.8"

function stringsEN()
    errorString = "Error"
    warningString = "Warning"
    settingsString = "auto zfarmz"

    immersiveString = "Immersive mode"
    saveFileNameString = "Save recording to file: "

    fileExistsString = "File exists. Overwrite?"
    overWriteOriginalString = "Overwrite original file: "
    appendOriginalString = "Append original file: "
    overWriteNewString = "Overwrite new file: "
    storeNewString = "Store to new file: "

    stopLocationString = "Stop recording area\n (click this red area to stop): \n"
    upperLeftString = "Upper left"
    upperRightString = "Upper right"
    lowerLeftString = "Lower left"
    lowerRightString = "Lower Right"

    stopRecordString = "Stop recoring"

    scriptToPlayString = "The file to playbak: "
    scriptToExpandString = "The file to expand: "
    timesString = "Replay times: "
    gapString = "Gap (second) between replay: "
    contentString = "Plackback Content"

    modifiedString = "Content modified"

    chooseActionString ="Choose what to do"
    recordString = "Record"
    playString = "Playback"
    expandString = "Expand existing luar (Select file in next dialog.)"

    snapWidthString = "How many pixels to snap in left and right? "
    snapHeightString = "How many pixels to snap in up and down? "
    snapRegionExtraString = "How many pixels to expand in searching region? "
    duplicateDetectString = "Detect duplication(same images will not be recorded again)"
    repeatDetectRegionString = "How many pixels to expand in searching duplication?"
    dragDropOptionString = "The action when drag & drop or swipe detected: "
    dragDropOptionTable = {"According to detected action","drag and drop", "swipe", "If A found, click B", "Click target offset", "If A found, click B location",
                           "swipe target offset", "Ask" }
    dragDropAskString = "DragDrop/swipe detected, choose the actions:"

    smartOrderString = "Smart order(If previous snaps found in background, new snap will arrange in front)"
    repeatFoundString = "Find duplicate image. The image is not recorded."
    backgroundFoundString = "Find previous snaps in background, the new snap is rearranged."

    specifyFileNameString = "Manually specify image file name "
    inputFileNameString = "Input file name: "
    inputDragFileNameString = "Input drag file name: "
    inputDropFileNameString = "Input drop file name: "

    similarString = "Minimum similarity(0~0.99): "
    allWithRegionString = "All searchings with regions"
    searchFromBeginningString = "Always search from first image.\n(If not selected, will search from next image of found one.)"
    whichWithRegionString = "Which searchings with region?"
    withRegsionString = "search with region"
    searchPngString = "Stop when finding chosen snap for fixed times.\n (If clicked, setting in next diaglog.)"
    searchPngPreString = "Stop when finding "
    searchTimesString = "times"
    runTimeString = "How many minutes to stop? "
    searchReachString = "Have found %s.png %d times"
    timeReachString = "Script have run %d minutes"
    randomTouchString = "Random click (up/down/left/right pixels): "
    minIntervalString = "The minimum snap interval in seconds: "

    waitString = "Wait"
    underWaitString = "Waiting...\nDon't touch screen!"
    waitOptionString = "Enable wait option"
    waitSecondString = ", waiting seconds: "
    waitDescriptionString ="Enable this if the game pauses when the screen is light yellow."

    cutoutString = "with cutout and cutout on device top \n(Will detect cutout height and compensate)"

    dimString = "dim the screen when running script"
    fiveMinString = "This function is only available for 5 minutes in trial version"

    noLuarString = "Can't find .luar file under luar directory. Please record first."
end


function regionWaitMulti(target, seconds, debug, skipLocation, index, previousSnap)
    local timer = Timer()
    local match
    local length = table.getn(target)
    if (index > length or index <= 0) then
        index = 1
    end

    while (true) do
        --        for i, t in ipairs(target) do
        if (not previousSnap) then snapshot() end
        usePreviousSnap(true)
        for i = index, length do
            local t = target[i]
            if (debug and t.region) then t.region:offset(0, -cutoutHeight):highlight(0.2) end
            if ((t.region and (t.region):exists(t.target, 0)) or
                    (not t.region and exists(t.target, 0))) then -- check once
                usePreviousSnap(false)
                if (t.region) then
                    match = (t.region):getLastMatch()
                else
                    match = getLastMatch()
                end
                --            if (debug) then match:offset(0, -cutoutHeight):highlight(0.5) end
                return i, t.id, match
            end
        end
        index = 1
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1, "__none__"
        end
    end
end

function targetExists(target, seconds)
    if (not seconds) then seconds = 3 end
    if (target.region) then
        return (target.region:exists(target.target, seconds))
    end
    return (exists(target.target, seconds))
end

function cutoutHeightMeasure(startY)
    local width = getRealScreenSize():getX()
    local height = getRealScreenSize():getY()

    local testHeight = math.floor(height / 8)
    setHighlightStyle(0xff567890, true)
    local reg = Region(0, startY, width / 4, testHeight)
    reg:highlight()
    wait(0.5)
    snapshotColor()
    reg:highlightOff()
    local maxY = 0
    local found = false
    for y = math.floor(testHeight/2) + startY, startY + testHeight * 2 do
        local r, g, b = getColor(Location(10, y))
        --        print (string.format("y = %d, r = %x, g = %x, b = %x", y, r, g, b))
        if (found and (r ~= 0x56 or g ~= 0x78 or b ~= 0x90)) then
            maxY = y - 1
            break
        end
        if (r == 0x56 and g == 0x78 and b == 0x90) then
            found = true
        end
    end

    usePreviousSnap(false)
    setHighlightStyle(0xffff0000, false)
    local cHeight = maxY - testHeight - startY
    if (cHeight < 10) then cHeight = 0 end
    return (cHeight)
end

function loadStringsFunction()
    local language = getLanguage()
    if (language == "zh") then
        --        if (getCountry() == "CN") then
        --            stringsZHCN()
        --        else
        stringsZH()
        --        end
    elseif (language == "pt") then
        stringsPT()
    else
        stringsEN()
    end
end

function fileExists(name)
    local fName = localPath .. "luar/" .. name .. ".luar"
    local f=io.open(fName,"r")
    if f~=nil then io.close(f) return true else return false end
end

function fileCheck(name, text)
    overwrite = 0
    removePreference("overwriteFileName")
    local fName = string.gsub(name, ".luar$", "")
    name = fName
    fileName = preferenceGetString("fileName", "")

    while (overwrite == 0 and fileExists(fName)) do
        dialogInit()
        addTextView(text)
        newRow()
        addRadioGroup("overwrite", 0)
        addRadioButton(overWriteOriginalString .. name .. ".luar", 1)
        addRadioButton(appendOriginalString .. name .. ".luar", 11)
        if (fName ~= "") then
            addRadioButton(overWriteNewString .. fileName .. ".luar", 2)
        end

        addRadioButton(storeNewString, 0)
        newRow()
        addEditText("fileName", "touch2")
        addTextView(".luar")
        dialogShowFullScreen(text)

        --        if (overwrite == 1) then
        --            fName = overwriteFileName
        --        else
        fName = fileName
        --        end
    end
    return localPath .. "luar/" .. fName .. ".luar", (overwrite == 11) -- extend
end

function locationInRegion(loc, reg)
    local l = loc
    if (not reg) then return true end
    local x = l:getX()
    local y = l:getY()
    return (x > reg:getX() and x < (reg:getX() + reg:getW()) and
            y > reg:getY() and y < (reg:getY() + reg:getH()))
end

function locationToString(loc)
    return(string.format("Location(%d, %d)", loc:getX(), loc:getY()))
end

function locationToRegion(loc, widthHalf, heightHalf)

    local x = loc:getX()
    if (x - widthHalf < 0 ) then
        x = 0;
    end

    local y = loc:getY()
    if (y - heightHalf < 0) then
        y = 0;
    end

    return Region(x - widthHalf, y - heightHalf, 2 * widthHalf, 2 * heightHalf)
end

function fileHeader(fPointer)
    fPointer:write("----- created by AnkuLua snap and play script ------\n")
    fPointer:write("immersive = " .. tostring(immersive) .. "\n")
    fPointer:write("setImmersiveMode(immersive)\n")
    if (genVersion) then
        fPointer:write('genVersion = "' .. genVersion .. '"\n')
    end
    if (setAutoGameArea) then
        fPointer:write("setAutoGameArea = " .. tostring(setAutoGameArea) .. "\n")
        fPointer:write("pcall (autoGameArea, setAutoGameArea)\n")
    end
    fPointer:write("scriptDimension = " .. scriptDimension .. "\n")
    fPointer:write("Settings:setScriptDimension(true, scriptDimension)\n")
    fPointer:write("Settings:setCompareDimension(true, scriptDimension)\n")
    fPointer:write("local index = 1\n")
    fPointer:write("touchList = {}\n")
    fPointer:write("waitList = {}\n")
    fPointer:write("\n")
end

------------------------ record function ----------------------
function regionToString(reg, snapRegionExtra)
    if (not reg) then return ('nil') end
    return("Region(" .. (reg:getX() - snapRegionExtra) .. ", " .. (reg:getY() - snapRegionExtra) .. ", "
            .. (reg:getW() + 2 * snapRegionExtra) .. ", " .. (reg:getH() + 2 * snapRegionExtra) .. ")")
end

function repeatDetect(targetReg, duplicateDetect)
    local startIndex = 1
    local meet = {}
    local repeatIndex = -1
    local backgroundIndex = -1

    while (true) do
        local choice, id, match = regionWaitMulti(touchList, 0, false, nil, startIndex, true)
        if (choice == -1) then
            break
        else
            if (locationInRegion(Location(match:getX(), match:getY()), targetReg) and
                    locationInRegion(Location(match:getX() + match:getW(), match:getY() + match:getH()), targetReg)) then
                repeatIndex = choice
                break
            else
                if (backgroundIndex == -1) then backgroundIndex = choice end
                if (repeatIndex ~= -1 or not duplicateDetect) then break end
            end

            if (startIndex >= #touchList) then
                return repeatIndex, backgroundIndex
            end
            startIndex = choice + 1;

        end
    end

    return repeatIndex, backgroundIndex

end

function targetToString(t)

    if (typeOf(t) == "string") then return ('"' .. t .. '"') end

    target = 'Pattern("' .. t:getFileName() .. '")'
    target = target .. ':similar(' .. t:getSimilar() ..')'
    local tOffset = t:getTargetOffset()
    if (tOffset:getX() ~= 0 or tOffset:getY() ~= 0) then
        target = target .. string.format(':targetOffset(%d, %d)', tOffset:getX() ,tOffset:getY())
    end

    return target
end


function touchListToFile()
    io.close(fPointer)
    fPointer = io.open(fileName, "w")

    fileHeader(fPointer)
    local index = 1
    for i, t in ipairs(touchList) do
        if (not t.action) then t.action = "click" end
        local text = string.format('touchList[index] = {target =  %s, region = %s, id = "%s", action = \'%s\'',
                targetToString(t.target), regionToString(t.region, 0), t.id, t.action)
        if (t.target2) then
            text = text .. string.format(',\n                    target2 = %s, region2 = %s',
                    targetToString(t.target2), regionToString(t.region2, 0))
        end
        fPointer:write("------ " .. index .. " -----\n")
        fPointer:write(text .. "}\n")
        fPointer:write("index = index + 1\n\n")

        index = index + 1
    end
end

function record(expand)

    if (not expand) then
        if (getVersion() >= "8.2.0") then
            setAutoGameArea = true
            autoGameArea(true)
        else
            setAutoGameArea = false
        end
        genVersion = getVersion()
    end

    dialogInit()
    addCheckBox("immersive", immersiveString, true)
    newRow()
    addCheckBox("specifyFileName", specifyFileNameString, false)
    --    addSeparator()
    newRow()
    newRow()

    local fileList
    if (expand) then
        fileList = scandir(luarPath ..  "*.luar")
        if (#fileList == 0) then
            scriptExit(noLuarString)
        end
        addTextView(scriptToExpandString)
        newRow()
        addRadioGroup("fileNum", 1)
        for i, f in ipairs(fileList) do
            local subString = localPath .. "luar/"
            local shortName = string.gsub(f, luarPath, "")
            addRadioButton(shortName, i)
            fileList[i] = shortName
        end
    else
        addTextView(saveFileNameString)
        newRow()
        addEditText("fileName", "test")
        addTextView(".luar")
    end

    newRow()
    newRow()
    addTextView(stopLocationString)
    local areaItems = {upperLeftString, upperRightString, lowerLeftString, lowerRightString }
    addSpinnerIndex("stopIndex", areaItems, areaItems[3])
    newRow()
    newRow()

    addSeparator()
    addCheckBox("waitOption", waitOptionString, false)
    addTextView(waitSecondString)
    addEditNumber("waitSecond", 10)
    newRow()
    addTextView(waitDescriptionString)
    dialogShowFullScreen(settingsString)

    if (expand) then
        fileName = string.gsub(fileList[fileNum], ".luar$", "")
    else
        fileName = string.gsub(fileName, "%s", "_")
    end

    setImmersiveMode(immersive)

    luarPath = localPath .. "luar"
    os.execute("mkdir " .. luarPath)
    luarImagePath = luarPath .. "/" .. fileName .. "Image"
    os.execute("mkdir " .. luarImagePath)
    setImagePath(luarImagePath)
    luarImagePath = luarImagePath .."/"

    dialogInit()
    addTextView(snapWidthString)
    addEditNumber("snapWidth", 26)
    newRow()
    addTextView(snapHeightString)
    addEditNumber("snapHeight", 26)
    newRow()
    addTextView(snapRegionExtraString)
    addEditNumber("snapRegionExtra", 50)
    newRow()
    addTextView(dragDropOptionString)
    addSpinnerIndex("dragDropAction", dragDropOptionTable, 1)
    newRow()
    newRow()
    addCheckBox("duplicateDetect",duplicateDetectString, true)
    newRow()
    addTextView("        " ..  repeatDetectRegionString)
    addEditNumber("repeatRegionExtra", 15)

    newRow()
    newRow()
    addCheckBox("smartOrder", smartOrderString, true)
    dialogShowFullScreen(settingsString)

    if (expand) then
        fileName = localPath .. "luar/" .. fileName .. ".luar"
        appendFile = true
    else
        fileName, appendFile = fileCheck(fileName, fileExistsString) -- fileName is with .luar
    end

    askDragDrop = dragDropAction == #dragDropOptionTable
    local index
    if (appendFile) then
        os.execute("cp "..fileName .. " " .. fileName..".bak")
        fPointer = io.open(fileName, "a+")
        dofile(fileName)
        index = #touchList + 1
    else
        if (getVersion() >= "8.2.0") then
            autoGameArea(true)
            scriptDimension = getGameArea():getW()
        else
            if (immersive) then
                scriptDimension = getRealScreenSize():getX()
            else
                scriptDimension = getAppUsableScreenSize():getX()
            end
        end
        Settings:setScriptDimension(true, scriptDimension)
        Settings:setCompareDimension(true, scriptDimension)
        fPointer = io.open(fileName, "w")
        fileHeader(fPointer)
        index = 1
        touchList = {}
    end

    local width = getRealScreenSize():getX()
    local height = getRealScreenSize():getY()
    if (immersive) then
        width = getRealScreenSize():getX()
        height = getRealScreenSize():getY()
    else
        width = getAppUsableScreenSize():getX()
        height = getAppUsableScreenSize():getY()
    end
    local stopWidth = width / 8
    local stopHeight = height / 8
    if (stopIndex == 1) then
        stopArea = Region(0, 0, stopWidth, stopHeight)
        waitArea = Region(0, stopHeight + 5, stopWidth, stopHeight)
    elseif (stopIndex == 2) then
        stopArea = Region(width - stopWidth, 0, stopWidth, stopHeight)
        waitArea = Region(width - stopWidth, stopHeight + 5, stopWidth, stopHeight)
    elseif (stopIndex == 3) then
        stopArea = Region(0, height - stopHeight, stopWidth, stopHeight)
        waitArea = Region(0, height - stopHeight * 2 - 5, stopWidth, stopHeight)
    else
        stopArea = Region(width - stopWidth, height - stopHeight, stopWidth, stopHeight)
        waitArea = Region(width - stopWidth, height - stopHeight * 2 - 5, stopWidth, stopHeight)
    end

    centerArea = Region(width / 2 - stopWidth/2, height /2 - stopHeight /2, stopWidth, stopHeight)
    fullArea = Region(0, 0, width, height)
    setHighlightStyle(0x80ff0000, true)
    setHighlightTextStyle(0x80ff0000, 0x80ffffff, 16)
    stopArea:highlight("Stop!")
    if (waitOption) then
        waitArea:highlight("Wait!")
    end


    local timer = Timer()
    local waitTime, text
    local tmpFileName1 = "___tmp1.png"
    local tmpFileName2 = "___tmp2.png"
    while(true) do

        local action, locTable, touchTable = getTouchEvent()

        if (action == "click" or action == "longClick") then
            firstDown = locTable
        else
            firstDown = locTable[1]
        end
        firstDown = firstDown:offset(0, cutoutHeightEvent)
        if (locationInRegion(firstDown, stopArea)) then
            print("stop clicked")
            io.close(fPointer)
            scriptExit(stopRecordString)
        end

        if (waitOption and locationInRegion(firstDown, waitArea)) then
            hideAndWait()
        else
            if (action == "click" or action == "longClick") then

                local reg = locationToRegion(locTable, snapWidth, snapHeight):offset(0, cutoutHeightEvent)
                locTable = locTable:offset(0, cutoutHeightEvent)
                reg:save(tmpFileName1)

                reg:offset(0, -cutoutHeight):highlight(0.5)
                if (action == "longClick") then
                    longClick(locTable, 1.5)
                else
                    _G[action](locTable)
                end

                local extraReg = reg:grow(repeatRegionExtra, repeatRegionExtra, repeatRegionExtra, repeatRegionExtra)
                local repeatIndex, backgroundIndex
                if (smartOrder or duplicateDetect ) then
                    repeatIndex, backgroundIndex = repeatDetect(extraReg, duplicateDetect)
                end
                if (not smartOrder) then backgroundIndex = -1 end
                if (not duplicateDetect) then repeatIndex = -1 end

                if (repeatIndex ~= -1) then index = index - 1 end
                if (repeatIndex ~= -1 and backgroundIndex ~= -1) then
                    toast (repeatFoundString .. "\n" .. backgroundFoundString)
                    local original = touchList[repeatIndex]
                    dofile(fileName)
                    table.insert(touchList, backgroundIndex, original)
                    table.remove(touchList, repeatIndex + 1)
                    touchListToFile()
                elseif (repeatIndex ~= -1 and backgroundIndex == -1) then
                    toast (repeatFoundString)
                else -- repeatIndex == -1
                    if (specifyFileName) then
                        dialogInit()
                        addTextView(inputFileNameString)
                        newRow()
                        addEditText("pngFileName", ""..index)
                        addTextView(".png")
                        dialogShowFullScreen(settingsString)
                        pngFileName = string.gsub(pngFileName, "%s", "_")
                    else
                        pngFileName = "" .. index
                    end

                    os.execute("mv ".. luarImagePath .. tmpFileName1 ..  " " ..luarImagePath .. pngFileName..".png")


                    if (backgroundIndex ~= -1) then
                        toast (backgroundFoundString)
                        local original = { target = pngFileName .. ".png",
                                           region = reg:grow(snapRegionExtra, snapRegionExtra, snapRegionExtra, snapRegionExtra),
                                           id = pngFileName, action = action }
                        table.insert(touchList, backgroundIndex, original)
                        touchListToFile()
                    else
                        local regionText = regionToString(reg, snapRegionExtra)
                        text = string.format('touchList[index] = {target =  "%s.png", region = %s, id = "%s", action = \'%s\'}',
                                pngFileName, regionText, pngFileName, action)

                        fPointer:write("------ " .. index .. " -----\n")
                        fPointer:write(text .. "\n")
                        print(index .. ": " .. text)
                        fPointer:write("index = index + 1\n\n")
                        text = string.format("index = %d\n", index) .. text
                        local f = loadstring(text)
                        f()
                    end
                end

            end

            if (action == "swipe" or action == "dragDrop") then
                if (locationInRegion(locTable[1], stopArea)) then
                    print("stop clicked")
                    io.close(fPointer)
                    scriptExit(stopRecordString)
                end
                local reg1 = locationToRegion(locTable[1], snapWidth, snapHeight):offset(0, cutoutHeightEvent)
                locTable[1] = locTable[1]:offset(0, cutoutHeightEvent)
                reg1:save(tmpFileName1)
                local reg2 = locationToRegion(locTable[2], snapWidth, snapHeight):offset(0, cutoutHeightEvent)
                locTable[2] = locTable[2]:offset(0, cutoutHeightEvent)
                reg2:save(tmpFileName2)

                local reg1Highlight = reg1:offset(0, -cutoutHeight)
                local reg2Highlight = reg2:offset(0, -cutoutHeight)
                reg1Highlight:highlight()
                reg2Highlight:highlight(0.5)
                reg1Highlight:highlight()

                if (askDragDrop) then
                    dialogInit()
                    addTextView(dragDropAskString)
                    newRow()

                    addRadioGroup("dragDropActionDetail",2)
                    for i = 2, #dragDropOptionTable - 1 do
                        addRadioButton(dragDropOptionTable[i], i)
                    end
                    dialogShowFullScreen(dragDropAskString)
                else
                    dragDropActionDetail = dragDropAction;
                end

                if (dragDropActionDetail == 2) then
                    action = "dragDrop"
                elseif (dragDropActionDetail == 3) then
                    action = "swipe"
                elseif (dragDropActionDetail == 4) then
                    action = "findA_ClickB"
                elseif (dragDropActionDetail == 5) then
                    action = "click"
                elseif (dragDropActionDetail == 6) then
                    action = "findA_ClickB_Loc"
                elseif (dragDropActionDetail == 7) then
                    action = "swipeA_offset"
                end

                if (action == "findA_ClickB" or action == "click" or action == "findA_ClickB_Loc") then
                    click(locTable[2])
                elseif (action == "swipeA_offset") then
                    swipe(locTable[1], locTable[2])
                else
                    _G[action](locTable[1], locTable[2])
                end

                local needSecondPng = action == "dragDrop" or action == "swipe" or
                        action == "findA_ClickB";
                if (specifyFileName) then
                    dialogInit()
                    addTextView(inputDragFileNameString)
                    newRow()
                    addEditText("pngFileName1", ""..index)
                    addTextView(".png")
                    newRow()
                    addTextView("   ")
                    newRow()
                    if (needSecondPng) then
                        addTextView(inputDropFileNameString)
                        addEditText("pngFileName2", ""..index.."drop")
                        addTextView(".png")
                    end
                    dialogShowFullScreen(settingsString)
                else
                    pngFileName1 = "" .. index
                    pngFileName2 = "" .. index.."drop"
                end

                os.execute("mv ".. luarImagePath .. tmpFileName1 .. " " ..luarImagePath .. pngFileName1..".png")
                if (needSecondPng) then
                    os.execute("mv ".. luarImagePath .. tmpFileName2 ..  " " ..luarImagePath ..pngFileName2..".png")
                end
                local regionText1 = regionToString(reg1, snapRegionExtra)
                local regionText2
                if (action ~= "click" and action ~= "findA_ClickB_Loc") then
                    regionText2 = regionToString(reg2, snapRegionExtra)
                end

                if (action == "click") then
                    text = string.format('touchList[index] = {target =  Pattern("%s.png"):targetOffset(%d,%d), region = %s, id = "%s", action = \'%s\'}',
                            pngFileName1,  reg2:getX() - reg1:getX(), reg2:getY() - reg1:getY(),
                            regionText1, pngFileName1, action)
                elseif (action == "findA_ClickB_Loc") then
                    text = string.format('touchList[index] = {target =  "%s.png", region = %s, id = "%s", action = \'%s\'}',
                            pngFileName1,  regionText1, pngFileName1,
                            string.format("click(Location(%d, %d))", locTable[2]:getX(), locTable[2]:getY()))
                elseif (action == "swipeA_offset") then
                    text = string.format('touchList[index] = {target =  "%s.png", region = %s, id = "%s", action = \'%s\'}',
                            pngFileName1,  regionText1, pngFileName1,
                            string.format("swipe(matchResult, matchResult:offset(%d, %d))",
                                    locTable[2]:getX() - locTable[1]:getX(), locTable[2]:getY() - locTable[1]:getY()))
                else
                    text = string.format(
                            'touchList[index] = {target =  "%s.png", region = %s, id = "%s", action = \'%s\',\n'..
                                    '                    target2 = "%s.png", region2 = %s}',
                            pngFileName1, regionText1, pngFileName1,
                            action, pngFileName2, regionText2)
                end

                fPointer:write("------ " .. index .. " -----\n")
                fPointer:write(text .. "\n")
                text = string.format("index = %d\n", index) .. text
                local f = loadstring(text)
                f()
                print(index .. ": " .. text)
                fPointer:write("index = index + 1\n\n")

            end

            --        timer:set()
            index = index + 1
            if (waitOption) then
                hideAndWait()
            end

        end

    end

end

function hideAndWait()
    stopArea:highlightOff()
    waitArea:highlightOff()
    setHighlightStyle(0x80ffffff, true)
    setHighlightTextStyle(0x80ffffff, 0xff0000ff, 64)
    fullArea:highlight(underWaitString, waitSecond)
    setHighlightStyle(0x80ff0000, true)
    setHighlightTextStyle(0x80ff0000, 0x80ffffff, 16)
    stopArea:highlight("Stop!")
    waitArea:highlight("Wait!")
end

------------------ playback related functions -------------------

function scandir(directory)

    local listFile = localPath .. "__list"
    local command = "ls " .. directory .. " > " .. listFile
    os.execute(command)

    local lines = {}
    local i = 1
    for line in io.lines(listFile) do
        lines[#lines + 1] = line
    end

    os.execute("rm " .. listFile)
    return lines
end

---------------------------- playback related functions ------------------
function playback()

    local fileList = scandir(luarPath ..  "*.luar")
    if (#fileList == 0) then
        scriptExit(noLuarString)
    end

    dialogInit()

    addTextView(similarString)
    addEditNumber("similar", 0.9)
    newRow()
    
    newRow()

    addCheckBox("searchLimit", searchPngString, false)
    --    addEditNumber("pngIndex", 1)
    --    addTextView(".png ")
    --    addEditNumber("pngTimes", 5)
    --    addTextView(searchTimesString)
    newRow()


    --    addTextView(timesString)
    --    addEditNumber("times", 5)
    --    newRow()
    addCheckBox("allWithRegion", allWithRegionString, false)

newRow()
    addTextView( minIntervalString)
    addEditNumber("scanInterval", 0)

    newRow()
    addCheckBox("debug", "debug", false)
    newRow()
    --    addSeparator()

    addTextView(scriptToPlayString)
    newRow()
    addRadioGroup("fileNum", 1)
    for i, f in ipairs(fileList) do
        local subString = localPath .. "luar/"
        local shortName = string.gsub(f, luarPath, "")
        addRadioButton(shortName, i)
        fileList[i] = shortName
    end
    newRow()
    dialogShowFullScreen(settingsString)
    Settings:set("MinSimilarity", similar)

    setScanInterval(scanInterval)

    fileName = fileList[fileNum]
    dofile (luarPath .. fileName)

    if (not searchLimit) then
        pngIndex = -1
    end

    if (not randomClick) then randomClickNumber = 0 end

    if (not allWithRegion or searchLimit) then
        dialogInit()

        if (searchLimit) then
            local spinner = {}
            for i = 1, table.getn(touchList) do
                table.insert(spinner, touchList[i].id)
            end
            addTextView(searchPngPreString)
            addSpinnerIndex("pngIndex", spinner, 1)
            addTextView(".png ")
            addEditNumber("pngTimes", 5)
            addTextView(searchTimesString)
            newRow()
            newRow()
        end

        if (not allWithRegion) then
            addTextView(whichWithRegionString)
            newRow()
            for i = 1, table.getn(touchList) do
                addCheckBox("withRegion"..i, "  " .. touchList[i].id, true)
                newRow()
            end
        end
        dialogShowFullScreen(settingsString)

        if (not allWithRegion) then
            for i = 1, table.getn(touchList) do
                if (not _G["withRegion"..i]) then
                    touchList[i].region = nil
                end
            end
        end
    end

    if (dim) then
        setBrightness(1)
    end

    luarImagePath = luarPath .. string.sub(fileName, 1, -6) .. "Image"

    setImagePath(luarImagePath)

    local index = 1
    local timer = Timer()
    local findTimes = 0
    local pngTimesList = {}
    for i = 1, table.getn(touchList) do
        pngTimesList[i] = 0
    end

    if (continueScan == nil) then
        continueScan = not allFromBeginning
    end

    while (true) do
        if (timeLimit and timer:check() >= (runTime * 60)) then
            scriptExit(string.format(timeReachString, runTime))
        end
        local choice, id, match = regionWaitMulti(touchList, 30, debug, nil, index)
        if (choice ~= -1 and match) then
            if (debug) then print("find "..id) end

            if (pngTimesList[choice]) then
                pngTimesList[choice] = pngTimesList[choice] + 1
            else
                pngTimesList[choice] = 0;
            end

            local stopMessage = "stopped"
            for i = 1, table.getn(touchList) do
                --            for i, t in ipairs(touchList) do
                if (touchList[i] and pngTimesList[i]) then
                    stopMessage = stopMessage .. touchList[i].id..": "..pngTimesList[i] .."\n"
                end
            end
            setStopMessage(stopMessage)

            if (debug) then
                match:offset(0, -cutoutHeight):highlight(0.5)
            end
            if (choice == pngIndex) then
                findTimes = findTimes + 1
                if (findTimes == pngTimes) then
                    scriptExit(string.format(searchReachString, touchList[pngIndex].id, pngTimes))
                end
            end

            local matchObject = touchList[choice]
            local matchLocation = match:getTarget()
            if (randomClick) then
                local targetLoc = match:getTarget()
                local centerLoc = match:getCenter()
                match:setTargetOffset(targetLoc:getX()  - centerLoc:getX()+ math.random(-randomClickNumber, randomClickNumber),
                        targetLoc:getY() - centerLoc:getY() + math.random(-randomClickNumber, randomClickNumber))
            end
            if (not matchObject.action) then matchObject.action = "click" end

            if (matchObject.action == "click" or
                    matchObject.action == "doubleClick") then
                _G[matchObject.action](match)
            elseif (matchObject.action == "longClick") then
                _G[matchObject.action](match, 1.5)
            elseif (matchObject.action == "swipe" or matchObject.action == "dragDrop" or
                    matchObject.action == "findA_ClickB") then
                local match2 = targetExists({target = matchObject.target2, region = matchObject.region2}, 0)
                if (match2) then
                    if (debug) then match2:offset(0, -cutoutHeight):highlight(0.5) end
                    local match2Location = match2:getTarget()
                    if (randomClick) then
                        match2 = match2Location:offset(math.random(2*randomClickNumber) - randomClickNumber,
                                math.random(2*randomClickNumber) - randomClickNumber)
                    end
                    if (matchObject.action == "findA_ClickB") then
                        click(match2)
                    else
                        _G[matchObject.action](match, match2)
                    end
                end
            else
                matchResult = match
                local func = assert(loadstring(matchObject.action))
                func()
            end
            wait(2)
            if (continueScan) then index = choice + 1 end
        end
    end

end


localPath = scriptPath()
luarPath = localPath .. "luar/"
loadStringsFunction()

print ("Version: " .. version)

local width = getRealScreenSize():getX()
local height = getRealScreenSize():getY()
cutoutHeight = 0
detectCutout = false

dialogInit()
if (getVersion() >= "8.2.0") then
    detectCutout = false
else
    if (width  < height) then
        addCheckBox("detectCutout", cutoutString, false)
        newRow()
        addSeparator()
    end
end

addTextView(chooseActionString)
newRow()
addRadioGroup("actionSelect", 2)
addRadioButton(recordString, 1)
addRadioButton(playString, 2)
addRadioButton(expandString, 3)


cutoutHeightEvent = 0
if (detectCutout) then
    cutoutHeightEvent = cutoutHeightMeasure(0) -- real cutout height, for recording input position
    print("cutout height = " .. cutoutHeightEvent)
    cutoutHeight = cutoutHeightMeasure(cutoutHeightEvent * 2) -- region highlight offset
    print("cutut highlight offset = " .. cutoutHeight)
end

if (actionSelect == 1 or actionSelect == 3) then
    record(actionSelect == 3)
else
    playback()
end
