--[[
This is my mapper with some changes to fit EF gmap command
I forget if I kept working on CoffeeMud mapper after splitting this off or not.  Maybe I should merge some of that in to this again.
And then changed again for Cheeseworld that I'm adding room data to
--]]

mudlet = mudlet or {}
mudlet.mapper_script = true


function RoomEvent()

  local function deb(msg)
    if(spam) then
      echo(msg)
    end
  end

  local function findAreaID(areaname)
    local list = getAreaTable()
    local returnid, fullareaname
    for area, id in pairs(list) do
      if area:find(areaname, 1, true) then
        if returnid then return false, "more than one area matches" end
        returnid = id; fullareaname = area
      end
    end
    return returnid, fullareaname
  end




  deb("BEFORE...")
  if not gmcp or not gmcp.Room then
    deb("handle_room was called prior to getting room data")
    return
  end
  local localHash = gmcp.Room.id
  local localID = getRoomIDbyHash(localHash)
  deb("A")
  if localID == -1 then
    echo("\nALERT! teleport? creating room that you are currently in\n")
    deb("creating this room that you are currently in")
    localID = createRoomID()
    setRoomIDbyHash(localID, localHash)
    addRoom(localID)
    centerview(localID)
  end
  
  if gmcp.Room.file then
    setRoomUserData(localID, "file", gmcp.Room.file)
  end
  
  local areaID = findAreaID(gmcp.Room.area)
  if areaID == nil then
    areaID = addAreaName(gmcp.Room.area)
    --echo("\nALERT created area "..gmcp.room.info.zone)
  end
  
  deb("B")
  setRoomName(localID, gmcp.Room.short)
  if getRoomArea(localID) and (getRoomArea(localID) ~= -1) then
    -- allow user to manually set an area and keep it,
    -- for hand-crafting zones and submitting back to the game
    -- so change it but only if current is unchanged from initial
    local strA, strB, strC
    strA = getRoomUserData(localID,"initialArea")
    strB = getRoomAreaName(getRoomArea(localID))
    strC = gmcp.Room.area
    --A is metadata variable, set before visiting based on neighbors
    --B is current room area, set at creation and then the result of manual changes
    --C is told to me by GMCP when visiting the room.
    --If C != B then I want to know if I've moved it
    --If (C != B) AND (B != A) then I have manually set it
    --if (C != B) AND (B == A) then it was given at creation and untouched so go ahead and change.
    deb("\nalready has an area ID, ")
    if getRoomAreaName(getRoomArea(localID))== gmcp.Room.area then
      deb("it is already in area suggested by game\n")
    else
      --the above if statement got C==B so this else is C!=B
      deb(string.format("\n it is in %s,\n game suggests %s,\n initial guess was %s\n",strB,strC,strA))
      if strB == strA then
        deb("current area is equal to initial area so move\n")
        setRoomArea(localID, gmcp.Room.area)
        clearRoomUserDataItem(localID,"initialArea") -- only do it once
      else
        deb("current area is not equal to initial area, was manually set\n")
      end
    end
  else
    --room is currently in default zone so go ahead and set it
    deb("room is currently in default zone so go ahead and set it")
    setRoomArea(localID, gmcp.Room.area)
  end
  deb("C")
  
  if gmcp.Room.coords then
    deb("game sent us coordinates")
    --echo("GAME GAVE COORDINATES\n")
    local loc = gmcp.Room.coords
    deb(string.format("coords given by game are %d,%d,%d\n",loc.x,loc.y,loc.z))
    setRoomCoordinates(localID, loc.x, loc.y, loc.z)
  else
    --echo("GAME GAVE NO COORDINATES\n")
    deb("game did not send us coordinates")
  end
  --[[
  local coord = gmcp.room.info.coord
  if(coord.x ~= -1 or coord.y ~= -1 or coord.cont ~= 0 or coord.id ~= -0) then
    echo(string.format("\nALERT! non-default coords found in room %s:\n x=%s y=%s cont=%s id=%s\n",
      localID, coord.x, coord.y, coord.cont, coord.id))
  end
  --]]
  deb("D")
  local exitText = "Exits:<br>"
  for k,v in pairs(gmcp.Room.exits) do
    deb("[handle "..k.."]")
    --exitText = exitText..string.format("%s<br>",k)
    local specialDirection = false
    local destID = getRoomIDbyHash(v)
    deb("[about to check if should create]")
    if destID == -1 then
      deb("[creating]");
      destID = createRoomID()
      setRoomIDbyHash(destID, v)
      addRoom(destID)
      deb("a")
      local x,y,z = getRoomCoordinates(localID)
      deb("b")
      deb(string.format("\nam in %s at %s,%s,%s...\n",localID,x,y,z))
      deb("c")

      if k=="north" then y=y+1
      elseif k=="south" then y=y-1
      elseif k=="northwest" then y=y+1 x=x-1
      elseif k=="northeast" then y=y+1 x=x+1
      elseif k=="southwest" then y=y-1 x=x-1
      elseif k=="southeast" then y=y-1 x=x+1
      elseif k=="east" then x=x+1
      elseif k=="west" then x=x-1
      elseif k=="up" then z=z+1
      elseif k=="down" then z=z-1
      elseif k=="southwestup" then y=y-1 x=x-1 z=z+1
      elseif k=="in" or k=="out" then
        z=z+5
        specialDirection = true --actually might not be special, check if it is
      else
        echo("\nDo not recognize ["..k.."] so will make it z+10")
        z=z+10
        specialDirection = true
      end
      
      deb("d")
      deb(string.format("\ncreated room %s at %s,%s,%s\n",destID,x,y,z))
      setRoomCoordinates(destID,x,y,z)
      setRoomArea(destID, gmcp.Room.area) -- initially put neighboring room in local area
      -- set metadata saying initial area so that I know if I manually moved it
      setRoomUserData(destID, "initialArea", gmcp.Room.area)
    end
    deb("[after if]")
    deb("\nabout to setExit, "..localID.." "..destID.." "..k)
    deb("[check if common]")
    if table.index_of(({"north","south","east","west","northwest","northeast","southwest","southeast","up","down"}), k) then
      deb("[is common]")
      setExit(localID, destID, k)
    else
      deb("[not common]")
      addSpecialExit(localID, destID, k)
    end
    deb("w")
    local a1,b1,c1=getRoomCoordinates(localID)
    local a2,b2,c2=getRoomCoordinates(destID)
    deb("x")
    if (math.abs(a2-a1) > 1 or math.abs(b2-b1) > 1) then
      deb("\nhmm, rooms are spread out, this is a good point to check on the override thing and suggest one\n")
      deb(string.format("local %s is at %s,%s, dest %s to %s is at %s,%s",localID,a1,b1,k,destID,a2,b2))
      --get hash from room ID (if it isn't still in a variable) and print them
      --also, make an alias that does this same thing but loops through all rooms to produce list
    end
    deb("y")
    exitText = string.format("%s%s %s<br>",exitText,k,(getRoomName(destID) or "<i>unvisited</i>"))
    deb("z")
  end
  --TODO: look at current list of exits and list from getRoomExits+getSpecialExits and delete any that are missing now
  deb("E")
--  GUI.Box3:echo(exitText)
  if not crawling then
    updateMap()
    centerview(localID)
  end
  --[[
  GUI.Box3:echo(exitText)
  GUI.Box7:echo(string.format("Location:<br>name: %s<br>id: %s<br>num: %s<br>terrain: %s<br>zone: %s<br>details: %s<br>desc: %s",
    gmcp.room.info.name or "Undefined",
    gmcp.room.info.id or "Undefined",
    gmcp.room.info.num or "Undefined",
    gmcp.room.info.terrain or "Undefined",
    gmcp.room.info.zone or "Undefined",
    gmcp.room.info.details or "Undefined",
    gmcp.room.info.desc or "Undefined"
  ))
  --]]
  deb("...AFTER")
end
