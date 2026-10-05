local SillySealClientFishBite = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("./PassiveHandler")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local Net = require(ReplicatedStorage.packages.Net)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local remoteEvent = Net:RemoteEvent("Companion/SillySeal/AteFish")

function SillySealClientFishBite.Morph(p, _, object)
	task.spawn(function()
		object:WaitUntilReady()

		if not (object.data and object.data.SealActive) then
			return
		end

		local v = fish[object.fish.Name]
		local scaledConfig = CompanionController.GetScaledConfig(p.config)
		local random = object:GetRandom(99)
		local v2 = false

		local function biteOnce()
			if table.find(scaledConfig.BiteBlacklist.Name, object.fish.Name) or table.find(
				scaledConfig.BiteBlacklist.Rarity,
				v.Rarity
			) or (not object.active or v2) then
				return
			end

			if not (random:NextInteger(1, 100) <= scaledConfig.EatChance and table.find(
				scaledConfig.RaritiesToEat,
				v.Rarity
			)) then
				object:AddProgress(scaledConfig.BiteProgress)
				return
			end

			v2 = true
			remoteEvent:FireServer()
			object:EndMinigame(true)
		end

		p.reelTrove:Add(task.spawn(function()
			while object.active and not v2 do
				object:WaitLogic(random:NextNumber() * (scaledConfig.BiteIntervalMax - scaledConfig.BiteIntervalMin) + scaledConfig.BiteIntervalMin)

				if object.active and not v2 then
					biteOnce()
				else
					break
				end
			end
		end))
	end)
end

setmetatable(SillySealClientFishBite, module)
return SillySealClientFishBite