local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.shared.modules.library.harpoonGuns)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("world")
local GenericHarpoonMultiClick = {
	MorphHarpoon = function(p, _, object)
		local random = object:GetRandom(62)
		p.reelTrove:Add(object.core.pullButtons.OnButtonAdd:Connect(function(p2)
			p2.requiredClicks = random:NextInteger(p.config.ClicksMin, p.config.ClicksMax)
			p2.clicksRemaining = p2.requiredClicks
		end))
		p.reelTrove:Add(object.core.pullButtons.OnClickEvent:Connect(function(p2)
			if p2.button.clicksRemaining > 0 and p2.button.despawnTimer ~= nil then
				p2.button:ModifyDespawnTime("add", 0.5)
			end
		end))
	end
}
setmetatable(GenericHarpoonMultiClick, module)
return GenericHarpoonMultiClick