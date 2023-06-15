--[[
    This script will export your aseprite sprite to the supplied specifications.
    For ease of use, these specifications are stored in the following path:
    %appdata%\Roaming\Aseprite\exporttogm\

    The dialog will autofill with the text found in these files, should they exist. The files will be overwritten/created upon pressing OK.

    For support, contact @thinedave#1661 via Discord, or via https://github.com/thinedave.

    CREDITS:
    thinedave - Script creation
    Massimog - save_tags_as_gifs script creation and assistance

    MIT License
    Copyright 2023 thinedave
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
    to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local file = app.fs
local cmd = app.command
local spr = app.activeSprite

-- fuck lua for not having a native copy function
function io.fileCopy(filepath, todir)
    if(not file.isFile(filepath)) then
        print("File not found at "..filepath)
        return false

    end

    local fl = io.open(filepath, "r+")
    local contents = fl:read("*all")

    fl = io.open(todir, "w")
    fl:write(contents)

end

file.makeDirectory(file.joinPath(file.userConfigPath, "exporttogm"))

local configPath = file.joinPath(file.userConfigPath, "exporttogm", "gms2projectpath.txt")
local spriteNamePath = file.joinPath(file.userConfigPath, "exporttogm", "gms2spritename.txt")
local projectNamePath = file.joinPath(file.userConfigPath, "exporttogm", "gms2projectname.txt")
local piggyBackPath = file.joinPath(file.userConfigPath, "exporttogm", "gms2piggybackname.txt")
local targetFPSPath = file.joinPath(file.userConfigPath, "exporttogm", "gms2fpstarget.txt")
local projectPath = ""
local spritesPath = ""
local piggyBackName = ""
local spriteName = ""
local projectName = ""
local fpsTarget = ""

if(file.isFile(configPath)) then
    local fl = io.open(configPath, "r")

    projectPath = fl:read()

end

if(file.isFile(piggyBackPath)) then
    local fl = io.open(piggyBackPath, "r")

    piggyBackName = fl:read()

end

if(file.isFile(spriteNamePath)) then
    local fl = io.open(spriteNamePath, "r")

    spriteName = fl:read()

end

if(file.isFile(projectNamePath)) then
    local fl = io.open(projectNamePath, "r")

    projectName = fl:read()

end

if(file.isFile(targetFPSPath)) then
    local fl = io.open(targetFPSPath, "r")

    fpsTarget = fl:read()

end

local data = Dialog():entry{
    id = "project_name",
    label = "GMS2 Project Name",
    text = projectName,
    focus = true,

}:entry{
    id = "project_path",
    label = "GMS2 Project Path",
    text = projectPath,
    focus = true,

}:entry{
    id = "sprite_name",
    label = "Sprite Name",
    text = spriteName,
    focus = true,

}:entry{
    id = "piggyback_name",
    label = "Piggyback Sprite Name",
    text = piggyBackName,
    focus = true,

}:entry{
    id = "fps_target",
    label = "Game FPS",
    text = fpsTarget,
    focus = true,

}:button{
    id= "confirm",
    text = "OK",

}:button{
    id = "cancel",
    text = "Cancel",

}:show().data

if (not data.confirm) then
    print("hm")
    return

end

local spritesPath = file.joinPath(data.project_path, "sprites")

local fl = io.open(configPath, "w")
fl:write(data.project_path)
fl = io.open(spriteNamePath, "w")
fl:write(data.sprite_name)
fl = io.open(projectNamePath, "w")
fl:write(data.project_name)
fl = io.open(piggyBackPath, "w")
fl:write(data.piggyback_name)
fl = io.open(targetFPSPath, "w")
fl:write(data.fps_target)

local piggybackUUID = ""

for _, v in pairs(file.listFiles(file.joinPath(spritesPath, data.piggyback_name))) do
    if(v:sub(-4) == ".png") then
        piggybackUUID = v:sub(1, -5)

        break

    end

end

for index, tag in ipairs(spr.tags) do
    file.makeDirectory(file.joinPath(spritesPath, data.sprite_name.."_"..tag.name))

    local tagFrames = {}

    for i, v in ipairs(spr.frames) do
        if(i >= tag.fromFrame.frameNumber and i <= tag.toFrame.frameNumber) then
            tagFrames[#tagFrames+1] = v

        end

    end

    local tagsprite = Sprite(spr)

    for j,s in ipairs(tagsprite.frames) do
        if((tag.fromFrame.frameNumber == tag.toFrame.frameNumber and tag.fromFrame.frameNumber ~= j) or (j < tag.fromFrame.frameNumber or j > tag.toFrame.frameNumber)) then
            tagsprite:deleteFrame(s)

        end

    end

    local pth = file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, "frame0.png")

    tagsprite:saveCopyAs(pth)

    local yypath = file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, data.sprite_name.."_"..tag.name..".yy")

    local yystr = [[
    {
        "resourceType": "GMSprite",
        "resourceVersion": "1.0",
        "name": "]]..data.sprite_name.."_"..tag.name..[[",
        "bbox_bottom": ]]..spr.height..[[,
        "bbox_left": 0,
        "bbox_right": ]]..spr.width..[[,
        "bbox_top": 0,
        "bboxMode": 0,
        "collisionKind": 1,
        "collisionTolerance": 0,
        "DynamicTexturePage": false,
        "edgeFiltering": false,
        "For3D": false,
        "frames": [
    ]]

    for i, v in pairs(tagFrames) do
        print(v.duration*60)
        for k = 1, v.duration*60 do
            yystr = yystr..[[
            {"resourceType":"GMSpriteFrame","resourceVersion":"1.1","name":"]].."frame"..(i-1)..[[",},
            ]]
        end

    end

    yystr = yystr..[[
        ],
        "gridX": 0,
        "gridY": 0,
        "height": ]]..spr.height..[[,
        "HTile": false,
        "layers": [
            {"resourceType":"GMImageLayer","resourceVersion":"1.0","name":"]].."frame0"..[[","blendMode":0,"displayName":"default","isLocked":false,"opacity":100.0,"visible":true,},
        ],
        "nineSlice": null,
        "origin": 7,
        "parent": {
            "name": "]]..data.project_name..[[",
            "path": "]]..data.project_name..[[.yyp",
        },
        "preMultiplyAlpha": false,
        "sequence": {
            "resourceType": "GMSequence",
            "resourceVersion": "1.4",
            "name": "]]..data.sprite_name.."_"..tag.name..[[",
            "autoRecord": true,
            "backdropHeight": 768,
            "backdropImageOpacity": 0.5,
            "backdropImagePath": "",
            "backdropWidth": 1366,
            "backdropXOffset": 0.0,
            "backdropYOffset": 0.0,
            "events": {"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"1.0","Keyframes":[],},
            "eventStubScript": null,
            "eventToFunction": {},
            "length": ]]..#tagFrames..[[.0,
            "lockOrigin": false,
            "moments": {"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"1.0","Keyframes":[],},
            "playback": 1,
            "playbackSpeed": ]]..data.fps_target..[[,
            "playbackSpeedType": 0,
            "showBackdrop": true,
            "showBackdropImage": false,
            "timeUnits": 1,
            "tracks": [
                {"resourceType":"GMSpriteFramesTrack","resourceVersion":"1.0","name":"frames","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"1.0","Keyframes":[
    ]]

    local fuck = 0

    for i, v in pairs(tagFrames) do
        for k = 1, v.duration*60 do
            yystr = yystr..[[
            {"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"1.0","Channels":{"0":{"resourceType":"SpriteFrameKeyframe","resourceVersion":"1.0","Id":{"name":"]]..piggybackUUID..[[","path":"sprites/]]..data.piggyback_name..[[/]]..data.piggyback_name..[[.yy",},},},"Disabled":false,"id":"]]..piggybackUUID..[[","IsCreationKey":false,"Key":]]..fuck..[[.0,"Length":1.0,"Stretch":false,},
            ]]
            fuck = fuck + 1
        end

    end

    yystr = yystr..[[
                ],},"modifiers":[],"spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
            ],
            "visibleRange": null,
            "volume": 1.0,
            "xorigin": 0,
            "yorigin": 0,
        },
        "swatchColours": null,
        "swfPrecision": 2.525,
        "textureGroupId": {
        "name": "Default",
        "path": "texturegroups/Default",
        },
        "type": 0,
        "VTile": false,
        "width": ]]..spr.width..[[,
    }
    ]]

    fl = io.open(file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, data.sprite_name.."_"..tag.name..".yy"), "w")
    fl:write(yystr)

    --layers folder

    file.makeDirectory(file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, "layers"))

    for i, _ in pairs(tagFrames) do
        file.makeDirectory(file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, "layers", "frame"..(i-1)))

        io.fileCopy(file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, "frame"..(i-1)..".png"), file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, "layers", "frame"..(i-1), "frameLYR.png"))

        --[[cmd.SaveFileCopyAs{
            ui = false,
            filename = file.joinPath(spritesPath, data.sprite_name.."_"..tag.name, "layers", "frame"..(i-1), "frame"..(i-1)..".png"),
            ["from-frame"] = i-1,
            ["to-frame"] = i-1,

        }]]

    end

    --resource order
    --this is so fucked up
    fl = io.open(file.joinPath(data.project_path, data.project_name..".resource_order"), "r")
    local resourceOrderStr = fl:read("*all")
    local resourceOrderTbl = {}

    for v in resourceOrderStr:gmatch("([^\n]*)\n?") do
        resourceOrderTbl[#resourceOrderTbl+1] = v

    end

    local doResource = true

    for _, v in pairs(resourceOrderTbl) do
        if(v == "    {\"name\":\""..data.sprite_name.."_"..tag.name.."\",\"order\":0,\"path\":\"sprites/"..data.sprite_name.."_"..tag.name.."/"..data.sprite_name.."_"..tag.name..".yy\",},") then
            doResource = false

        end

    end

    if(doResource) then
        for i, _ in pairs(resourceOrderTbl) do
            local addBracket = false

            if(resourceOrderTbl[i] == "  \"ResourceOrderSettings\": []," or resourceOrderTbl[i] == "  \"ResourceOrderSettings\": []") then
                addBracket = true

                resourceOrderTbl[i] = "  \"ResourceOrderSettings\": ["

            end

            if(resourceOrderTbl[i] == "  \"ResourceOrderSettings\": [") then
                table.insert(resourceOrderTbl, i+1, "    {\"name\":\""..data.sprite_name.."_"..tag.name.."\",\"order\":0,\"path\":\"sprites/"..data.sprite_name.."_"..tag.name.."/"..data.sprite_name.."_"..tag.name..".yy\",},")

                if(addBracket) then
                    table.insert(resourceOrderTbl, i+2, "  ],")

                end

                break

            end

        end

        local newResourceOrderStr = ""

        for _, v in pairs(resourceOrderTbl) do
            newResourceOrderStr = newResourceOrderStr.."\n"..v

        end

        print(newResourceOrderStr)

        fl = io.open(file.joinPath(data.project_path, data.project_name..".resource_order"), "w")

        fl:write(newResourceOrderStr)

        fl:close()

    end

    --yyp registration
    fl = io.open(file.joinPath(data.project_path, data.project_name..".yyp"), "r")
    local yypStr = fl:read("*all")
    local yypTbl = {}

    for v in yypStr:gmatch("([^\n]*)\n?") do
        yypTbl[#yypTbl+1] = v

    end

    local doYYP = true

    for _, v in pairs(yypTbl) do
        if(v == "    {\"id\":{\"name\":\""..data.sprite_name.."_"..tag.name.."\",\"path\":\"sprites/"..data.sprite_name.."_"..tag.name.."/"..data.sprite_name.."_"..tag.name..".yy\",},},") then
            doYYP = false

        end

    end

    if(doYYP) then
        for i, _ in pairs(yypTbl) do
            local addBracket = false

            if(yypTbl[i] == "  \"resources\": []," or yypTbl[i] == "  \"resources\": []") then
                addBracket = true

                yypTbl[i] = "  \"resources\": ["

            end

            if(yypTbl[i] == "  \"resources\": [") then
                table.insert(yypTbl, i+1, "    {\"id\":{\"name\":\""..data.sprite_name.."_"..tag.name.."\",\"path\":\"sprites/"..data.sprite_name.."_"..tag.name.."/"..data.sprite_name.."_"..tag.name..".yy\",},},")

                if(addBracket) then
                    table.insert(yypTbl, i+2, "  ],")

                end

                break

            end

        end

        local newYYPStr = ""

        for _, v in pairs(yypTbl) do
            newYYPStr = newYYPStr.."\n"..v

        end

        print(newYYPStr)

        fl = io.open(file.joinPath(data.project_path, data.project_name..".yyp"), "w")

        fl:write(newYYPStr)

        fl:close()

    end

    tagsprite:close()

end