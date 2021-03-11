--[[
In starting room, typed: lua gmcp.room
{
  info = {
    coord = {
      cont = 0,
      id = 0,
      x = -1,
      y = -1
    },
    desc = "This is the entrance to the Mud School Zone.  Go north to go through mud school.  Go 
south to fight in the school arena.\r\n\r\nA sign warns `You may not pass these doors once you have 
passed level 5.`",
    details = "",
    exits = {
      N = 299884817,
      S = 299884783
    },
    id = "Mud School#3700",
    name = "Entrance to Mud School",
    num = 299884655,
    terrain = "wooden",
    zone = "Mud School"
  }
}

coord: neighboring rooms are also -1,-1, this is not like northwest of 0,0
I guess it means default.

info.coord.cont = 0 - continent? 
info.coord.id = 0 -- ???
info.id = "Mud School#3700"
info.zone is "Mud School", maybe that matches the cont or id?


In Mud School there is some overlap...
see if there is a good way to stretch all parallel lines or what
 ED
 F
 CB
  A
like maybe if you move ABCBDE and you see that F is not C then move ABC all down so BD is longer?

In the northern center of the arena, it has room #6
 that matched one near the starting area
  id = "Mud School#3744",
  name = "North Wall of Arena",
  num = 299884783,
  terrain = "desert",
  zone = "Mud School"


--]]

mudlet = mudlet or {}
mudlet.mapper_script = true



function handle_room()
echo("BEFORE...")
--echo(display(gmcp.room.info.coord))
--echo("pre")
  local localID = getRoomIDbyHash(gmcp.room.info.num)
  echo("A")
  if localID == -1 then
    localID = createRoomID()
    setRoomIDbyHash(localID, gmcp.room.info.num)
    addRoom(localID)
    centerview(localID)
  end
  echo("B")
  setRoomName(localID, gmcp.room.info.name)
  echo("C")
  
  if(gmcp.room.info.coord.x ~= -1 or gmcp.room.info.coord.y ~= -1) then
    echo("\nOH! coords that aren't -1,-1:"..gmcp.room.info.coord.x..","..gmcp.room.info.coord.y)
  end
  
  --setRoomCoordinates(localID, gmcp.room.info.coord.x, gmcp.room.info.coord.y, 0)
  -- play some and try going upstairs to see if they have Z or not
  -- bah, those are all -1 anyway
    
  echo("D")
  for k,v in pairs(gmcp.room.info.exits) do
    --echo("entered loop")
    local destID = getRoomIDbyHash(v)
    if destID == -1 then
      destID = createRoomID()
      setRoomIDbyHash(destID, v)
      addRoom(destID)
      local x,y,z = getRoomCoordinates(localID)
      
      echo("a")
      echo(string.format("\nam in %s at %s,%s,%s...",localID,x,y,z))
      echo("b")

      
      if k=='N' or k=='NE' or k=='NW' then
        y=y+1
      end
      if k=='S' or k=='SE' or k=='SW' then
        y=y-1
      end
      if k=='W' or k=='NW' or k=='SW' then
        x=x-1
      end
      if k=='E' or k=='NE' or k=='SE' then
        x=x+1
      end
      if k=='U' then
        z=z+1
      end
      if k=='D' then
        z=z-1
      end
      echo(string.format("created room %s at %s,%s,%s\n",destID,x,y,z))

      setRoomCoordinates(destID,x,y,z)
    end
    setExit(localID, destID, k)
    local a1,b1,c1=getRoomCoordinates(localID)
    local a2,b2,c2=getRoomCoordinates(destID)
    if (math.abs(a2-a1) > 1 or math.abs(b2-b1) > 1) then
      echo("\nhmm, rooms are spread out\n")
      echo(string.format("local %s is at %s,%s, dest %s to %s is at %s,%s",localID,a1,b1,k,destID,a2,b2))
    end
  end
  echo("E")
  updateMap()
  centerview(localID)
--echo(string.format("You are in %s\n", gmcp.room.info.id))
echo("...AFTER")
end
