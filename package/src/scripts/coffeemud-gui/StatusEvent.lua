--[[
This puts GMCP data into GUI, is triggered by event gmcp.char.

-Tim
--]]

function StatusEvent()
  if (not gmcp.char) then
    return "StatusEvent called without data"
  end
  local b = gmcp.char.base
  local s = gmcp.char.status
  if b then
    local output=string.format("Player: %s<br>The Level %s %s %s",
      b.name, gmcp.char.statusvars.level, b.race, b.class
    )
    if b.subclass then
      output = output.."<br>Subclass: "..b.subclass
    end
    
    if(gmcp.char.worth) then output = output .. "<br>Gold: "..gmcp.char.worth.gold end
    -- Gold seems to wrongly be set as 0 in testing.  It gave me accurate numbers before, when I was in the Mud School area.
    
    GUI.Box4:echo(output)
    output = ""
    if s then
      output = string.format("%s<br><br>state: [%s]<br>%s [%s]<br>💦 [%s]<br>💧 [%s]<br>🍴 [%s]<br>🦨 [%s%%]",
        (s.pos or "?"),
        (s.state or "?"),
        (s.align and ((math.abs(s.align)<4500) and "😐" or (s.align<0 and "😈" or "😇")) or "?"),
        (s.align or "?"),
        (s.fatigue or "?"),
        (s.thirst or "?"),
        (s.hunger or "?"),
        (s.stink_pct or "?")
      )
      -- that complex one was taken from http://lua-users.org/wiki/TernaryOperator

      if(s.enemy) then
        output = string.format("%s<br><br>⚔️ %s [%s%%]<br>",output,s.enemy,s.enemypct)
      end
      GUI.Box5:echo(output)
    end
  end
  if gmcp.char.status then
  end
  if gmcp.char.vitals then
  --status and vitals appear to arrive early
  --maxstats and base arrive later, so use vitals for both temporarily
    local hp=gmcp.char.vitals.hp
    local maxhp=gmcp.char.maxstats.maxhp or hp
    local mana=gmcp.char.vitals.mana
    local maxmana=gmcp.char.maxstats.maxmana or mana
    local moves=gmcp.char.vitals.moves
    local maxmoves=gmcp.char.maxstats.maxmoves or moves
    local tnl=gmcp.char.status.tnl or 0
    local maxtnl=gmcp.char.base.perlevel or tnl
    GUI.Health:setValue(hp, maxhp)
    GUI.Mana:setValue(mana, maxmana)
    GUI.Endurance:setValue(moves, maxmoves)
    GUI.Willpower:setValue(maxtnl-tnl,maxtnl)
    local output
    output = string.format("Health [ %s / %s ]",hp,maxhp)
    GUI.Health.front:echo(output)
    GUI.Health.back:echo(output)
    output = string.format("Mana [ %s / %s ]",mana,maxmana)
    GUI.Mana.front:echo(output)
    GUI.Mana.back:echo(output)
    output = string.format("Movement [ %s / %s ]",moves,maxmoves)
    GUI.Endurance.front:echo(output)
    GUI.Endurance.back:echo(output)
    output = string.format("Experience [ %s / %s ]",maxtnl-tnl,maxtnl)
    GUI.Willpower.front:echo(output)
    GUI.Willpower.back:echo(output)
  end
end
