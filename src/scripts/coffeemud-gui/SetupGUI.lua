--[[
This file changes some UI elements that were set up in the template. 
I believe this will run after the template code just by having it listed afterward.
It duplicates code, but I wanted to leave the other part untouched as much as I can.
-Tim
--]]


GUI.Icon1:echo("Look")
GUI.Icon2:echo("Score")
GUI.Icon3:echo("Who")
GUI.Icon4:echo("Where")
GUI.Icon5:echo("Areas")
GUI.Icon6:echo("Weather")
GUI.Icon7:echo("Time")
GUI.Icon8:echo("Exits")
GUI.Icon1:setClickCallback(function() send("look") end)
GUI.Icon2:setClickCallback(function() send("score") end)
GUI.Icon3:setClickCallback(function() send("who") end)
GUI.Icon4:setClickCallback(function() send("where") end)
GUI.Icon5:setClickCallback(function() send("areas") end)
GUI.Icon6:setClickCallback(function() send("weather") end)
GUI.Icon7:setClickCallback(function() send("time") end)
GUI.Icon8:setClickCallback(function() send("exits") end)
--Marisa's screenshot had 8 buttons.  Might remove 9-12 later, might just fill it out.
GUI.Box1:echo("") --Map
GUI.Box2:echo("Might put exit list here")
GUI.Box3:echo("This box will have exits")
GUI.Box4:echo("This box will have name, title, wealth")
GUI.Box5:echo("Stats could go here<br>but they are not in GMCP")
GUI.Box6:echo("Maybe inventory<br>But inventory is<br>not in GMCP info")
GUI.Box7:echo("This box will have location information")
GUI.Health.front:echo("Health")
GUI.Mana.front:echo("Mana")
GUI.Endurance.front:echo("Moves")
GUI.Willpower.front:echo("Undecided")

--Map stuff pasted from example, TODO: come back to this and customize it
GUI.Map_Container = Geyser.Container:new({
name = "GUI.Map_Container",
x = 0, y = 0,
width = "100%",
height = "100%",
},GUI.Box1)

GUI.Mapper = Geyser.Mapper:new({
name = "GUI.Mapper",
x = 20, y = 20,
width = GUI.Map_Container:get_width()-40,
height = GUI.Map_Container:get_height()-40,
},GUI.Map_Container)

--the map's default background color is black, so lets blend it in...
GUI.Box1CSS = CSSMan.new(GUI.BoxCSS:getCSS())
GUI.Box1CSS:set("background-color", "black")
GUI.Box1:setStyleSheet(GUI.Box1CSS:getCSS())
