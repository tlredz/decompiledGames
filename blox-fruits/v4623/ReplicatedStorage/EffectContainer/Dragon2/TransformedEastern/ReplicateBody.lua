local DragonMoverClass = require(script.Parent:WaitForChild("DragonMoverClass"))
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local parent = hrp.Parent
	local dragonPart = data.dragonPart
	local collisionPart = data.collisionPart
	local easternDragon = data.easternDragon
	local scriptInstance = data.scriptInstance
	DragonMoverClass.new(player, parent, hrp, dragonPart, collisionPart, easternDragon, scriptInstance)
end