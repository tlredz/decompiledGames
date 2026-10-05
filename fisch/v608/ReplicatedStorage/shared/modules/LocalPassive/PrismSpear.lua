local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
local PrismSpear = {
	MorphSpear = function(p, _, object)
		local modifier = object:CreateModifier("progressefficiency", "force_add")
		local count = 0
		p.reelTrove:Add(object.core.simplifiedMinigame.OnPiercing:Connect(function()
			count += 1
			local v = count
			modifier.Value += p.config.ForcedProgressSpeedBoost
			object:WaitLogic(p.config.Timeout)

			if count == v then
				modifier.Value = 0
			end
		end))
	end
}
setmetatable(PrismSpear, module)
return PrismSpear