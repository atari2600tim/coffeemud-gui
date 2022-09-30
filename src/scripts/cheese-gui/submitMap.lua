addMapMenu("Tim Menu") -- add submenu to the general menu
addMapEvent("submitMapItem", "onSubmitMap", "Tim Menu", "Build messages to submit handcrafted room coordinates to the game")

function submitMap()
  local i, val
  local SelectedRooms = getMapSelection()["rooms"]
  --echo("Copy and paste or click the red part:\n")
  echo("\nCopy and paste (or fix up my echoLink code):\n")
  for _, val in ipairs(SelectedRooms) do
    --echo(string.format("val=%d:, cmd=",val))
    --echo("pre\n")
    local fileName=getRoomUserData(val,"file")
    --display(fileName)
    if (fileName ~= "") then
      --echo("looking at "..fileName.."\n")
      local x,y,z=getRoomCoordinates(val)
      local areaName=getRoomAreaName(getRoomArea(val))
      local cmdString = string.format("gmap %s:%d:%d:%d:%s\n",fileName,x,y,z,areaName)
      if(autoSendMap) then
        tempTimer((math.random(20, 500)/10.0), function() send(cmdString,false) end)
        local timerText
        tempTimer(30, function() deleteRoom(val) end)
      else
        --cechoLink("<red>click ",[[send(cmdString)]],"click to send", true)
        echo(cmdString)
      end
    else
      echo("Skipping room "..val..", we don't know filename\n")
    end

--cechoLink("<red>press <brown:white>me!", [[send("hi")]], "This is a tooltip", true)
    -- gmap /u/t/tim/workroom:1:2:3:Area is here
  end
end