local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("ServerScriptService")
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local remoteEvent = Net:RemoteEvent("Companion/RequestMood")
local PenguinPalFreezing = {
	MorphSpear = true,
	Morph = function(p, _, object)
		local scaledConfig = CompanionController.GetScaledConfig(p.config)
		local random = object:GetRandom(42)
		task.spawn(function()
			object:WaitUntilReady()
			local v = not scaledConfig.AttemptImmediate and 0 or scaledConfig.AttemptInterval
			local now = -1e999
			p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
				if not object.active then
					return
				end

				v += p2

				if v < scaledConfig.AttemptInterval then
					return
				end

				v = 0

				if tick() - now < scaledConfig.Cooldown or random:NextNumber(0, 100) > scaledConfig.TriggerChance then
					return
				end

				now = tick()

				if not object.data.SlashDisableStun then
					object:FreezeFish(scaledConfig.Duration)
				end

				remoteEvent:FireServer("Freezing")
			end))
		end)
	end
}
setmetatable(PenguinPalFreezing, module)
return PenguinPalFreezing