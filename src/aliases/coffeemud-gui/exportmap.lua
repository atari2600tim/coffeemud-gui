--[[
This simulates samples from https://wiki.mudlet.org/w/Standards:MMP


If you import a map from file that has custom colors selected for environments,
it sets the color internally but does not update the user-accessible data.
So if you want exported file to have colors beyond the reserved ones, you will
want to set them through setCustomEnvColor(envID,r,g,b,a) as well.


Mudlet does not store environment names.
If you would like to put such names into your exported map, track them in
a table with key of ID number in a string and value of name, then convert it to
json and then place it into map user data called EnvNames.

local envNames=yajl.to_value(getMapUserData("EnvNames") or "{}")
envNames["78"]="Scrublands"
envNames["79"]="Tower"
envNames["81"]="Twisted Forest Council"
envNames["82"]="Arctic"
envNames["83"]="Orc stronghold"
envNames["84"]="Goblin Village"
envNames["85"]="Tavern"
envNames["86"]="Ocean Dome"
setMapUserData("EnvNames", yajl.to_string(envNames))


For example, if your input file has this:
 <environment id="21" name="Garden" color="10" htmlcolor="#00FF00" />
you would want to:
 setCustomEnvColor(21, 0, 255, 0, 255)
 EnvNames["21"] = "Garden"
--]]



local function encodeXML (str)
-- & is first because enclosed in others
-- ' only needs encoded if used inside of a string with " around it
-- same deal for " inside of '
-- I am going to use " on all my strings here.
-- > doesn't need encoded but you can for consistency with the <
  str = string.gsub(str,"&","&amp;") -- first because enclosed in others
  --str = string.gsub(str,"'","&apos;") 
  str = string.gsub(str,"\"","&quot;")
  str = string.gsub(str,"<","&lt;")
  --str = string.gsub(str,">","&gt;")
  return str
end

local function rgbToAnsi (r,g,b)
  for i = 0, 255 do
    local x,y,z = unpack(color_table[string.format("ansi_%03d",i)])
    if x==r and y==g and z==b then
      return i
    end
  end
  return nil
end

local timePre = getEpoch()


local outputAreas, outputRooms, outputEnvs = "","",""
local numAreas, numRooms, numEnvs
local output = ""
local areaList = getAreaTable()
local roomList = getRooms()
local envList = {}
local envNames = yajl.to_value(getMapUserData("EnvNames") or "{}")


local areaListByID = {}
local sortedAreaIDs = {}
for k,v in pairs(areaList) do
  areaListByID[v]=k
  table.insert(sortedAreaIDs, v)
end
table.sort(sortedAreaIDs)
numAreas = #sortedAreaIDs
for i=1, numAreas do
  local areaID = sortedAreaIDs[i]
  local areaName = areaListByID[areaID]
  if areaID ~= -1 then
    outputAreas = string.format("%s\n   <area id=\"%s\" name=\"%s\" x=\"0\" y=\"0\" />",
      outputAreas,areaID,encodeXML(areaName))
  end
  if (#getAllAreaUserData(areaID)>0) then
    echo(string.format("Area %s has metadata I didn't handle yet\n",areaID))
  end
  if (#getMapLabels(areaID)>0) then
    echo(string.format("Area %s has map labels I didn't handle yet\n",areaID))
  end
end


local roomListIDs = {}
for k,_ in pairs(roomList) do
  table.insert(roomListIDs, k)
end
table.sort(roomListIDs)
numRooms = #roomListIDs
for i=1, numRooms do
  local roomID = roomListIDs[i]
  local x,y,z = getRoomCoordinates(roomID)
  local roomArea = getRoomArea(roomID)
  local roomEnv = getRoomEnv(roomID)
  local roomUserData = getAllRoomUserData(roomID)
  local roomInfo = string.format("   <room id=\"%s\" area=\"%s\" title=\"%s\"",
    roomID,roomArea,encodeXML(getRoomName(roomID)))
  if roomArea ~= -1 then -- skip unvisited rooms that are in the default area
    if roomEnv ~= -1 then  -- is environment optional in xml map? there is an environment on every line in sample map.xml
      envList[roomEnv] = 1
      roomInfo = string.format("%s environment=\"%s\"",roomInfo,roomEnv)
    end
    for k,v in ipairs(roomUserData) do
      roomInfo = string.format("%s %s=\"%s\"", roomInfo, v, encodeXML(getAllRoomUserData(v)))
    end
    roomInfo = string.format("%s>\n      <coord x=\"%s\" y=\"%s\" z=\"%s\" />",
      roomInfo,x,y,z)
    local exitsList = getRoomExits(roomID)
    for dir,dest in pairs(exitsList) do
      roomInfo = string.format("%s\n      <exit direction=\"%s\" target=\"%s\" />",
        roomInfo,dir,dest)
    end

    outputRooms = string.format("%s\n%s\n   </room>", outputRooms, roomInfo)
    
    if (#getAllRoomUserData(roomID)>0) then
      echo(string.format("Room %s has metadata I didn't handle yet\n",roomID))

    end
  end
end

local envIDs = {}
for k,_ in pairs(envList) do
  table.insert(envIDs, k)
end
table.sort(envIDs)
numEnvs = #envIDs
envNames = envNames or {}
for i=1, numEnvs do
  local envID = envIDs[i]
  local rgba = getCustomEnvColorTable()[i]
  if (1<=i and i<=16) then -- 1-16 are reserved
    local a,b,c = unpack(color_table[string.format("ansi_%03d",i)])
    rgba = {a,b,c,255}
  end
  local envInfo = string.format("\n   <environment id=\"%s\"",envID)
  if envNames[i] then
    envInfo=string.format("%s name=\"%s\"",envInfo,envNames[i])
  end 
  if rgba ~= nil then
    local r,g,b,a = unpack(rgba)
    local ansiColor = rgbToAnsi(r,g,b)
    if ansiColor ~= nil then
      envInfo = string.format("%s color=\"%s\"",envInfo,ansiColor)
    end
    envInfo = string.format("%s htmlcolor=\"#%02X%02X%02X\"",envInfo,r,g,b)
  end
  envInfo = envInfo.." />"  
  outputEnvs = outputEnvs..envInfo
end

output = string.format(
  "<?xml version=\"1.0\"?>\n<map>\n<areas>%s\n</areas>\n<rooms>%s\n</rooms>\n<environments>%s\n</environments>\n</map>",
  outputAreas,outputRooms,outputEnvs)

if (#getAllMapUserData()>0) then
  echo ("getAllMapUserData() shows some metadata that I didn't handle yet\n")
end

io.output(getMudletHomeDir().."/exportmap.txt")
io.write(output)
io.close()
echo("Wrote to "..getMudletHomeDir().."/exportmap.txt\n")

local timeStamp = getTime(true, "yyyy-MM-dd#HH-mm-ss")
io.output(getMudletHomeDir().."/"..timeStamp..".txt")
io.write(output)
io.close()
echo("Wrote to "..getMudletHomeDir().."/"..timeStamp..".txt\n")


local timePost = getEpoch()
echo(string.format("There were %d areas and %d rooms with %d environments.  Done in %.3f seconds.\n",
  numAreas,numRooms,numEnvs,timePost-timePre))

