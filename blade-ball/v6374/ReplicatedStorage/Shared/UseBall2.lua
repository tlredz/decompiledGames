local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local v = require3(ReplicatedStorage2.ServerInfo)
return function()
	if workspace:GetAttribute("CurrentlySelectedMode") == "HalloweenEvent" or v.isBossFightServer() or (v.isTutorialServer() or v.isNoAbilityRankedMatchServer()) then
		return true
	end

	if v.isDungeonsMatchServer() or game.PlaceId == 15240096157 then
		return true
	end

	return false
end