--[[
most notes are at https://github.com/atari2600tim/coffemud-mapper/wiki/Sample-GMCP-data

I should probably make an initial map with just the newbie area
https://wiki.mudlet.org/w/Standards:MMP
and then include it in resources folder and run a function
 to load it once if map is empty
Or maybe just manually load it, and tell CoffeeMud people that
here is a file for them to send GMCP message about
Or maybe parse the area files? although I think they don't have an id until import

Once I figure out how to build the message, here is how to write text to file:
https://forums.mudlet.org/viewtopic.php?t=4305

That way the newbie area at least I could manually adjust a bit.
For areas they have to explore though... should I have a list of exceptions?
"If you ever find room 123 then the west exit is 3 spaces long"?
"Room 123 is at x,y"?


In Mud School there is some overlap...
see if there is a good way to stretch all parallel lines or what
 ED
 F
 CB
  A
like maybe if you move ABCBDE and you see that F is not C then move ABC all down so BD is longer?





lua gmcp.room
{
  enter = "the tridrone",
  info = {
    coord = {
      cont = 0,
      id = 0,
      x = -1,
      y = -1
    },
    desc = "You are in the Arena.  Remember, if you wish to get out of this Arena, just go up.  
Ceilings can barely be seen in this huge Arena.  You feel as if you are being watched by some 
divine being.",
    details = "",
    exits = {
      E = 299884722,
      N = 299884726,
      U = 299884841,
      W = 299884720
    },
    id = "Mud School#3722",
    name = "South Wall of Arena",
    num = 299884719,
    terrain = "desert",
    zone = "Mud School"
  },
  wrongdir = "S"
}
just noticed outside of room.info, what is room.enter="the tridone"?

--]]

uninstallPackage("generic_mapper")
--TODO: When I first added the uninstallPackage line, it crashed Mudlet.
--I had exported to a package and then imported it to other profile and added this line.
--No problem next time.
--Experiment some with it and see if I can repeat crash.

mudlet = mudlet or {}
mudlet.mapper_script = true

--For manual override of 1 unit grid, put pairs of rooms into specialVectors list,
--Key is 2 room IDs lower to higher separated by space, then values are x,y,z from first room to second
--TODO: namespace this when I'm done
specialVectors={
  ["12345 23456"]={10,0,0} -- just showing format
}
--[[
TODO: I'm not sure if this is enough now that I think of it.
What if you enter a zone and leave and come back in other part of the zone?
Enter from the west edge of the map and leave without exploring then enter from the east edge of the map...
this manual offset thing will work fine with walking around the outside of walls,
but leaving the zone and then coming back is different story.
--]]

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
  if not gmcp or not gmcp.room or not gmcp.room.info or not gmcp.room.info.num then
    deb("handle_room was called prior to getting room data")
    return
  end
  local localID = getRoomIDbyHash(gmcp.room.info.num)
  deb("A")
  if localID == -1 then
    deb("creating this room that you are currently in")
    localID = createRoomID()
    setRoomIDbyHash(localID, gmcp.room.info.num)
    addRoom(localID)
    centerview(localID)
  end
  
  local areaID = findAreaID(gmcp.room.info.zone)
  if areaID == nil then
    areaID = addAreaName(gmcp.room.info.zone)
    echo("\nALERT created area "..gmcp.room.info.zone)
  end
  
  deb("B")
  setRoomName(localID, gmcp.room.info.name)
  setRoomArea(localID, gmcp.room.info.zone)
  deb("C")
  local coord = gmcp.room.info.coord
  if(coord.x ~= -1 or coord.y ~= -1 or coord.cont ~= 0 or coord.id ~= -0) then
    echo(string.format("\nALERT! non-default coords found in room %s:\n x=%s y=%s cont=%s id=%s\n",
      localID, coord.x, coord.y, coord.cont, coord.id))
  end
  
  deb("D")
  local exitText = "Exits:<br>"
  for k,v in pairs(gmcp.room.info.exits) do
    deb("[handle"..k.."]")
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
      deb(string.format("\nam in %s at %s,%s,%s...",localID,x,y,z))
      deb("c")

      local offset = specialVectors[((localID<destID) and localID.." "..destID) or (destID.." "..localID)]
      if offset then
        deb("\nusing special override for path between "..localID.." and "..destID)
        if localID < destID then
          x=x+offset[1] y=y+offset[2] z=z+offset[3]
        else
          x=x-offset[1] y=y-offset[2] z=z-offset[3]
        end
        if not table.index_of(({"N","S","E","W","U","D"}), k) then
          specialDirection = true
        end
      elseif k=="N" then y=y+1
      elseif k=="S" then y=y-1
      elseif k=="E" then x=x+1
      elseif k=="W" then x=x-1
      elseif k=="U" then z=z+1
      elseif k=="D" then z=z-1
      elseif k=="V" then
        deb("\nIs V always a portal? Will say it is z+5")
        --TODO: Probably should skip if they are temporary
        --Note that I am not ever deleting exits, but perhaps should
        z=z+5
        specialDirection = true
      else
        echo("\nDo not recognize ["..k.."] so will make it z+10")
        z=z+10
        specialDirection = true
      end
      
      deb("d")
      deb(string.format("created room %s at %s,%s,%s\n",destID,x,y,z))
      setRoomCoordinates(destID,x,y,z)
    end
    deb("[after if]")
    deb("\nabout to setExit, "..localID.." "..destID.." "..k)
    deb("[check if common]")
    if table.index_of(({"N","S","E","W","U","D"}), k) then
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
  GUI.Box3:echo(exitText)
  updateMap()
  centerview(localID)
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
  deb("...AFTER")
end
