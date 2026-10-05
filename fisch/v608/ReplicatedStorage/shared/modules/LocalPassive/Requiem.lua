local Requiem = {}
game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local module = require("./PassiveHandler")

function Requiem.Morph(p, _, object)
	object:Preload({ script })
	local forcedProgressSpeedConfig

	if object.stats.ForcedProgressSpeed <= p.config.ForcedProgressSpeedThreshold and fish[object.fish.Name].Rarity ~= "Special" then
		forcedProgressSpeedConfig = p.config.ForcedProgressSpeedConfig
	else
		forcedProgressSpeedConfig = p.config
	end

	task.spawn(function()
		object:WaitUntilReady()
		local v = 0
		p.reelTrove:Add(object.OnBarDirectionChange:Connect(function()
			local now = tick()
			local v2 = now - v <= forcedProgressSpeedConfig.FailThreshold

			if v2 or now - v > forcedProgressSpeedConfig.ClickThreshold or not object.onbar then
				v = now

				if v2 then
					object:AddProgress(-100000 / math.max(object.trueprogressefficiency, 0.0001))
				end
			else
				v = now
				object:AddProgress(forcedProgressSpeedConfig.ProgressPerClick)
			end
		end))
	end)
end

setmetatable(Requiem, module)
return Requiem