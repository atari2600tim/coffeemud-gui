mudlet.custom_speedwalk = true
function doSpeedWalk()
  --echo("Room we're coming from: " .. speedWalkFrom .. "\n")
  --echo("Room you're going to: " .. speedWalkTo .. "\n")
  if(getPath(speedWalkFrom, speedWalkTo)) then
    cecho("<green>MAPPER<reset> Path we need to take: " .. table.concat(speedWalkDir, ", ") .. "\n")
    cecho("<green>MAPPER<reset> Rooms we'll pass through: " .. table.concat(speedWalkPath, ", ") .. "\n")
    for _,x in ipairs(speedWalkDir) do
      local arr = string.split(x,",")
      for _,y in ipairs(arr) do
        send(y)
      end
    end
  else
    local dest = getRoomUserData(speedWalkTo, "file")
    if (dest ~= "") then
      cecho("<green>MAPPER<reset> No path to "..speedWalkTo.." found, will try goto\n")
      send("goto "..dest)
    else
      cecho("<green>MAPPER<reset> No path found and do not know the filename of "..speedWalkTo.."\n")
    end
  end
end