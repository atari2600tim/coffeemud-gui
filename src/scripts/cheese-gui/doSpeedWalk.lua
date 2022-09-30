function doSpeedWalk()
  echo("Path we need to take: " .. table.concat(speedWalkDir, ", ") .. "\n")
  echo("Rooms we'll pass through: " .. table.concat(speedWalkPath, ", ") .. "\n")
  --echo("pre\n")
  --display(speedWalkDir)
  for _,x in ipairs(speedWalkDir) do
    local arr = string.split(x,",")
    for _,y in ipairs(arr) do
      send(y)
    end
    --send(x)
  end
  --echo("post\n")
end