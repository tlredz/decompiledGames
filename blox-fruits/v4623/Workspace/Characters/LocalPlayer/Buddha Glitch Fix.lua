local character = game.Players.LocalPlayer.Character
local Global = require(game.ReplicatedStorage.Global)

if Global.BoatsDisabled then
	local Global2 = require(game.ReplicatedStorage.Global)
	Global2.BoatsDisabled:Disconnect()
end

local Global2 = require(game.ReplicatedStorage.Global)
Global2.BoatsDisabled = false
local humanoid = character:WaitForChild("Humanoid")
task.spawn(function()
	local SharedSignals = require(game.ReplicatedStorage:WaitForChild("SharedSignals"))
	local v = false
	local connection = SharedSignals.TransformationChanged():Connect(function(p, _, p2)
		if p2 then
			return
		end

		if p and not v then
			v = true
			local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
			AttributeCounter.add(humanoid, "BlockSit")
		elseif not p and v then
			v = false
			local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
			AttributeCounter.remove(humanoid, "BlockSit")
		end
	end)
	humanoid.Died:Once(function()
		connection:Disconnect()
	end)
end)